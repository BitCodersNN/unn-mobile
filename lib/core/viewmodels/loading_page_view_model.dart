import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/base_file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha_provider.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_provider.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';

enum _TypeScreen {
  authScreen,
  mainScreen,
}

class LoadingPageViewModel extends BaseViewModel {
  final LoggerService _loggerService;
  final AuthorizationRefreshService _initializingApplicationService;
  final LastCommitShaService _lastCommitShaService;
  final LoadingPageConfigService _loadingPageConfigService;
  final BaseFileDownloaderService _logoDownloaderService;
  final LastCommitShaProvider _lastCommitShaProvider;
  final LoadingPageProvider _loadingPageProvider;

  final CurrentUserSyncStorage _typeOfCurrentUser;
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;
  final UserDataProvider _userDataProvider;
  final AppOpenTracker _appOpenTracker;

  LoadingPageModel? _actualLoadingPage;
  File? _logoImage;

  LoadingPageModel? get loadingPageData => _actualLoadingPage;
  LoadingPageModel? get defaultPageData => LoadingPageModel(imagePath: '');
  File? get logoImage => _logoImage;

  LoadingPageViewModel(
    this._loggerService,
    this._initializingApplicationService,
    this._lastCommitShaService,
    this._loadingPageConfigService,
    this._logoDownloaderService,
    this._lastCommitShaProvider,
    this._loadingPageProvider,
    this._typeOfCurrentUser,
    this._gettingProfileOfCurrentUser,
    this._userDataProvider,
    this._appOpenTracker,
  );

  void decideRoute(context) {
    _init().then((value) => _goToScreen(context, value));
  }

  Future<void> initLoadingPages() async {
    final [
      loadingPages as List<LoadingPageModel>?,
      downloadsPath as String?,
    ] = await Future.wait([
      _loadingPageProvider.getData(),
      getDownloadPath(),
    ]);

    if (loadingPages == null || downloadsPath == null) {
      throw Exception('Failed to fetch loading pages data or download path');
    }

    _actualLoadingPage = _getCurrentLoadingPageModel(loadingPages);

    if (_actualLoadingPage == null) {
      throw Exception('Invalid loading page data');
    }

    _logoImage = File('$downloadsPath/${_actualLoadingPage!.imagePath}');

    if (!await _logoImage!.exists()) {
      _logoImage = await _logoDownloaderService
          .downloadFile(_actualLoadingPage!.imagePath);
    }

    if (_logoImage == null) {
      throw Exception('Failed to download logo image');
    }
  }

  Future<_TypeScreen> _init() async {
    AuthRequestResult? authRequestResult;
    late _TypeScreen typeScreen;

    await AppSettings.load();

    final [shaFromService, shaFromProvider] = await Future.wait([
      _lastCommitShaService.getSha(),
      _lastCommitShaProvider.getData(),
    ]);

    if (shaFromProvider == null || shaFromService != shaFromProvider) {
      Future.wait([
        _saveLoadingPagesFromGit(),
        _lastCommitShaProvider.saveData(shaFromService),
      ]);
    }

    try {
      authRequestResult = await _initializingApplicationService.refreshLogin();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }
    typeScreen = switch (authRequestResult) {
      null => _TypeScreen.authScreen,
      AuthRequestResult.success => _TypeScreen.mainScreen,
      AuthRequestResult.noInternet => _TypeScreen.mainScreen,
      AuthRequestResult.wrongCredentials => _TypeScreen.authScreen,
      AuthRequestResult.unknown => _TypeScreen.authScreen,
    };

    if (typeScreen == _TypeScreen.mainScreen) {
      await _initUserData();
    }

    return typeScreen;
  }

  void _goToScreen(BuildContext context, _TypeScreen typeScreen) {
    final route = switch (typeScreen) {
      _TypeScreen.authScreen => authPageRoute,
      _TypeScreen.mainScreen => mainPageRoute,
    };
    GoRouter.of(context).go(route);
  }

  Future<void> _initUserData() async {
    if (await _appOpenTracker.isFirstTimeOpenOnVersion()) {
      final profile =
          await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      _userDataProvider.saveData(profile);
    }

    await _typeOfCurrentUser.updateCurrentUserInfo();
    if (_typeOfCurrentUser.currentUserData != null &&
        _typeOfCurrentUser.currentUserData!.fullUrlPhoto != null) {
      DefaultCacheManager().downloadFile(
        _typeOfCurrentUser.currentUserData!.fullUrlPhoto!,
      );
    }
  }

  Future<void> _saveLoadingPagesFromGit() async {
    final loadingPages = await _loadingPageConfigService.getLoadingPages();

    if (loadingPages == null) {
      return;
    }

    await Future.wait([
      _loadingPageProvider.saveData(loadingPages),
      _logoDownloaderService
          .downloadFiles(loadingPages.map((model) => model.imagePath).toList()),
    ]);
  }

  LoadingPageModel _getCurrentLoadingPageModel(
    List<LoadingPageModel> loadingPages,
  ) {
    final today = DateTime.now();

    return loadingPages.firstWhere(
      (model) =>
          model.dateTimeRangeToUseOn != null &&
          _isDateInRange(today, model.dateTimeRangeToUseOn!),
      orElse: () => loadingPages.firstWhere(
        (model) => model.dateTimeRangeToUseOn == null,
      ),
    );
  }

  bool _isDateInRange(DateTime date, DateTimeRange range) {
    final start = range.start;
    final end = range.end;

    final isStartBeforeOrEqual = start.month < date.month ||
        (start.month == date.month && start.day <= date.day);
    final isEndAfterOrEqual = end.month > date.month ||
        (end.month == date.month && end.day >= date.day);

    return isStartBeforeOrEqual && isEndAfterOrEqual;
  }
}

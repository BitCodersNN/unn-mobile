import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/misc/date_time_extensions.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha_provider.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_provider.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';

class LoadingPageViewModel extends BaseViewModel {
  final LoggerService _loggerService;
  final AuthorizationRefreshService _initializingApplicationService;
  final LastCommitShaService _lastCommitShaService;
  final LoadingPageConfigService _loadingPageConfigService;
  final FileDownloaderService _logoDownloaderService;
  final LastCommitShaProvider _lastCommitShaProvider;
  final LoadingPageProvider _loadingPageProvider;
  final CurrentUserSyncStorage _typeOfCurrentUser;
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;
  final UserDataProvider _userDataProvider;
  final AppOpenTracker _appOpenTracker;

  LoadingPageModel? _actualLoadingPage;
  File? _logoImage;

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

  LoadingPageModel? get defaultPageData => LoadingPageModel(imagePath: '');
  LoadingPageModel? get loadingPageData => _actualLoadingPage;

  File? get logoImage => _logoImage;

  void decideRoute(context) {
    _init().then((value) => _goToScreen(context, value));
  }

  Future<void> initLoadingPages() async {
    final loadingPages = await _loadingPageProvider.getData();

    if (loadingPages == null) {
      throw Exception('Failed to fetch loading pages data');
    }

    _actualLoadingPage = _getCurrentLoadingPageModel(loadingPages);

    if (_actualLoadingPage == null) {
      throw Exception('Invalid loading page data');
    }

    _logoImage = await _logoDownloaderService
        .downloadFile(_actualLoadingPage!.imagePath);

    if (_logoImage == null) {
      throw Exception('Failed to download logo image');
    }
  }

  LoadingPageModel _getCurrentLoadingPageModel(
    List<LoadingPageModel> loadingPages,
  ) {
    final today = DateTime.now();

    return loadingPages.firstWhere(
      (model) =>
          model.dateTimeRangeToUseOn != null &&
          today.isDateInRangeIgnoringYear(model.dateTimeRangeToUseOn!),
      orElse: () => loadingPages.firstWhere(
        (model) => model.dateTimeRangeToUseOn == null,
      ),
    );
  }

  void _goToScreen(BuildContext context, _TypeScreen typeScreen) {
    final route = switch (typeScreen) {
      _TypeScreen.authScreen => authPageRoute,
      _TypeScreen.mainScreen => mainPageRoute,
    };
    GoRouter.of(context).go(route);
  }

  Future<_TypeScreen> _init() async {
    AuthRequestResult? authRequestResult;
    late _TypeScreen typeScreen;

    final [shaFromService, shaFromProvider] = await Future.wait([
      _lastCommitShaService.getSha(),
      _lastCommitShaProvider.getData(),
    ]);

    if (shaFromProvider == null || shaFromService != shaFromProvider) {
      Future.wait([
        _saveLoadingPagesConfigFromGit(),
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

  Future<void> _saveLoadingPagesConfigFromGit() async {
    final loadingPagesConfig =
        await _loadingPageConfigService.getLoadingPages();

    if (loadingPagesConfig == null) {
      return;
    }

    await Future.wait([
      _loadingPageProvider.saveData(loadingPagesConfig),
      _logoDownloaderService.downloadFiles(
        loadingPagesConfig.map((model) => model.imagePath).toList(),
      ),
    ]);
  }
}

enum _TypeScreen {
  authScreen,
  mainScreen,
}

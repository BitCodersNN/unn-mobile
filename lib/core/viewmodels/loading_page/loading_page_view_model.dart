// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/birthday/birthday_greeting_catalog.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_catalog.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';
import 'package:unn_mobile/core/providers/interfaces/profile/user_data_provider.dart';
import 'package:unn_mobile/core/repositories/interfaces/git/git_resource_repository.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/stream_auth_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';

class LoadingPageViewModel extends BaseViewModel {
  final LoggerService _loggerService;
  final AuthRefreshService _initializingApplicationService;
  final GitResourceRepository<LoadingPageCatalog> _loadingPages;
  final LogoDownloaderService _logos;
  final CurrentUserSyncStorage _typeOfCurrentUser;
  final ProfileOfCurrentUserService _gettingProfileOfCurrentUser;
  final StreamAuthService _streamAuthService;
  final UserDataProvider _userDataProvider;
  final AppOpenTracker _appOpenTracker;
  final GitResourceRepository<BirthdayGreetingCatalog> _birthdayCatalog;

  LoadingPageModel? _actualLoadingPage;
  File? _logoImage;

  LoadingPageViewModel(
    this._loggerService,
    this._initializingApplicationService,
    this._loadingPages,
    this._logos,
    this._typeOfCurrentUser,
    this._gettingProfileOfCurrentUser,
    this._userDataProvider,
    this._streamAuthService,
    this._appOpenTracker,
    this._birthdayCatalog,
  );

  LoadingPageModel? get defaultPageData => LoadingPageModel(imagePath: '');
  LoadingPageModel? get loadingPageData => _actualLoadingPage;

  File? get logoImage => _logoImage;

  void decideRoute(BuildContext context) {
    _init().then((value) {
      if (context.mounted) {
        _goToScreen(context, value);
      }
    });
  }

  Future<void> initLoadingPages() async {
    final resource = await _loadingPages.get();
    final page = resource?.data.pageForDate(DateTime.now());
    if (resource == null || page == null) {
      _actualLoadingPage = null;
      _logoImage = null;
      return;
    }
    final logo = await _logos.downloadFile(
      page.imagePath,
      revision: resource.sha ?? GitPath.branch,
      allowLegacyFallback: resource.isLegacy,
    );
    _actualLoadingPage = page;
    _logoImage = logo;
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

    unawaited(_birthdayCatalog.refresh());

    unawaited(_loadingPages.refresh());

    try {
      authRequestResult = await _initializingApplicationService.refreshLogin();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }
    final typeScreen = switch (authRequestResult) {
      null => _TypeScreen.authScreen,
      AuthRequestResult.success => _TypeScreen.mainScreen,
      AuthRequestResult.noInternet => _TypeScreen.mainScreen,
      AuthRequestResult.wrongCredentials => _TypeScreen.authScreen,
      AuthRequestResult.unknown => _TypeScreen.authScreen,
    };

    if (typeScreen == _TypeScreen.mainScreen) {
      await Future.wait([
        _initUserData(),
        _streamAuthService.getStreamAuthParams(),
      ]);
    }

    return typeScreen;
  }

  Future<void> _initUserData() async {
    if (await _appOpenTracker.isFirstTimeOpenOnVersion()) {
      final profile =
          await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      unawaited(_userDataProvider.saveData(profile));
    }

    await _typeOfCurrentUser.updateCurrentUserInfo();
    if (_typeOfCurrentUser.currentUserData != null &&
        _typeOfCurrentUser.currentUserData!.photoSrc != null) {
      unawaited(
        DefaultCacheManager().downloadFile(
          _typeOfCurrentUser.currentUserData!.photoSrc!,
        ),
      );
    }
  }
}

enum _TypeScreen {
  authScreen,
  mainScreen,
}

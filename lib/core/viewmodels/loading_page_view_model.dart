import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/loading_pages.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';

enum _TypeScreen {
  authScreen,
  mainScreen,
}

class LoadingPageViewModel extends BaseViewModel {
  final AuthorizationRefreshService _initializingApplicationService;
  final CurrentUserSyncStorage _typeOfCurrentUser;
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;
  final UserDataProvider _userDataProvider;
  final AppOpenTracker _appOpenTracker;
  final LoggerService _loggerService;

  LoadingPageViewModel(
    this._initializingApplicationService,
    this._typeOfCurrentUser,
    this._gettingProfileOfCurrentUser,
    this._userDataProvider,
    this._appOpenTracker,
    this._loggerService,
  );

  final actualLoadingPage = LoadingPages().actualLoadingPage;

  LoadingPageModel get loadingPageData => actualLoadingPage;

  void disateRoute(context) {
    _init().then((value) => _goToScreen(context, value));
  }

  Future<_TypeScreen> _init() async {
    AuthRequestResult? authRequestResult;
    late _TypeScreen typeScreen;

    await AppSettings.load();

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

  void _goToScreen(context, _TypeScreen typeScreen) {
    final routes = switch (typeScreen) {
      _TypeScreen.authScreen => Routes.authPage,
      _TypeScreen.mainScreen => Routes.mainPagePrefix,
    };
    Navigator.of(context!).pushNamedAndRemoveUntil(routes, (route) => false);
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
}

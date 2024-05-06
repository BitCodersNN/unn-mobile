import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/loading_pages.dart';
import 'package:unn_mobile/core/misc/type_of_current_user.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';

enum _TypeScreen {
  authScreen,
  mainScreen,
}

class LoadingPageViewModel extends BaseViewModel {
  final _initializingApplicationService =
      Injector.appInstance.get<AuthorisationRefreshService>();
  final _typeOfCurrnetUser = Injector.appInstance.get<TypeOfCurrentUser>();
  final _gettingProfileOfCurrentUser =
      Injector.appInstance.get<GettingProfileOfCurrentUser>();
  final _userDataProvider = Injector.appInstance.get<UserDataProvider>();
  final _appOpenTracker = Injector.appInstance.get<AppOpenTracker>();

  final actualLoadingPage = LoadingPages().actualLoadingPage;

  LoadingPageModel get loadingPageData => actualLoadingPage;

  void disateRoute(context) {
    _init().then((value) => _goToScreen(context, value));
  }

  Future<_TypeScreen> _init() async {
    AuthRequestResult? authRequestResult;
    late _TypeScreen typeScreen;

    try {
      authRequestResult = await _initializingApplicationService.refreshLogin();
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
    typeScreen = switch (authRequestResult) {
      null => _TypeScreen.authScreen,
      AuthRequestResult.success => _TypeScreen.mainScreen,
      AuthRequestResult.noInternet => _TypeScreen.mainScreen,
      AuthRequestResult.wrongCredentials => _TypeScreen.authScreen,
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
    if (await _appOpenTracker.isFirstAppOpenForVersion()) {
      final profile =
          await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      _userDataProvider.saveData(profile);
    }

    if (await _userDataProvider.isContained()) {
      await _typeOfCurrnetUser.updateTypeOfCurrentUser();
    } else {
      final profile =
          await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      _userDataProvider.saveData(profile);
      if (profile != null && profile.fullUrlPhoto != null) {
        DefaultCacheManager().downloadFile(profile.fullUrlPhoto!);
      }
      _typeOfCurrnetUser.typeOfUser = profile.runtimeType;
    }
  }
}

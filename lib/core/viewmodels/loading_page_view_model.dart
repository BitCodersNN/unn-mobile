import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/type_of_current_user.dart';
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
  final TypeOfCurrentUser _typeOfCurrnetUser =
      Injector.appInstance.get<TypeOfCurrentUser>();
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser =
      Injector.appInstance.get<GettingProfileOfCurrentUser>();
  final UserDataProvider _userDataProvider = 
      Injector.appInstance.get<UserDataProvider>();

  void disateRoute(context) {
    _init().then((value) => _goToScreen(context, value));
  }

  Future<_TypeScreen> _init() async {
    _TypeScreen typeScreen = switch (await _initializingApplicationService.refreshLogin()) {
      null => _TypeScreen.authScreen,
      AuthRequestResult.success => _TypeScreen.mainScreen,
      AuthRequestResult.noInternet => _TypeScreen.mainScreen,
      AuthRequestResult.wrongCredentials => _TypeScreen.authScreen,
      AuthRequestResult.unknownError => throw Exception('Unknown Error'),
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
    if (await _userDataProvider.isContained()) {
      await _typeOfCurrnetUser.updateTypeOfCurrentUser();    
    }
    else {
      final profile = await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      _userDataProvider.saveData(profile);
      DefaultCacheManager().downloadFile(profile!.fullUrlPhoto!);
      _typeOfCurrnetUser.typeOfUser = profile.runtimeType;
    }
  }
}

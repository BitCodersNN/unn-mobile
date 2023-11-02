import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/initializing_application_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';


enum _TypeScreen {
  authScreen,
  mainScreen,
}

class LoadingPageViewModel extends BaseViewModel{
  final _initializingApplicationService = Injector.appInstance.get<InitializingApplicationService>();
  
  void disateRoute(context) {
    _init().then((value) => _goToScreen(context, value));
  }

  Future<_TypeScreen> _init() async{
    final isUserExists = await _initializingApplicationService.isUserDataExistsInStorage();
    if (!isUserExists){
      _TypeScreen.authScreen;
    }

    final isAuthorized = await _initializingApplicationService.isAuthorized();

    return switch (isAuthorized){
      AuthRequestResult.success => _TypeScreen.mainScreen,
      AuthRequestResult.noInternet => _TypeScreen.mainScreen,
      AuthRequestResult.wrongCredentials => _TypeScreen.authScreen,
      AuthRequestResult.unknownError => throw Exception('Unknown Error'),
    };
  }

  void _goToScreen(context, _TypeScreen typeScreen){
    final routes = switch (typeScreen){
      _TypeScreen.authScreen => Routes.authPage,
      _TypeScreen.mainScreen => Routes.mainPage,
    };
    Navigator.of(context!).pushNamedAndRemoveUntil(routes, (route) => false);
  }
}
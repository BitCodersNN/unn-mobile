import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/initializing_application_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';

class LoaderViewModel extends BaseViewModel{
  final _initializingApplicationService = Injector.appInstance.get<InitializingApplicationService>();
  
  void init(context) async{
    final isUserExists = await _initializingApplicationService.isUserExists();
    if (!isUserExists){
      _goToAuthScreen(context);
    }

    final isAuthorized = await _initializingApplicationService.isAuthorized();

    switch (isAuthorized){
      case AuthRequestResult.success:
        _goToMainScreen(context);
        break;
      case AuthRequestResult.noInternet:
        throw Exception('No internet');
      case AuthRequestResult.wrongCredentials:
        _goToAuthScreen(context);
        break;
      case AuthRequestResult.unknownError:
        throw Exception('Unknown Error');
    }
  }

  void _goToAuthScreen(context){
    Navigator.of(context!).pushNamedAndRemoveUntil(Routes.authPage, (route) => false);
  }

  void _goToMainScreen(context) {
  Navigator.of(context!).pushNamedAndRemoveUntil(Routes.mainPage, (route) => false);
  }
}
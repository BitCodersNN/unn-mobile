import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/services/initializing_application_service.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/loader_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';

void main() {
  registerDependencies();
  runApp(const UnnMobile());
}

void registerDependencies() {
  // ignore: unused_local_variable
  var injector = Injector.appInstance;
  // register all the dependencies here:
  injector.registerSingleton(() => LoaderViewModel());
  injector.registerSingleton(() => AuthPageViewModel());
  injector.registerSingleton(() => MainPageViewModel());
  injector.registerSingleton(() => InitializingApplicationService());

}

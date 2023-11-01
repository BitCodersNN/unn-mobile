import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule.dart';

void main() {
  registerDependencies();
  runApp(const UnnMobile());
}

void registerDependencies() {
  // ignore: unused_local_variable
  var injector = Injector.appInstance;
  // register all the dependencies here:
  injector.registerDependency(() => MainPageViewModel());
  injector.registerDependency(() => ScheduleScreenViewModel());
}

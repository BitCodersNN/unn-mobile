import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/app.dart';

void main() {
  registerDependencies();
  runApp(const UnnMobile());
}

void registerDependencies() {
  // ignore: unused_local_variable
  var injector = Injector.appInstance;
  // register all the dependencies here:
}

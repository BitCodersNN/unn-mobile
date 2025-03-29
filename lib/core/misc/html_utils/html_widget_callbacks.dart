import 'dart:async';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:url_launcher/url_launcher.dart';

FutureOr<bool> htmlWidgetOnTapUrl(url) async {
  if (!await launchUrl(Uri.parse(url))) {
    Injector.appInstance.get<LoggerService>().log('Could not launch url $url');
  }
  return true;
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_event.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchGiveawayPromoUrl(String url, {LoggerService? logger}) async {
  final resolvedLogger = logger ?? Injector.appInstance.get<LoggerService>();
  final launched = await _tryLaunchUrl(Uri.parse(url), resolvedLogger);
  if (!launched) {
    resolvedLogger.log(DiagnosticEvent.urlLaunchFailed);
  }
  return launched;
}

Future<bool> _tryLaunchUrl(Uri uri, LoggerService logger) async {
  try {
    return await launchUrl(uri);
  } catch (error, stack) {
    logger.logError(error, stack);
    return false;
  }
}

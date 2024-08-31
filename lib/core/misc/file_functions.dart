import 'dart:io';

import 'package:injector/injector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

Future<String?> getDownloadPath() async {
  Directory? directory;
  try {
    directory = await getApplicationCacheDirectory();
    if (directory.existsSync()) {
      directory.createSync();
    }
  } catch (err, stack) {
    Injector.appInstance.get<LoggerService>().logError(
          err,
          stack,
        );
  }
  return directory?.path;
}

Future<void> clearCacheFolder() async {
  try {
    final cachePath = await getDownloadPath();
    if (cachePath != null) {
      final directory = Directory(cachePath);
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  } catch (error, stack) {
    Injector.appInstance.get<LoggerService>().logError(error, stack);
  }
}

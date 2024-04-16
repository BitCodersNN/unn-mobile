import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> getDownloadPath() async {
  Directory? directory;
  try {
    directory = await getApplicationCacheDirectory();
    if (directory.existsSync()) {
      directory.createSync();
    }
  } catch (err, stack) {
    FirebaseCrashlytics.instance
        .recordError("Cannot get download folder path: $err", stack);
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
    FirebaseCrashlytics.instance.recordError(error, stack);
  }
}

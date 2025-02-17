import 'dart:io';

import 'package:injector/injector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:path/path.dart' as p;

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
  const String projectName = 'ru.unn.unnMobile';
  final loggerService = Injector.appInstance.get<LoggerService>();
  final cachePath = await getDownloadPath();
  if (cachePath == null) {
    return;
  }
  final directory = Directory(cachePath);
  final entities = directory.listSync();

  await Future.forEach(entities, (entity) async {
    if (entity.path.endsWith(projectName)) {
      return;
    }
    if (!await entity.exists()) {
      return;
    }
    try {
      await entity.delete(recursive: entity is Directory);
    } catch (err, stack) {
      loggerService.logError(err, stack);
    }
  });
}

String shortenFileName(String fileName, [int maxFileNameLength = 127]) {
  final extension = p.extension(fileName);
  final baseName = p.basenameWithoutExtension(fileName);

  final shortenedBaseName = baseName.substring(
    0,
    baseName.length < maxFileNameLength
        ? baseName.length
        : maxFileNameLength - extension.length - 1,
  );
  return '$shortenedBaseName$extension';
}

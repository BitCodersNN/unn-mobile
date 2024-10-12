part of 'library.dart';

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

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:content_resolver/content_resolver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:path/path.dart' as p;

const MethodChannel _fileChannel = MethodChannel('ru.unn.unn_mobile/files');

Future<String?> openFilePicker(String fileName, String mimeType) async {
  await _fileChannel.invokeMethod(
    'pickDirectory',
    {
      'fileName': fileName,
      'mimeType': mimeType,
    },
  );
  const pickerEvents = EventChannel('ru.unn.unn_mobile/file_events');
  final pickerStream = pickerEvents.receiveBroadcastStream();
  final location = await pickerStream.first as String?;
  return location;
}

Future<Iterable<String>?> openUploadFilePicker(bool gallery) async {
  if (Platform.isAndroid) {
    await _fileChannel.invokeMethod('pickUploadFiles', {'gallery': gallery});
    const pickerEvents = EventChannel('ru.unn.unn_mobile/file_events');
    final pickerStream = pickerEvents.receiveBroadcastStream();
    final locations = await pickerStream.first as List<Object?>?;
    final uriStrings = locations?.cast<String>() ?? [];
    return await resolveAndroidContentUris(uriStrings);
  } else {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: gallery ? FileType.media : FileType.any,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.paths.nonNulls.cast<String>().toList();
  }
}

Future<List<String>> resolveAndroidContentUris(
  Iterable<String> uriStrings,
) async {
  final cacheDir = await getApplicationCacheDirectory();
  final tempDir = await cacheDir.createTemp();
  final List<String> paths = [];
  for (final uri in uriStrings) {
    final r = await ContentResolver.resolveContentMetadata(uri);
    final name = p.basename(r.fileName ?? 'null.txt');
    final filePath = '${tempDir.path}/$name';
    await ContentResolver.resolveContentToFile(uri, filePath);
    paths.add(filePath);
  }
  return paths;
}

Future<void> viewFile(String uri, String mimeType) async {
  try {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await _fileChannel.invokeMethod(
          'viewFile',
          {
            'uri': uri,
            'mimeType': mimeType,
          },
        );
        break;
      default:
        await OpenFilex.open(uri, type: mimeType);
        break;
    }
  } catch (error, stack) {
    Injector.appInstance.get<LoggerService>().log(
          'Could not open file.\n'
          'Exception: $error\n'
          'stack: $stack',
        );
  }
}

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

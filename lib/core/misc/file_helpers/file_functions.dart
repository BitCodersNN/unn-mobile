// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';
import 'dart:io';

import 'package:content_resolver/content_resolver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:open_filex/open_filex.dart' as ofx;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

const MethodChannel fileFunctionsMethodChannel = MethodChannel(
  'ru.bitcodersnn.unnstudenthub/files',
);

class OpenResult {
  final OpenResultType type;

  final String message;

  OpenResult(this.type, this.message);
  OpenResult.fromJson(Map<String, dynamic> json)
    : type = _typeFromJson(json['type']),
      message = json['message'];

  OpenResult.suceess() : type = OpenResultType.success, message = 'done';

  static OpenResultType _typeFromJson(int? jsonValue) => switch (jsonValue) {
    0 => OpenResultType.success,
    1 => OpenResultType.noApp,
    2 => OpenResultType.permissionDenied,
    3 => OpenResultType.notFound,
    _ => OpenResultType.error,
  };
}

enum OpenResultType { success, noApp, permissionDenied, notFound, error }

Future<String?> openFilePicker(String fileName, String mimeType) async {
  await fileFunctionsMethodChannel.invokeMethod('pickDirectory', {
    'fileName': fileName,
    'mimeType': mimeType,
  });
  const pickerEvents = EventChannel('ru.bitcodersnn.unnstudenthub/file_events');
  final pickerStream = pickerEvents.receiveBroadcastStream();
  final location = await pickerStream.first as String?;
  return location;
}

Future<OpenResult> viewFile(String uri, String mimeType) async {
  try {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => await _viewFileAndroid(uri, mimeType),
      _ => await _viewFileDefault(uri, mimeType),
    };
  } catch (error, stack) {
    Injector.appInstance.get<LoggerService>().log(
      'Could not open file.\n'
      'Exception: $error\n'
      'stack: $stack',
    );
    return OpenResult(OpenResultType.error, error.toString());
  }
}

Future<OpenResult> _viewFileAndroid(String uri, String mimeType) async {
  final result = await fileFunctionsMethodChannel.invokeMethod('viewFile', {
    'uri': uri,
    'mimeType': mimeType,
  });
  return OpenResult.fromJson(jsonDecode(result));
}

Future<OpenResult> _viewFileDefault(String uri, String mimeType) async {
  final result = await ofx.OpenFilex.open(uri, type: mimeType);
  return OpenResult(switch (result.type) {
    ofx.ResultType.done => OpenResultType.success,
    ofx.ResultType.noAppToOpen => OpenResultType.noApp,
    ofx.ResultType.fileNotFound => OpenResultType.permissionDenied,
    ofx.ResultType.permissionDenied => OpenResultType.permissionDenied,
    _ => OpenResultType.error,
  }, result.message);
}

Future<Iterable<String>?> openUploadFilePicker({required bool gallery}) async {
  if (Platform.isAndroid) {
    await fileFunctionsMethodChannel.invokeMethod('pickUploadFiles', {
      'gallery': gallery,
    });
    const pickerEvents = EventChannel(
      'ru.bitcodersnn.unnstudenthub/file_events',
    );
    final pickerStream = pickerEvents.receiveBroadcastStream();
    final locations = await pickerStream.first as List<Object?>?;
    final uriStrings = locations?.cast<String>() ?? [];
    return resolveAndroidContentUris(uriStrings);
  } else {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: gallery ? FileType.media : FileType.any,
      allowMultiple: true,
    );
    if (result == null) {
      return [];
    }
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

Future<String?> getDownloadPath() async {
  Directory? directory;
  try {
    directory = await getApplicationCacheDirectory();
    if (directory.existsSync()) {
      directory.createSync();
    }
  } catch (err, stack) {
    Injector.appInstance.get<LoggerService>().logError(err, stack);
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

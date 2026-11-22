// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/misc/file_helpers/image_file_validator.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

abstract class GitImageDownloaderBase {
  final LoggerService logger;
  final ApiHelper apiHelper;

  GitImageDownloaderBase(this.logger, this.apiHelper);

  GitPath get gitPath;

  @protected
  String? resolveDownloadFolder(List<String> segments);

  bool isValidRelativeSegments(Uri uri, List<String> segments) =>
      !uri.hasAuthority &&
      !uri.isAbsolute &&
      !uri.hasAbsolutePath &&
      !uri.hasQuery &&
      !uri.hasFragment &&
      segments.isNotEmpty &&
      !segments.any(
        (segment) =>
            segment.isEmpty ||
            segment == '.' ||
            segment == '..' ||
            segment.contains('/') ||
            segment.contains('\\'),
      );

  Future<File?> getValidatedCachedFile(String fileName) async {
    try {
      return await _getValidatedCachedFile(fileName);
    } catch (error, stack) {
      logger.logError(error, stack);
      return null;
    }
  }

  Future<File?> downloadAndValidateFile(
    String fileName, {
    required String revision,
  }) async {
    try {
      return await _downloadAndValidateFile(fileName, revision);
    } catch (error, stack) {
      logger.logError(error, stack);
      return null;
    }
  }

  Future<List<File>?> downloadAllFiles({
    required List<String> fileNames,
    required String revision,
  }) async {
    final results = await Future.wait([
      for (final fileName in fileNames)
        downloadAndValidateFile(fileName, revision: revision),
    ]);
    return results.any((file) => file == null) ? null : results.cast<File>();
  }

  Future<File?> _getValidatedCachedFile(String fileName) async {
    final location = await _resolveLocalLocation(fileName);
    if (location == null) {
      return null;
    }
    return _validatedFile(
      File(p.join(location.basePath, location.folder, location.name)),
    );
  }

  Future<File?> _downloadAndValidateFile(
    String fileName,
    String revision,
  ) async {
    final location = await _resolveLocalLocation(fileName);
    if (location == null) {
      return null;
    }
    final cached = await _validatedFile(
      File(p.join(location.basePath, location.folder, location.name)),
    );
    if (cached != null) {
      return cached;
    }
    final downloaded = await FileDownloader(
      logger,
      apiHelper,
      downloadFolderName: location.folder,
      basePath: '${ApiPath.gitRepository}/${gitPath.pathAt(revision)}',
    ).downloadFile(fileName, force: true);
    return downloaded == null ? null : _validatedFile(downloaded);
  }

  Future<({String basePath, String folder, String name})?>
  _resolveLocalLocation(String fileName) async {
    if (fileName.isEmpty || fileName.contains('\\')) {
      return null;
    }
    final uri = Uri.parse(fileName);
    final segments = uri.pathSegments;
    if (!isValidRelativeSegments(uri, segments)) {
      return null;
    }
    final folder = resolveDownloadFolder(segments);
    if (folder == null) {
      return null;
    }
    final basePath = await getDownloadPath();
    if (basePath == null) {
      return null;
    }
    return (
      basePath: basePath,
      folder: folder,
      name: shortenFileName(fileName),
    );
  }

  Future<File?> _validatedFile(File file) async {
    if (!await file.exists()) {
      return null;
    }
    try {
      await validateImageFile(file);
    } catch (error, stack) {
      logger.logError(error, stack);
      await _removeInvalidFile(file);
      return null;
    }
    return file;
  }

  Future<void> _removeInvalidFile(File file) async {
    try {
      await file.delete();
    } catch (error, stack) {
      logger.logError(error, stack);
    }
  }
}

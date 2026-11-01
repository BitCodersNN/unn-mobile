// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/misc/file_helpers/image_file_validator.dart';
import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader_service.dart';

class LogoDownloaderServiceImpl implements LogoDownloaderService {
  final LoggerService _logger;
  final ApiHelper _apiHelper;

  LogoDownloaderServiceImpl(this._logger, this._apiHelper);

  @override
  Future<File?> downloadFile(
    String fileName, {
    required String revision,
    bool allowLegacyFallback = false,
  }) async {
    try {
      return await _downloadFile(fileName, revision, allowLegacyFallback);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  Future<File?> _downloadFile(
    String fileName,
    String revision,
    bool allowLegacyFallback,
  ) async {
    final path = await getDownloadPath();
    if (path == null) {
      return null;
    }
    final name = shortenFileName(fileName);
    if (allowLegacyFallback) {
      final legacy = await _validatedFile(File('$path/logos/$name'));
      if (legacy != null) {
        return legacy;
      }
    }
    final cached = await _validatedFile(File('$path/logos/$revision/$name'));
    if (cached != null) {
      return cached;
    }
    final downloaded = await FileDownloader(
      _logger,
      _apiHelper,
      downloadFolderName: 'logos/$revision',
      basePath:
          '${ApiPath.gitRepository}/${GitPath.loadingScreen.pathAt(revision)}',
    ).downloadFile(fileName, force: true);
    return downloaded == null ? null : _validatedFile(downloaded);
  }

  Future<File?> _validatedFile(File file) async {
    if (!await file.exists()) {
      return null;
    }
    try {
      await validateImageFile(file);
    } catch (error, stack) {
      _logger.logError(error, stack);
      await _removeInvalidFile(file);
      return null;
    }
    return file;
  }

  Future<void> _removeInvalidFile(File file) async {
    try {
      await file.delete();
    } catch (error, stack) {
      _logger.logError(error, stack);
    }
  }

  @override
  Future<List<File>?> downloadFiles({
    required List<String> fileNames,
    required String revision,
  }) async {
    final results = await Future.wait([
      for (final fileName in fileNames)
        downloadFile(fileName, revision: revision),
    ]);
    return results.any((file) => file == null) ? null : results.cast<File>();
  }
}

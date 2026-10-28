// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
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
    if (allowLegacyFallback) {
      final path = await getDownloadPath();
      if (path != null) {
        final legacy = File('$path/logos/${shortenFileName(fileName)}');
        if (await legacy.exists()) {
          return legacy;
        }
      }
    }
    return FileDownloader(
      _logger,
      _apiHelper,
      downloadFolderName: 'logos/$revision',
      basePath:
          '${ApiPath.gitRepository}/${GitPath.loadingScreen.pathAt(revision)}',
    ).downloadFile(fileName);
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

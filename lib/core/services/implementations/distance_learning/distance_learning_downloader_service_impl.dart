// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_learning_downloader_service.dart';

class DistanceLearningDownloaderServiceImpl
    implements DistanceLearningDownloaderService {
  final FileDownloader _fileDownloader;

  DistanceLearningDownloaderServiceImpl(
    loggerService,
    apiHelper,
  ) : _fileDownloader = FileDownloader(
          loggerService,
          apiHelper,
          downloadFolderName: 'distanceLearning',
        );

  @override
  Future<File?> downloadFile({
    required String fileName,
    required String downloadUrl,
    bool force = false,
  }) {
    return _fileDownloader.downloadFile(
      fileName,
      downloadUrl: downloadUrl,
      force: force,
      pickLocation: true,
    );
  }
}

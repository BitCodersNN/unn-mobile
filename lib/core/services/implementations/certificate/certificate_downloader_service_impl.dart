// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class CertificateDownloaderServiceImpl implements CertificateDownloaderService {
  final FileDownloader _fileDownloader;

  CertificateDownloaderServiceImpl(
    LoggerService loggerService,
    ApiHelper apiHelper,
  ) : _fileDownloader = FileDownloader(
          loggerService,
          apiHelper,
          downloadFolderName: Platform.isAndroid ? null : 'certificate',
        );

  @override
  Future<File?> downloadFile(String fileName) => _fileDownloader.downloadFile(
        fileName,
        pickLocation: Platform.isAndroid,
      );
}

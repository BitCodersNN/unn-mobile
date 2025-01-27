import 'dart:io';

import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_downloader_service.dart';

class CertificateDownloaderServiceImpl implements CertificateDownloaderService {
  final FileDownloader _fileDownloader;

  CertificateDownloaderServiceImpl(
    loggerService,
    apiHelper,
  ) : _fileDownloader = FileDownloader(
          loggerService,
          apiHelper,
          downloadFolderName: 'certificate',
        );

  @override
  Future<File?> downloadFile(String fileName) async {
    return _fileDownloader.downloadFile(fileName);
  }
}
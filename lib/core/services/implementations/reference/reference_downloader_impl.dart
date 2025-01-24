import 'dart:io';

import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/reference/reference_downloader.dart';

class ReferenceDownloaderServiceImpl implements ReferenceDownloaderService {
  final FileDownloader _fileDownloader;

  ReferenceDownloaderServiceImpl(
    loggerService,
    apiHelper,
  ) : _fileDownloader = FileDownloader(
          loggerService,
          apiHelper,
        );

  @override
  Future<File?> downloadFile(String fileName) async {
    return _fileDownloader.downloadFile(fileName);
  }
}

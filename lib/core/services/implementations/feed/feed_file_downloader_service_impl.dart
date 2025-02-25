import 'dart:io';

import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/feed/feed_file_downloader_service.dart';

class FeedFileDownloaderServiceImpl implements FeedFileDownloaderService {
  final FileDownloader _fileDownloader;

  FeedFileDownloaderServiceImpl(
    loggerService,
    apiHelper,
  ) : _fileDownloader = FileDownloader(
          loggerService,
          apiHelper,
          downloadFolderName: 'feed',
        );

  @override
  Future<File?> downloadFile({
    required String fileName,
    required String downloadUrl,
    required bool force,
  }) async {
    return _fileDownloader.downloadFile(
      fileName,
      downloadUrl: downloadUrl,
      force: force,
    );
  }

  @override
  Future<List<File>?> downloadFiles({
    required List<String> fileNames,
    required String downloadUrl,
    required bool force,
  }) async {
    return _fileDownloader.downloadFiles(
      fileNames,
      downloadUrl: downloadUrl,
      force: force,
    );
  }
}

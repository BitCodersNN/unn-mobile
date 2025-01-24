import 'dart:io';

import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_downloader.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader.dart';

class LogoDownloaderServiceImpl implements LogoDownloaderService {
  final FileDownloader _fileDownloader;

  LogoDownloaderServiceImpl(
    loggerService,
    apiHelper,
  ) : _fileDownloader = FileDownloader(
          loggerService,
          apiHelper,
          basePath: '${ApiPaths.gitRepository}/main',
        );

  @override
  Future<File?> downloadFile(String fileName) async {
    return _fileDownloader.downloadFile(fileName);
  }

  @override
  Future<List<File>?> downloadFiles({required List<String> fileNames}) {
    return _fileDownloader.downloadFiles(fileNames);
  }
}

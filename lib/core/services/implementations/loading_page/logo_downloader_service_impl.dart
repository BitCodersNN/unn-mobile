// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/services/implementations/git/git_image_downloader_base.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader_service.dart';

class LogoDownloaderServiceImpl extends GitImageDownloaderBase
    implements LogoDownloaderService {
  LogoDownloaderServiceImpl(super.logger, super.apiHelper);

  @override
  GitPath get gitPath => GitPath.loadingScreen;

  @override
  String? resolveDownloadFolder(List<String> segments) {
    if (segments.length < 2 || segments.first != 'logos') {
      return null;
    }
    return segments.take(segments.length - 1).join('/');
  }

  @override
  Future<File?> downloadFile(String fileName, {required String revision}) =>
      downloadAndValidateFile(fileName, revision: revision);

  @override
  Future<List<File>?> downloadFiles({
    required List<String> fileNames,
    required String revision,
  }) => downloadAllFiles(fileNames: fileNames, revision: revision);
}

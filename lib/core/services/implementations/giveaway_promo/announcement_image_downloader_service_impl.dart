// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/services/implementations/git/git_image_downloader_base.dart';
import 'package:unn_mobile/core/services/interfaces/giveaway_promo/announcement_image_downloader_service.dart';

class AnnouncementImageDownloaderServiceImpl extends GitImageDownloaderBase
    implements AnnouncementImageDownloaderService {
  AnnouncementImageDownloaderServiceImpl(super.logger, super.apiHelper);

  @override
  GitPath get gitPath => GitPath.announcements;

  @override
  String? resolveDownloadFolder(List<String> segments) => [
    GitPath.announcements.directory,
    ...segments.take(segments.length - 1),
  ].join('/');

  @override
  Future<File?> getCachedFile(String fileName) =>
      getValidatedCachedFile(fileName);

  @override
  Future<File?> downloadFile(String fileName, {required String revision}) =>
      downloadAndValidateFile(fileName, revision: revision);

  @override
  Future<List<File>?> downloadFiles({
    required List<String> fileNames,
    required String revision,
  }) => downloadAllFiles(fileNames: fileNames, revision: revision);
}

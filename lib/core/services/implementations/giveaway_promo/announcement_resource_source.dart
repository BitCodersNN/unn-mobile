// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_catalog.dart';
import 'package:unn_mobile/core/services/interfaces/git/git_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/git/git_resource_source.dart';
import 'package:unn_mobile/core/services/interfaces/giveaway_promo/announcement_image_downloader_service.dart';

class AnnouncementResourceSource
    implements GitResourceSource<AnnouncementCatalog> {
  final GitConfigService _configService;
  final AnnouncementImageDownloaderService _imageDownloader;

  AnnouncementResourceSource(this._configService, this._imageDownloader);

  @override
  GitPath get path => GitPath.announcements;

  @override
  Future<AnnouncementCatalog?> load({required String revision}) async {
    final results = await Future.wait([
      _configService.getConfig(
        path: '${path.directory}/${AnnouncementCategory.giveaway.fileName}',
        revision: revision,
      ),
      _configService.getConfig(
        path: '${path.directory}/${AnnouncementCategory.ad.fileName}',
        revision: revision,
      ),
      _configService.getConfig(
        path: '${path.directory}/${AnnouncementCategory.update.fileName}',
        revision: revision,
      ),
    ]);
    if (results.every((result) => result == null)) {
      return null;
    }
    final catalog = AnnouncementCatalog.fromCategoryFiles(
      giveawaysJson: results[0],
      adsJson: results[1],
      updatesJson: results[2],
    );
    if (catalog.imagePaths.isNotEmpty) {
      await _prepareImages(catalog, revision);
    }
    return catalog;
  }

  Future<void> _prepareImages(
    AnnouncementCatalog catalog,
    String revision,
  ) async {
    final files = await _imageDownloader.downloadFiles(
      fileNames: catalog.imagePaths.toList(),
      revision: revision,
    );
    if (files == null) {
      throw StateError('Failed to download announcement images');
    }
  }
}

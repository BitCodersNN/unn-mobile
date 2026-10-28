// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/models/loading_page/loading_page_catalog.dart';
import 'package:unn_mobile/core/services/implementations/git/git_json_resource_source.dart';
import 'package:unn_mobile/core/services/interfaces/git/git_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/git/git_resource_source.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader_service.dart';

class LoadingPageResourceSource
    implements GitResourceSource<LoadingPageCatalog> {
  final GitJsonResourceSource<LoadingPageCatalog> _source;
  final LogoDownloaderService _logos;

  LoadingPageResourceSource(
    GitConfigService configService,
    this._logos,
  ) : _source = GitJsonResourceSource(
          configService,
          LoadingPageCatalog.fromJson,
          path: GitPath.loadingScreen,
        );

  @override
  GitPath get path => _source.path;

  @override
  Future<LoadingPageCatalog?> load({required String revision}) async {
    final pages = await _source.load(revision: revision);
    if (pages == null) {
      return null;
    }
    await _prepareLogos(pages, revision);
    return pages;
  }

  Future<void> _prepareLogos(
    LoadingPageCatalog pages,
    String revision,
  ) async {
    final files = await _logos.downloadFiles(
      fileNames: pages.pages.map((page) => page.imagePath).toSet().toList(),
      revision: revision,
    );
    if (files == null) {
      throw StateError('Loading page logos could not be prepared');
    }
  }
}

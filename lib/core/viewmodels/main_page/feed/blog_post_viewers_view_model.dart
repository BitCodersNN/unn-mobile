// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post_viewer.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_viewers_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class BlogPostViewersViewModel extends BaseViewModel {
  final BlogPostViewersService _service;
  final int postId;
  final int? totalCount;
  final Map<Object, BlogPostViewer> _viewers = {};
  int _nextPage = 1;
  bool _hasMore = true;
  bool _hasError = false;

  BlogPostViewersViewModel(this._service, this.postId, {this.totalCount});

  List<BlogPostViewer> get viewers => List.unmodifiable(_viewers.values);
  bool get hasMore => _hasMore;
  bool get hasError => _hasError;

  Future<void> loadNextPage() async {
    if (disposed || isBusy || !_hasMore) {
      return;
    }
    await busyCallAsync(_loadPage);
  }

  Future<void> _loadPage() async {
    _hasError = false;
    final page = await _service.getViewers(
      postId: postId,
      pageNumber: _nextPage,
    );
    if (disposed) {
      return;
    }
    _hasError = page == null;
    if (page == null) {
      return;
    }
    final previousCount = _viewers.length;
    for (final viewer in page) {
      final Object key =
          viewer.bitrixId ??
          (viewer.fullname, viewer.photoSrc, viewer.viewedAt);
      final previous = _viewers[key];
      if (previous == null || previous.viewedAt.isBefore(viewer.viewedAt)) {
        _viewers[key] = viewer;
      }
    }
    _hasMore =
        page.isNotEmpty &&
        _viewers.length > previousCount &&
        (totalCount == null || _viewers.length < totalCount!);
    _nextPage++;
  }
}

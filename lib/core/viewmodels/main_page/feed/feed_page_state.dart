// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';

class FeedPageState {
  final List<FeedPostViewModel> posts = [];
  final List<FeedPostViewModel> offlinePosts = [];
  final List<FeedPostViewModel> pinnedPosts = [];

  int pageNumber = 0;
  int unreadCount = 0;
  bool failedToLoad = false;
  bool isLoaded = false;
}

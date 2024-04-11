import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';

abstract interface class FeedUpdaterService with ChangeNotifier {
  List<PostWithLoadedInfo> get feedPosts;
  Future<void> updateFeed();
  Future<bool> checkForUpdates();
  Future<void> loadNextPage();
  bool get isBusy;
  int get lastLoadedPage;
  DateTime get lastViewedPostDateTime;
}

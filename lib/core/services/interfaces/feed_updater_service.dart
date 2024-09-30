import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/blog_data.dart';

abstract interface class FeedUpdaterService with ChangeNotifier {
  List<BlogData> get feedPosts;
  Future<void> updateFeed();
  Future<void> loadNextPage();
  int get lastLoadedPage;
}

part of '../library.dart';

abstract interface class FeedUpdaterService with ChangeNotifier {
  List<BlogData> get feedPosts;
  Future<void> updateFeed();
  Future<void> loadNextPage();
  int get lastLoadedPage;
}

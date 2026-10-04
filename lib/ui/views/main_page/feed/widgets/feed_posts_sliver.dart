import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_section_header.dart';

class FeedPostsSliver extends StatelessWidget {
  final List<FeedPostViewModel> posts;
  final String? title;
  final bool showCount;

  const FeedPostsSliver({
    required this.posts,
    this.title,
    this.showCount = false,
    super.key,
  });

  Widget _section(String title, List<FeedPostViewModel> items) =>
      SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: FeedSectionHeader(
              title: title,
              count: showCount ? items.length : null,
            ),
          ),
          SliverList.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => FeedPost(
              key: ObjectKey(items[index]),
              post: items[index],
              showingComments: false,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return _section(title!, posts);
    }
    final unread = posts.where((post) => post.isNewPost).toList();
    final read = posts.where((post) => !post.isNewPost).toList();
    return SliverMainAxisGroup(
      slivers: [
        if (unread.isNotEmpty) _section('Новые посты', unread),
        if (read.isNotEmpty) _section('Прочитанные посты', read),
      ],
    );
  }
}

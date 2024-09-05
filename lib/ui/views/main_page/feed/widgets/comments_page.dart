import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_comment.dart';

class CommentsPage extends StatelessWidget {
  final PostWithLoadedInfo post;
  final FeedScreenViewModel feedViewModel;

  const CommentsPage({
    super.key,
    required this.post,
    required this.feedViewModel,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись'),
      ),
      body: BaseView<CommentsPageViewModel>(
        builder: (context, model, child) {
          return RefreshIndicator(
            onRefresh: () => model.refresh(),
            child: NotificationListener<ScrollEndNotification>(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ListenableBuilder(
                      listenable: feedViewModel,
                      builder: (context, child) => FeedScreenViewState.feedPost(
                        context,
                        post,
                        feedViewModel,
                        showingComments: true,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 0),
                      child: Text(
                        'КОММЕНТАРИИ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 152, 158, 169),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final comment in model.comments)
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 18,
                              bottom: 10,
                              right: 18,
                            ),
                            child: Divider(
                              thickness: 0.3,
                              color: Color.fromARGB(255, 152, 158, 169),
                            ),
                          ),
                          FeedCommentView(comment: comment),
                        ],
                      ),
                    if (model.isLoadingComments)
                      const SizedBox(
                        height: 36.0,
                        child: CircularProgressIndicator.adaptive(),
                      ),
                  ],
                ),
              ),
              onNotification: (scrollEnd) {
                final metrics = scrollEnd.metrics;
                if (metrics.atEdge) {
                  final bool isTop = metrics.pixels == 0;
                  if (!isTop) {
                    model.loadMoreComments();
                  }
                }
                return false;
              },
            ),
          );
        },
        onModelReady: (p0) => p0.init(post.post),
      ),
    );
  }
}

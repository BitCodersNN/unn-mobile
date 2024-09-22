import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_comment.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final post = GoRouterState.of(context).extra! as FeedPostViewModel;
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
                    FeedPost(
                      post: post,
                      showingComments: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 0),
                      child: Text(
                        model.commentsCount > 0
                            ? 'КОММЕНТАРИИ'
                            : 'НЕТ КОММЕНТАРИЕВ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 152, 158, 169),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final comment in model.commentViewmodels)
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
                              color: Color(0xFF989EA9),
                            ),
                          ),
                          FeedCommentView(
                            viewModel: comment,
                          ),
                        ],
                      ),
                    if (model.isLoadingComments && model.commentsCount > 0)
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
                  if (!isTop && model.commentsCount > 0) {
                    model.loadMoreComments();
                  }
                }
                return false;
              },
            ),
          );
        },
        onModelReady: (p0) => p0.init(post),
      ),
    );
  }
}

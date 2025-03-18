import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_comment.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';

class CommentsPage extends StatelessWidget {
  final int postId;
  const CommentsPage({
    super.key,
    required this.postId,
  });
  @override
  Widget build(BuildContext context) {
    final post = FeedPostViewModel.cached(postId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись'),
      ),
      body: BaseView<FeedPostViewModel>(
        builder: (context, model, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () => model.refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        FeedPost(
                          post: post,
                          showingComments: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            model.commentsCount > 0
                                ? 'КОММЕНТАРИИ'
                                : 'НЕТ КОММЕНТАРИЕВ',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF989EA9),
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
                                  color: Color(0xFF989EA9),
                                ),
                              ),
                              FeedCommentView(
                                viewModel: comment,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        model: post,
      ),
    );
  }
}

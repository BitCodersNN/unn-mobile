// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_comment.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';

class CommentsPage extends StatelessWidget {
  final int postId;
  const CommentsPage({
    required this.postId,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final post = FeedPostViewModel.cached(postId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись'),
      ),
      body: BaseView<FeedPostViewModel>(
        builder: (context, model, child) => LayoutBuilder(
          builder: (context, constraints) {
            final theme = Theme.of(context);
            final unnColors = theme.unnMobileColors;
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
                        isCollapsed: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          model.commentsCount > 0
                              ? 'КОММЕНТАРИИ'
                              : 'НЕТ КОММЕНТАРИЕВ',
                          style: TextStyle(
                            fontSize: 14,
                            color: unnColors?.ligtherTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            child: Divider(
                              height: 1,
                              thickness: 0.3,
                              color: unnColors?.ligtherTextColor,
                            ),
                          ),
                          for (final comment in model.comments)
                            FeedCommentView(viewModel: comment),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        model: post,
      ),
    );
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';

class PostsListPage extends StatelessWidget {
  const PostsListPage({
    super.key,
    required this.title,
    required this.viewModel,
    required this.postsList,
    required this.noPostsText,
  });

  final String title;
  final FeedScreenViewModel? viewModel;
  final List<FeedPostViewModel> postsList;
  final String noPostsText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: OnlineStatusBuilder(
        builder: (context, online) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () async {
                  if (online) {
                    await viewModel?.refreshFeatured();
                  }
                },
                child: Builder(
                  builder: (context) {
                    if (viewModel == null) {
                      return const Text('Что-то пошло не так');
                    }
                    if (postsList.isEmpty) {
                      final child = Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            noPostsText,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                            minHeight: constraints.maxHeight,
                          ),
                          child: child,
                        ),
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: postsList.length,
                      itemBuilder: (context, index) {
                        return FeedPost(
                          key: ObjectKey(postsList[index]),
                          post: postsList[index],
                          showingComments: false,
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

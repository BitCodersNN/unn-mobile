// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_comment.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_section_header.dart';

class CommentsPage extends StatefulWidget {
  final int postId;
  final bool scrollToComments;
  const CommentsPage({
    required this.postId,
    this.scrollToComments = false,
    super.key,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _commentsKey = GlobalKey();
  bool _commentsLoaded = false;

  @override
  void didUpdateWidget(CommentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _commentsLoaded = false;
    } else if (!oldWidget.scrollToComments &&
        widget.scrollToComments &&
        _commentsLoaded) {
      unawaited(_scrollToComments());
    }
  }

  Future<void> _loadComments(FeedPostViewModel model) async {
    final postId = widget.postId;
    await model.reloadComments();
    if (!mounted || widget.postId != postId) {
      return;
    }
    _commentsLoaded = true;
    if (widget.scrollToComments) {
      await _scrollToComments();
    }
  }

  Future<void> _scrollToComments() async {
    final postId = widget.postId;
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !widget.scrollToComments || widget.postId != postId) {
      return;
    }
    final target = _commentsKey.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = FeedPostViewModel.cached(widget.postId);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        title: const Text('Пост'),
        scrolledUnderElevation: 0,
      ),
      body: BaseView<FeedPostViewModel>(
        key: ValueKey(widget.postId),
        builder: (context, model, child) => LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator.adaptive(
            onRefresh: () async {
              triggerHaptic(HapticIntensity.light);
              await model.refresh(loadComments: true);
            },
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
                    FeedSectionHeader(
                      key: _commentsKey,
                      title: model.commentsCount > 0
                          ? 'Комментарии'
                          : 'Нет комментариев',
                      count:
                          model.commentsCount > 0 ? model.commentsCount : null,
                    ),
                    Column(
                      verticalDirection: AppSettings.reverseComments
                          ? VerticalDirection.up
                          : VerticalDirection.down,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (model.isBusy)
                          const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (model.hasMoreComments)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8.0,
                              left: 16.0,
                              right: 16.0,
                            ),
                            child: TextButton(
                              onPressed: () async {
                                triggerHaptic(HapticIntensity.light);
                                await model.loadMoreComments();
                              },
                              child: const Text('Предыдущие комментарии'),
                            ),
                          ),
                        for (final comment in model.comments)
                          FeedCommentView(viewModel: comment),
                        if (model.commentsError)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Не удалось загрузить комментарии',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
        model: post,
        onModelReady: (model) {
          unawaited(_loadComments(model));
        },
      ),
    );
  }
}

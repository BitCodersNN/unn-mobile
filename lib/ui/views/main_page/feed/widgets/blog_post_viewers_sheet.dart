// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/relative_date_time_formatter.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/models/feed/blog_post_viewer.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_viewers_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/blog_post_viewers_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/feed_navigation.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_metric_button.dart';
import 'package:unn_mobile/ui/widgets/app_modal_sheet.dart';
import 'package:unn_mobile/ui/widgets/empty_state_widget.dart';
import 'package:unn_mobile/ui/widgets/sheets/app_bottom_sheet.dart';

Future<void> showBlogPostViewers(
  BuildContext context, {
  required int postId,
  int? totalCount,
}) async {
  triggerHaptic(HapticIntensity.selection);
  final userId = await showAppBottomSheet<int>(
    context,
    heightFactor: 0.85,
    constraints: const BoxConstraints(maxWidth: 640),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    builder: (_) => BlogPostViewersSheet(
      postId: postId,
      totalCount: totalCount,
      service: Injector.appInstance.get<BlogPostViewersService>(),
    ),
  );
  if (userId != null && context.mounted) {
    await openFeedUserProfile(context, userId);
  }
}

class BlogPostViewersSheet extends StatefulWidget {
  final int postId;
  final int? totalCount;
  final BlogPostViewersService service;

  const BlogPostViewersSheet({
    required this.postId,
    required this.service,
    this.totalCount,
    super.key,
  });

  @override
  State<BlogPostViewersSheet> createState() => _BlogPostViewersSheetState();
}

class _BlogPostViewersSheetState extends State<BlogPostViewersSheet> {
  late final BlogPostViewersViewModel _model;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _model = BlogPostViewersViewModel(
      widget.service,
      widget.postId,
      totalCount: widget.totalCount,
    );
    _scrollController.addListener(_loadIfNeeded);
    unawaited(_model.loadNextPage());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    if (mounted &&
        !_model.hasError &&
        _scrollController.hasClients &&
        _scrollController.position.extentAfter < 240) {
      unawaited(_model.loadNextPage());
    }
  }

  @override
  Widget build(BuildContext context) => BaseView<BlogPostViewersViewModel>(
    model: _model,
    builder: (context, model, _) {
      final viewers = model.viewers;
      if (viewers.isNotEmpty &&
          model.hasMore &&
          !model.isBusy &&
          !model.hasError) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
      }
      return AppModalSheet(
        title: 'Просмотры',
        leading: widget.totalCount == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FeedMetricButton(
                  icon: Icons.visibility_outlined,
                  count: widget.totalCount,
                  label: 'Просмотры',
                  backgroundColor: Colors.transparent,
                ),
              ),
        child: _buildBody(context, model, viewers),
      );
    },
  );

  Widget _buildBody(
    BuildContext context,
    BlogPostViewersViewModel model,
    List<BlogPostViewer> viewers,
  ) {
    if (viewers.isEmpty) {
      if (model.isBusy) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }
      return EmptyStateWidget(
        icon: model.hasError
            ? Icons.cloud_off_rounded
            : Icons.visibility_outlined,
        title: model.hasError
            ? 'Не удалось загрузить просмотры'
            : 'Просмотров пока нет',
        caption: model.hasError
            ? 'Нажмите на значок, чтобы повторить'
            : 'Здесь появятся пользователи, просмотревшие пост',
        onIconTap: model.hasError
            ? () => unawaited(model.loadNextPage())
            : null,
      );
    }
    final colors = Theme.of(context).colorScheme;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: viewers.length + (model.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == viewers.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: model.isBusy
                ? const Center(child: CircularProgressIndicator.adaptive())
                : TextButton.icon(
                    onPressed: () => unawaited(model.loadNextPage()),
                    icon: Icon(
                      model.hasError
                          ? Icons.refresh_rounded
                          : Icons.expand_more_rounded,
                    ),
                    label: Text(
                      model.hasError ? 'Повторить загрузку' : 'Показать ещё',
                    ),
                  ),
          );
        }
        final viewer = viewers[index];
        return Material(
          key: ObjectKey(viewer),
          color: colors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: viewer.bitrixId == null
                ? null
                : () {
                    triggerHaptic(HapticIntensity.selection);
                    Navigator.of(context).pop(viewer.bitrixId);
                  },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _ViewerAvatar(viewer: viewer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewer.fullname ?? 'Пользователь',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatRelativeDateTime(viewer.viewedAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (viewer.bitrixId != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ViewerAvatar extends StatelessWidget {
  final BlogPostViewer viewer;

  const _ViewerAvatar({required this.viewer});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = Center(
      child: Text(
        generateInitials(viewer.fullname?.split(' ') ?? []),
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    final photo = viewer.photoSrc;
    return Container(
      width: 46,
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: photo == null || photo.isEmpty
          ? initials
          : CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => initials,
              errorWidget: (_, _, _) => initials,
            ),
    );
  }
}

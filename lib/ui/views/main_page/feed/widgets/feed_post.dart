// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:injector/injector.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/misc/html_utils/html_to_plain_text.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/reaction_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/anchored_reactions_window.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_action_style.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_author_header.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_item_context_menu.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/packed_post_images.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/text_html_widget.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_factory.dart';
import 'package:unn_mobile/ui/widgets/height_limiter.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';

class FeedPost extends StatefulWidget {
  final FeedPostViewModel post;
  final bool showingComments;
  final bool isCollapsed;

  const FeedPost({
    required this.post,
    required this.showingComments,
    super.key,
    this.isCollapsed = true,
  });

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  bool isCollapsed = true;
  final _previewKey = GlobalKey();

  void _collapse() {
    final source = _previewKey.currentContext?.findRenderObject();
    final scrollable = Scrollable.maybeOf(context);
    if (source != null && scrollable != null) {
      final viewport = RenderAbstractViewport.maybeOf(source);
      if (viewport != null) {
        final position = scrollable.position;
        final target = viewport.getOffsetToReveal(source, 0).offset.clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            );
        if (position.pixels > target) {
          position.jumpTo(target);
        }
      }
    }
    setState(() => isCollapsed = true);
  }

  @override
  void initState() {
    isCollapsed = widget.isCollapsed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BaseView<FeedPostViewModel>(
        model: widget.post,
        builder: (context, model, _) {
          final theme = Theme.of(context);
          return GestureDetector(
            onTap:
                widget.showingComments ? null : () => _openPost(context, model),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: FeedItemContextMenu(
                previewKey: _previewKey,
                reactions: model.reactionViewModel,
                actionsBuilder: (context) => createPostActions(
                  context: context,
                  model: model,
                  onShare: _sharePost,
                  includeReactions: false,
                ),
                child: Shimmer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: theme.colorScheme.surfaceContainerLowest,
                      gradient: model.isAnnouncement
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.alphaBlend(
                                  theme.colorScheme.error
                                      .withValues(alpha: 0.07),
                                  theme.colorScheme.surfaceContainerLowest,
                                ),
                                theme.colorScheme.surfaceContainerLowest,
                              ],
                            )
                          : null,
                      border: Border.all(
                        color: model.isAnnouncement
                            ? theme.colorScheme.error.withValues(alpha: 0.2)
                            : theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 6),
                          blurRadius: 20,
                          color: theme.shadowColor.withValues(alpha: 0.04),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: FeedAuthorHeader(
                                      dateTime: model.postTime == null
                                          ? ''
                                          : formatFeedPostTime(
                                              model.postTime!,
                                            ),
                                      canOpenProfile: true,
                                      viewModel: model.profileViewModel ??
                                          ProfileViewModel.empty(),
                                    ),
                                  ),
                                  if (model.isAnnouncement)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'ВАЖНО',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme.colorScheme.error,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    onPressed: model.togglePin,
                                    tooltip: model.isPinned
                                        ? 'Открепить пост'
                                        : 'Закрепить пост',
                                    icon: Icon(
                                      model.isPinned
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                      color: model.isPinned
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              if (isCollapsed)
                                HeightLimiter(
                                  maxHeight: 240,
                                  fadeEffectHeight: 40,
                                  overflowIndicatorOutside: true,
                                  overflowIndicatorBuilder: (context) =>
                                      Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: _PostExpansionButton(
                                      onPressed: () =>
                                          setState(() => isCollapsed = false),
                                      label: 'РАЗВЕРНУТЬ',
                                    ),
                                  ),
                                  child: _buildPostContent(model),
                                )
                              else
                                _buildPostContent(model),
                              if (!isCollapsed && widget.isCollapsed)
                                _PostExpansionButton(
                                  onPressed: _collapse,
                                  label: 'СКРЫТЬ',
                                ),
                              if (model.attachedImages.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: PackedPostImages(
                                    attachedImages: model.attachedImages,
                                    authorizationHeaders: model.authHeaders,
                                  ),
                                ),
                              if (model.isAnnouncement)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 12,
                                    bottom: model.attachedFileViewModels.isEmpty
                                        ? 4
                                        : 0,
                                  ),
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: model.isAnnouncementRead
                                        ? null
                                        : model.markReadIfImportant,
                                    child: Text(
                                      model.isAnnouncementRead
                                          ? 'Сообщение прочитано'
                                          : 'Прочитать',
                                    ),
                                  ),
                                )
                              else if (model.attachedFileViewModels.isEmpty)
                                const SizedBox(height: 16.0),
                              AttachedFiles(
                                files: model.attachedFileViewModels,
                                useCardStyle: true,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 4,
                                  right: 4,
                                  top: model.attachedFileViewModels.isEmpty
                                      ? 10
                                      : 0,
                                ),
                                child: Divider(
                                  height: model.attachedFileViewModels.isEmpty
                                      ? null
                                      : 1,
                                  thickness: 0.4,
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12.0,
                                children: [
                                  _ReactionButton(
                                    model.reactionViewModel ??
                                        ReactionViewModel.empty(),
                                    showCounter: true,
                                  ),
                                  InkWell(
                                    onTap: widget.showingComments
                                        ? null
                                        : () => _openPost(
                                              context,
                                              model,
                                              scrollToComments: true,
                                            ),
                                    borderRadius: feedActionBorderRadius,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ).copyWith(right: 8),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.surfaceContainerLow,
                                        borderRadius: feedActionBorderRadius,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            color: theme.colorScheme
                                                .onSecondaryContainer,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${model.commentsCount}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  IconButton(
                                    onPressed: () async {
                                      await _sharePost(model);
                                    },
                                    tooltip: 'Поделиться постом',
                                    icon: Icon(
                                      theme.platform == TargetPlatform.iOS
                                          ? Icons.ios_share_rounded
                                          : Icons.share_outlined,
                                      size: 20,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        onModelReady: (p0) => p0.onError.subscribe(_onPostRefreshError),
        onDispose: (p0) => p0.onError.unsubscribe(_onPostRefreshError),
      );

  void _openPost(
    BuildContext context,
    FeedPostViewModel model, {
    bool scrollToComments = false,
  }) {
    if (model.blogData == null) {
      return;
    }
    Injector.appInstance
        .get<FeedPostViewModelFactory>()
        .putInCache(model.blogData!.id, model);
    final router = GoRouter.of(context);
    final location = Uri(
      path: '${router.routeInformationProvider.value.uri.path}/'
          '${postCommentsRoute.pagePath.replaceAll(':postId', model.blogData!.id.toString())}',
      fragment: scrollToComments ? 'comments' : null,
    );
    router.go(location.toString());
  }

  Future<void> _sharePost(FeedPostViewModel model) async {
    if (model.profileViewModel == null) {
      return;
    }
    final List<XFile> xFiles = [];

    for (final fileViewModel in model.attachedFileViewModels) {
      final file = await fileViewModel.getFile();
      if (file?.existsSync() ?? false) {
        xFiles.add(XFile(file!.path));
      }
    }

    final fetchedImages = await Future.wait(
      model.attachedImages.map(
        (url) => _imageUrlToXFile(url).onError((_, __) => null),
      ),
    );
    xFiles.addAll(fetchedImages.whereType<XFile>());

    await SharePlus.instance.share(
      ShareParams(
        files: xFiles.isEmpty ? null : xFiles,
        text:
            '${htmlToPlainText(model.postText)}\n\nИсточник: Портал ННГУ\nАвтор: ${model.profileViewModel!.fullname}',
      ),
    );
  }

  Future<XFile?> _imageUrlToXFile(String imageUrl) async {
    final data = await http.get(Uri.parse(imageUrl));
    final mimeType =
        data.headers['Content-Type'] ?? lookupMimeType(p.basename(imageUrl));
    if (data.statusCode != 200) {
      return null;
    }
    return XFile.fromData(
      data.bodyBytes,
      mimeType: mimeType,
    );
  }

  void _onPostRefreshError(EventArgs e) {
    const snackBar = SnackBar(
      content: Text('Не удалось обновить пост'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildPostContent(FeedPostViewModel model) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextHtmlWidget(
            text: model.postText,
            headers: model.authHeaders,
          ),
        ],
      );
}

class _PostExpansionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PostExpansionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onPressed, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ],
      );
}

class _ReactionButton extends StatelessWidget {
  final ReactionViewModel viewModel;
  final bool showCounter;

  const _ReactionButton(this.viewModel, {required this.showCounter});

  @override
  Widget build(BuildContext context) => BaseView<ReactionViewModel>(
        model: viewModel,
        builder: (context, viewModel, _) => GestureDetector(
          onTap: () {
            triggerHaptic(HapticIntensity.selection);
            viewModel.toggleLike();
          },
          onLongPress: () {
            showAnchoredReactionChoice(context, viewModel);
          },
          child: _reactionButton(
            context,
            viewModel,
            showCounter,
          ),
        ),
      );

  static Widget _reactionButton(
    BuildContext context,
    ReactionViewModel model,
    bool showCounter,
  ) {
    final theme = Theme.of(context);
    final buttonColor = theme.colorScheme.onSurfaceVariant;
    final reactionToPost = model.currentReaction;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: feedReactionBackgroundColor(
          theme.colorScheme,
          isSelected: reactionToPost != null,
        ),
        borderRadius: feedActionBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          reactionToPost == null
              ? Icon(
                  Icons.favorite_border_rounded,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                )
              : getReactionImage(reactionToPost),
          const SizedBox(width: 6),
          Text(
            '${showCounter ? model.reactionCount : reactionToPost?.caption ?? ReactionType.like.caption}',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: buttonColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget getReactionImage(ReactionType? reaction) {
    const width = 23.0;
    const height = 23.0;
    if (reaction == null) {
      return Image.asset(
        'assets/images/reactions/default_like.png',
        width: width,
        height: height,
      );
    } else {
      return Image.asset(
        reaction.assetName,
        width: width,
        height: height,
      );
    }
  }
}

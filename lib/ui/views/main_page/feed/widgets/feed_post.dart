// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/reaction_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/reactions_window.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/packed_post_images.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/post_html_widget.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/height_limiter.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

const idkWhatColor = Color(0xFF989EA9);

class FeedPost extends StatefulWidget {
  final FeedPostViewModel post;
  final bool showingComments;
  final bool isCollapsed;

  const FeedPost({
    super.key,
    required this.post,
    required this.showingComments,
    this.isCollapsed = true,
  });

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  bool isCollapsed = true;
  @override
  void initState() {
    isCollapsed = widget.isCollapsed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    theme.extension<UnnMobileColors>();
    final reactionsSize = MediaQuery.textScalerOf(context).scale(18.0);
    return BaseView<FeedPostViewModel>(
      model: widget.post,
      builder: (context, model, _) {
        return GestureDetector(
          onTap: () {
            if (widget.showingComments) {
              return;
            }
            Injector.appInstance
                .get<FeedPostViewModelFactory>()
                .putInCache(model.blogData.id, model);
            _openPostCommentsPage(context, model);
          },
          child: Shimmer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: _getPostColor(context, model),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 0),
                    blurRadius: 9,
                    color: Color(0x33527DAF),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (model.isAnnouncement)
                    Container(
                      decoration: const BoxDecoration(color: Color(0x33000000)),
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      child: const Text('Важное сообщение'),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PostHeader(
                                postTime: model.postTime,
                                viewModel: model.profileViewModel,
                              ),
                            ),
                            IconButton(
                              onPressed: model.togglePin,
                              icon: Icon(
                                model.isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        if (isCollapsed)
                          HeightLimiter(
                            maxHeight: 240,
                            fadeEffectHeight: 40,
                            child: _buildPostContent(model),
                            overflowIndicatorBuilder: (context) {
                              return Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      _getPostColor(context, model)
                                          .withAlpha(255),
                                      _getPostColor(context, model)
                                          .withAlpha(0),
                                    ],
                                    stops: const [
                                      0.2,
                                      1.0,
                                    ],
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Expanded(child: Divider()),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            isCollapsed = false;
                                          });
                                        },
                                        child: const Text('Развернуть'),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          _buildPostContent(model),
                        if (model.isAnnouncement)
                          FilledButton(
                            onPressed: model.markReadIfImportant,
                            child: const Text('Отметить прочитанным'),
                          )
                        else
                          const SizedBox(height: 16.0),
                        for (final file in model.attachedFileViewModels)
                          AttachedFile(viewModel: file),
                        if (!widget.showingComments)
                          const Padding(
                            padding:
                                EdgeInsets.only(left: 4, right: 4, top: 10),
                            child: Divider(
                              thickness: 0.4,
                              color: idkWhatColor,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (widget.showingComments)
                          Row(
                            children: [
                              _ReactionCounterWithIcons(
                                model: model.reactionViewModel,
                                reactionsSize: reactionsSize,
                                background: idkWhatColor,
                              ),
                            ],
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 12.0,
                          children: [
                            _ReactionButton(
                              model.reactionViewModel,
                              !widget.showingComments,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ).copyWith(right: 8),
                              decoration: BoxDecoration(
                                color: idkWhatColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    color: idkWhatColor,
                                    size: 23,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${model.commentsCount}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: idkWhatColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: Container()),
                            IconButton(
                              onPressed: () async {
                                await _sharePost(model);
                              },
                              icon: const Icon(Icons.share),
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
        );
      },
      onModelReady: (p0) => p0.onError.subscribe(_onPostRefreshError),
      onDispose: (p0) => p0.onError.unsubscribe(_onPostRefreshError),
    );
  }

  static void _openPostCommentsPage(
    BuildContext context,
    FeedPostViewModel post,
  ) async {
    GoRouter.of(context).go(
      '${GoRouter.of(context).routeInformationProvider.value.uri.path}/'
      '${postCommentsRoute.pageRoute.replaceAll(':postId', post.blogData.id.toString())}',
    );
  }

  Future<void> _sharePost(FeedPostViewModel model) async {
    final List<XFile> xFiles = [];

    for (final fileViewModel in model.attachedFileViewModels) {
      final file = await fileViewModel.getFile();
      if (file?.existsSync() == true) {
        xFiles.add(XFile(file!.path));
      }
    }

final fetchedImages = await Future.wait(
      model.attachedImages.map(
        (url) => _imageUrlToXFile(url).onError((_, __) => null),
      ),
    );
    xFiles.addAll(fetchedImages.whereType<XFile>());

    final htmlDoc = parse(
      HtmlUnescape().convert(model.postText),
    );
    final parsedString = parse(htmlDoc.body?.text).documentElement?.text;
    await SharePlus.instance.share(
      ShareParams(
        files: xFiles.isEmpty ? null : xFiles,
        text:
            "Из ленты Портала ННГУ (автор ${model.profileViewModel.fullname}):\n${parsedString ?? ''}",
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

  Color _getPostColor(BuildContext context, FeedPostViewModel model) {
    final theme = Theme.of(context);
    final unnMobileColors = theme.extension<UnnMobileColors>()!;
    if (model.isAnnouncement) {
      return unnMobileColors.importantPostHighlight!;
    }
    return theme.colorScheme.surface;
  }

  void _onPostRefreshError(EventArgs e) {
    const snackBar = SnackBar(
      content: Text('Не удалось обновить пост'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildPostContent(FeedPostViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHtmlWidget(text: model.postText),
        PackedPostImages(attachedImages: model.attachedImages),
      ],
    );
  }
}

class _PostHeader extends StatelessWidget {
  final DateTime postTime;

  final ProfileViewModel viewModel;

  const _PostHeader({
    required this.postTime,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseView<ProfileViewModel>(
      model: viewModel,
      builder: (context, model, _) {
        return Row(
          children: [
            SizedBox(
              width: 45,
              height: 45,
              child: ShimmerLoading(
                isLoading: model.isLoading,
                child: CircleAvatar(
                  backgroundImage: model.hasAvatar
                      ? CachedNetworkImageProvider(model.avatarUrl!)
                      : null,
                  child: model.hasAvatar
                      ? null
                      : Text(
                          style: theme.textTheme.headlineSmall!.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          model.initials,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(
                    isLoading: model.isLoading,
                    child: model.isLoading
                        ? Container(
                            width: double.infinity,
                            height: MediaQuery.of(context)
                                .textScaler
                                .clamp(maxScaleFactor: 1.5)
                                .scale(16),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          )
                        : Text(
                            model.fullname,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A63B7),
                            ),
                          ),
                  ),
                  Text(
                    DateFormat('d MMMM yyyy, HH:mm', 'ru_RU').format(postTime),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6A6F7A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReactionCounterWithIcons extends StatelessWidget {
  const _ReactionCounterWithIcons({
    required this.model,
    required this.reactionsSize,
    required this.background,
  });

  final ReactionViewModel model;
  final double reactionsSize;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return BaseView<ReactionViewModel>(
      model: model,
      builder: (context, model, _) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.only(
              top: 6,
              bottom: 6,
              right: 8,
              left: 12,
            ),
            child: Builder(
              builder: (context) {
                final reactionTypeCount = model.reactionList.length - 1;
                final reactionCounterOffset =
                    reactionsSize * (reactionTypeCount) / 2 + reactionsSize + 8;
                return SizedBox(
                  height: reactionsSize,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      for (final (i, smallReactionEntry)
                          in model.reactionList.indexed)
                        Positioned(
                          left: reactionsSize / 2 * i,
                          child: ClipOval(
                            child: Container(
                              width: reactionsSize,
                              height: reactionsSize,
                              color: const Color(0x69c6d9f9),
                              child: Image.asset(
                                smallReactionEntry.assetName,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      if (model.reactionCount > 0)
                        Positioned(
                          left: reactionCounterOffset,
                          child: Text(
                            '${model.reactionCount}',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: background,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final ReactionViewModel viewModel;
  final bool showCounter;

  const _ReactionButton(this.viewModel, this.showCounter);

  @override
  Widget build(BuildContext context) {
    return BaseView<ReactionViewModel>(
      model: viewModel,
      builder: (context, viewModel, _) {
        return GestureDetector(
          onTap: () {
            triggerHaptic(HapticIntensity.selection);
            viewModel.toggleLike();
          },
          onLongPress: () {
            triggerHaptic(HapticIntensity.medium);
            showReactionChoicePanel(context, viewModel);
          },
          child: _reactionButton(
            context,
            viewModel,
            showCounter,
          ),
        );
      },
    );
  }

  static Widget _reactionButton(
    BuildContext context,
    ReactionViewModel model,
    bool showCounter,
  ) {
    final theme = Theme.of(context);
    const buttonColor = idkWhatColor;
    final reactionToPost = model.currentReaction;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.bounceOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: reactionToPost == null
            ? buttonColor.withValues(alpha: 0.1)
            : theme.colorScheme.inversePrimary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          getReactionImage(reactionToPost),
          const SizedBox(width: 6),
          Text(
            '${showCounter ? (model.reactionCount > 0 ? model.reactionCount : '') : reactionToPost?.caption ?? ReactionType.like.caption}',
            style: const TextStyle(
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

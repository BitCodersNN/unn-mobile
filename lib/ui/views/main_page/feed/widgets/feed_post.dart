// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:event/event.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/html_utils/html_widget_callbacks.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/reaction_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/reactions_window.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/packed_images_view.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

const idkWhatColor = Color(0xFF989EA9);

class FeedPost extends StatefulWidget {
  final FeedPostViewModel post;
  final bool showingComments;

  const FeedPost({
    super.key,
    required this.post,
    required this.showingComments,
  });

  @override
  State<FeedPost> createState() => _FeedPostState();

  static Widget htmlWidget(String text, BuildContext context) {
    return HtmlWidget(
      text,
      onTapUrl: htmlWidgetOnTapUrl,
      onTapImage: (imageMetadata) async {
        await showDialog(
          context: context,
          builder: (context) {
            return ExtendedImageSlidePage(
              slideAxis: SlideAxis.vertical,
              child: ExtendedImage(
                enableLoadState: true,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 3.0,
                    animationMaxScale: 3.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false,
                    initialAlignment: InitialAlignment.center,
                  );
                },
                image: CachedNetworkImageProvider(
                  imageMetadata.sources.first.url,
                ),
                enableSlideOutPage: true,
              ),
            );
          },
        );
      },
    );
  }

  static Widget _reactionCounterWithIcons(
    ReactionViewModel model,
    double reactionsSize,
    Color background,
  ) {
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
                int i = 0;
                return SizedBox(
                  height: reactionsSize,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      for (final smallReactionEntry in model.reactionList)
                        Positioned(
                          left: reactionsSize / 2 * i++,
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
                      Positioned(
                        left: reactionsSize * (i - 1) / 2 + reactionsSize + 8,
                        child: Text(
                          '${model.reactionCount > 0 ? model.reactionCount : ''}',
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

  static void _openPostCommentsPage(
    BuildContext context,
    FeedPostViewModel post,
  ) async {
    GoRouter.of(context).go(
      '${GoRouter.of(context).routeInformationProvider.value.uri.path}/'
      '${postCommentsRoute.pageRoute.replaceAll(':postId', post.blogData.id.toString())}',
    );
  }
}

class _FeedPostState extends State<FeedPost> {
  @override
  void initState() {
    super.initState();
  }

  void onPostRefreshError(EventArgs e) {
    const snackBar = SnackBar(
      content: Text('Не удалось обновить пост'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            FeedPost._openPostCommentsPage(context, model);
          },
          child: Shimmer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: getPostColor(context, model),
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
                        FeedPost.htmlWidget(model.postText, context),
                        PackedImagesView(
                          onChildTap: (index) async {
                            OverlayEntry createOverlay(int index) =>
                                OverlayEntry(
                                  builder: (context) {
                                    return SafeArea(
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              '${index + 1} из ${model.attachedImages.length}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );

                            var overlay = createOverlay(index);
                            await showDialog(
                              context: context,
                              builder: (context) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Overlay.of(context, rootOverlay: true)
                                      .insert(overlay);
                                });

                                return ExtendedImageSlidePage(
                                  slideAxis: SlideAxis.vertical,
                                  child: ImagesCarousel(
                                    viewModel: model,
                                    imageModel: index,
                                    onPageChanged: (index) {
                                      overlay.remove();
                                      overlay = createOverlay(index);
                                      Overlay.of(context).insert(overlay);
                                    },
                                  ),
                                );
                              },
                            );
                            overlay.remove();
                          },
                          children: model.attachedImages
                              .map(
                                (e) => CachedNetworkImage(
                                  imageUrl: e,
                                ),
                              )
                              .toList(),
                        ),
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
                              FeedPost._reactionCounterWithIcons(
                                model.reactionViewModel,
                                reactionsSize,
                                idkWhatColor,
                              ),
                            ],
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _ReactionButton(
                              model.reactionViewModel,
                              !widget.showingComments,
                            ),
                            const SizedBox(width: 12),
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
      onModelReady: (p0) => p0.onError.subscribe(onPostRefreshError),
      onDispose: (p0) => p0.onError.unsubscribe(onPostRefreshError),
    );
  }

  Color? getPostColor(BuildContext context, FeedPostViewModel model) {
    final theme = Theme.of(context);
    final unnMobileColors = theme.extension<UnnMobileColors>()!;
    if (model.isAnnouncement) {
      return unnMobileColors.importantPostHighlight;
    }
    return theme.colorScheme.surface;
  }
}

class ImagesCarousel extends StatefulWidget {
  final FeedPostViewModel viewModel;
  final int imageModel;
  final void Function(int index)? onPageChanged;

  const ImagesCarousel({
    super.key,
    required this.viewModel,
    this.imageModel = 0,
    this.onPageChanged,
  });

  @override
  State<ImagesCarousel> createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<ImagesCarousel> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        scrollPhysics: const BouncingScrollPhysics(),
        enableInfiniteScroll: false,
        disableCenter: true,
        padEnds: true,
        viewportFraction: 1.0,
        initialPage: widget.imageModel,
        onPageChanged: (index, reason) => widget.onPageChanged?.call(index),
      ),
      items: [
        for (final image in widget.viewModel.attachedImages)
          ExtendedImage(
            enableLoadState: true,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (state) {
              return GestureConfig(
                minScale: 0.9,
                animationMinScale: 0.7,
                maxScale: 3.0,
                animationMaxScale: 3.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false,
                initialAlignment: InitialAlignment.center,
              );
            },
            image: CachedNetworkImageProvider(
              image,
            ),
            enableSlideOutPage: true,
          ),
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
            if (AppSettings.vibrationEnabled) {
              HapticFeedback.selectionClick();
            }
            viewModel.toggleLike();
          },
          onLongPress: () {
            if (AppSettings.vibrationEnabled) {
              HapticFeedback.mediumImpact();
            }
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

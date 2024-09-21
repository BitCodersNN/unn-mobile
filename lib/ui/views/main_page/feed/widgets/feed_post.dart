import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/factories/profile_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/reactions_window.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class FeedPost extends StatelessWidget {
  final BlogData post;

  final bool showingComments;

  const FeedPost({
    super.key,
    required this.post,
    required this.showingComments,
  });

  static const idkWhatColor = Color(0xFF989EA9);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    theme.extension<UnnMobileColors>();
    final reactionsSize = MediaQuery.textScalerOf(context).scale(18.0);
    return BaseView<FeedPostViewModel>(
      builder: (context, model, _) {
        return GestureDetector(
          onTap: () {
            if (showingComments) {
              return;
            }
            _openPostCommentsPage(context, post);
          },
          child: Shimmer(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: theme.colorScheme.surface,
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 0),
                    blurRadius: 9,
                    color: Color(0x33527DAF),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostHeader(
                    postTime: model.postTime,
                    authorId: model.authorId,
                  ),
                  const SizedBox(height: 16.0),
                  BBCodeText(
                    data: model.postText,
                    stylesheet: getBBStyleSheet(),
                    errorBuilder: (context, error, stack) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Failed to parse BBCode correctly. ',
                            style: TextStyle(color: Colors.red),
                          ),
                          const Text(
                            'This usually means on of the tags is not properly handling unexpected input.\n',
                          ),
                          const Text('Original text: '),
                          Text(model.postText.replaceAll('\n', '\n#')),
                          Text(error.toString()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  for (final file in model.files)
                    AttachedFile(
                      fileId: file,
                    ),
                  if (!showingComments)
                    const Padding(
                      padding: EdgeInsets.only(left: 4, right: 4, top: 10),
                      child: Divider(
                        thickness: 0.4,
                        color: idkWhatColor,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (showingComments)
                    Row(
                      children: [
                        _reactionCounterWithIcons(
                          model,
                          reactionsSize,
                          idkWhatColor,
                        ),
                      ],
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (AppSettings.vibrationEnabled) {
                            HapticFeedback.selectionClick();
                          }
                          model.toggleLike();
                        },
                        onLongPress: () {
                          if (AppSettings.vibrationEnabled) {
                            HapticFeedback.mediumImpact();
                          }
                          showReactionChoicePanel(context, model);
                        },
                        child: _reactionButton(
                          context,
                          model,
                          !showingComments,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          if (showingComments) {
                            return;
                          }
                          _openPostCommentsPage(context, post);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ).copyWith(right: 8),
                          decoration: BoxDecoration(
                            color: idkWhatColor.withOpacity(0.1),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onModelReady: (model) => model.init(post),
    );
  }

  static Widget _reactionButton(
    BuildContext context,
    FeedPostViewModel model,
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
            ? buttonColor.withOpacity(0.1)
            : theme.colorScheme.inversePrimary.withOpacity(0.5),
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

  static Expanded _reactionCounterWithIcons(
    FeedPostViewModel model,
    double reactionsSize,
    Color background,
  ) {
    final reactionList = model.loadedPost?.ratingList.ratingList.entries
            .where((entry) => entry.value.isNotEmpty) ??
        [];
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
                  for (final smallReactionEntry in reactionList)
                    Positioned(
                      left: reactionsSize / 2 * i++,
                      child: ClipOval(
                        child: Container(
                          width: reactionsSize,
                          height: reactionsSize,
                          color: const Color(0x69c6d9f9),
                          child: Image.asset(
                            smallReactionEntry.key.assetName,
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
  }

  static void _openPostCommentsPage(
    BuildContext context,
    BlogData post,
  ) async {
    GoRouter.of(context).go(
      '${MainPageRouting.navbarRoutes[0].pageRoute}/'
      '${MainPageRouting.navbarRoutes[0].subroutes[0].pageRoute}',
      extra: post,
    );
  }
}

class _PostHeader extends StatelessWidget {
  final DateTime postTime;
  final int authorId;
  const _PostHeader({
    required this.postTime,
    required this.authorId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseView<ProfileViewModel>(
      model: Injector.appInstance
          .get<ProfileViewModelFactory>()
          .getViewModel(authorId),
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
      onModelReady: (model) => model.init(loadFromPost: true, userId: authorId),
    );
  }
}

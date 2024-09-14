import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
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
    final extraColors = theme.extension<UnnMobileColors>();
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
                  Row(
                    children: [
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: ShimmerLoading(
                          isLoading: model.isBusy,
                          child: CircleAvatar(
                            backgroundImage: model.authorAvatar,
                            child: model.hasAvatar
                                ? null
                                : Text(
                                    style:
                                        theme.textTheme.headlineSmall!.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    getUserInitials(model.author),
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
                              isLoading: model.isBusy,
                              child: model.isBusy
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
                                      model.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A63B7),
                                      ),
                                    ),
                            ),
                            Text(
                              DateFormat('d MMMM yyyy, HH:mm', 'ru_RU').format(
                                model.postTime,
                              ),
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
                  if (model.isBusy)
                    for (var i = 0; i < model.filesCount; i++)
                      const AttachedFilePlaceholder()
                  else
                    for (final file in model.files)
                      AttachedFile(
                        fileData: file,
                        backgroundColor: extraColors?.defaultPostHighlight ??
                            Colors.transparent,
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
                          chooseReaction(context, model);
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

  static void chooseReaction(
    BuildContext context,
    FeedPostViewModel model,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выбор реакции',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Divider(
                  indent: 8,
                  endIndent: 8,
                  thickness: 0.5,
                  color: Color(0xE5A2A2A2),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final reaction in ReactionType.values)
                        _circleAvatarWithCaption(
                          reaction,
                          context,
                          model,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Widget _circleAvatarWithCaption(
    ReactionType reaction,
    BuildContext context,
    FeedPostViewModel model,
  ) {
    return GestureDetector(
      onTap: () {
        if (AppSettings.vibrationEnabled) {
          HapticFeedback.selectionClick();
        }
        model.toggleReaction(reaction);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage(reaction.assetName),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              reaction.caption,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
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
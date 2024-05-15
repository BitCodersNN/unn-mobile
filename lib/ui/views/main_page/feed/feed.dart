import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/comments_page.dart';

class FeedScreenView extends StatefulWidget {
  const FeedScreenView({Key? key}) : super(key: key);

  @override
  State<FeedScreenView> createState() => FeedScreenViewState();
}

class FeedScreenViewState extends State<FeedScreenView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<FeedScreenViewModel>(
      builder: (context, model, child) {
        return NotificationListener<ScrollEndNotification>(
          child: RefreshIndicator(
            onRefresh: model.updateFeed,
            child: ListView.builder(
              itemCount: model.posts.length + (model.isLoadingPosts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index > model.posts.length) {
                  return null;
                }
                if (index == model.posts.length) {
                  return const SizedBox(
                    height: 64,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return feedPost(
                  context,
                  model.posts[index],
                  model,
                  isNewPost: model.isNewPost(
                    model.posts[index].post.datePublish,
                  ),
                  showingComments: false,
                );
              },
            ),
          ),
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            if (metrics.atEdge) {
              final bool isTop = metrics.pixels == 0;
              if (!isTop) {
                model.loadNextPage();
              }
            }
            return true;
          },
        );
      },
      onModelReady: (model) => model.init(),
    );
  }

  static Widget _circleAvatarWithCaption(
    FeedScreenViewModel model,
    ReactionType reaction,
    BuildContext context,
    PostWithLoadedInfo post,
  ) {
    return GestureDetector(
      onTap: () {
        model.toggleReaction(post, reaction);
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

  static void chooseReaction(
    BuildContext context,
    FeedScreenViewModel model,
    PostWithLoadedInfo post,
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
                          model,
                          reaction,
                          context,
                          post,
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

  static String getReactionString(ReactionType? reaction) {
    if (reaction == null) {
      return ReactionType.like.caption;
    }
    return reaction.caption;
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

  static Widget feedPost(
    BuildContext context,
    PostWithLoadedInfo post,
    FeedScreenViewModel model, {
    bool isNewPost = false,
    bool showingComments = false,
  }) {
    final theme = Theme.of(context);
    final unescaper = HtmlUnescape();
    final extraColors = theme.extension<UnnMobileColors>();
    const idkWhatColor = Color(0xFF989EA9);
    final reactionsSize = MediaQuery.textScalerOf(context).scale(18.0);

    return GestureDetector(
      onTap: () {
        if (showingComments) {
          return;
        }
        _openPostCommentsPage(context, post, model);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isNewPost
              ? extraColors!.newPostHiglaght
              : extraColors!.defaultPostHighlight,
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
                  child: _circleAvatar(theme, post.author),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${post.author.fullname.lastname} ${post.author.fullname.name} ${post.author.fullname.surname}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A63B7),
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy, HH:mm', 'ru_RU').format(
                        post.post.datePublish.toLocal(),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF6A6F7A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            BBCodeText(
              data: unescaper.convert(post.post.detailText.trim()),
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
                    Text(post.post.detailText.replaceAll('\n', '\n#')),
                    Text(error.toString()),
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            for (final file in post.files)
              AttachedFile(
                fileData: file,
                backgroundColor: isNewPost
                    ? extraColors.newPostHiglaght
                    : extraColors.defaultPostHighlight,
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
                  _reactionCounterWithIcons(post, reactionsSize, idkWhatColor),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    model.toggleLike(post);
                  },
                  onLongPress: () {
                    chooseReaction(context, model, post);
                  },
                  child: _reactionButton(
                    model,
                    post,
                    idkWhatColor,
                    theme,
                    !showingComments,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    if (showingComments) {
                      return;
                    }
                    _openPostCommentsPage(context, post, model);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                            .copyWith(right: 8),
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
                          '${post.post.numberOfComments}',
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
    );
  }

  static AnimatedContainer _reactionButton(
    FeedScreenViewModel model,
    PostWithLoadedInfo post,
    Color buttonColor,
    ThemeData theme,
    bool showCounter,
  ) {
    final reactionToPost = model.getReactionToPost(post);
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
            '${showCounter ? (post.ratingList.getTotalNumberOfReactions() > 0 ? post.ratingList.getTotalNumberOfReactions() : '') : getReactionString(reactionToPost)}',
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

  static void _openPostCommentsPage(
    BuildContext context,
    PostWithLoadedInfo post,
    FeedScreenViewModel model,
  ) async {
    await Navigator.of(
      context.findRootAncestorStateOfType<NavigatorState>()!.context,
    ).push(
      MaterialPageRoute(
        builder: (context) {
          return CommentsPage(
            post: post,
            feedViewModel: model,
          );
        },
      ),
    );
  }

  static Expanded _reactionCounterWithIcons(
    PostWithLoadedInfo post,
    double reactionsSize,
    Color background,
  ) {
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
                  for (final smallReactionEntry in post
                      .ratingList.ratingList.entries
                      .where((entry) => entry.value.isNotEmpty))
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
                      '${post.ratingList.getTotalNumberOfReactions() > 0 ? post.ratingList.getTotalNumberOfReactions() : ""}',
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

  static CircleAvatar _circleAvatar(ThemeData theme, UserData? userData) {
    final userAvatar = getUserAvatar(userData);
    return CircleAvatar(
      backgroundImage: userAvatar,
      child: userAvatar == null
          ? Text(
              style: theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onBackground,
              ),
              getUserInitials(userData),
            )
          : null,
    );
  }
}

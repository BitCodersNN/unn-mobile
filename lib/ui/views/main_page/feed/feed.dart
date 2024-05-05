import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart' as custom_tags;
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/comments_page.dart';
import 'package:url_launcher/url_launcher.dart';

int currentReaction = 0;
Map<int, int> reactionsMap = {};

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({Key? key}) : super(key: key);

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
                  isNewPost: model.isNewPost(
                    model.posts[index].post.datePublish,
                  ),
                  showCommentsCount: true,
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

  Widget _circleAvatarWithCaption(
    int id,
    String imagePath,
    String caption,
    BuildContext context,
    PostWithLoadedInfo post,
  ) {
    return GestureDetector(
      onTap: () {
        currentReaction = id;
        reactionsMap[post.post.id] = currentReaction;
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
                  backgroundImage: AssetImage(imagePath),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void chooseReaction(BuildContext context, PostWithLoadedInfo post, flag) {
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
                  color: Color.fromARGB(229, 162, 162, 162),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleAvatarWithCaption(
                        1,
                        'assets/images/reactions/like.png',
                        'Нравится',
                        context,
                        post,
                      ),
                      _circleAvatarWithCaption(
                        2,
                        'assets/images/reactions/love.png',
                        'Восторг',
                        context,
                        post,
                      ),
                      _circleAvatarWithCaption(
                        3,
                        'assets/images/reactions/laugh.png',
                        'Смешно',
                        context,
                        post,
                      ),
                      _circleAvatarWithCaption(
                        4,
                        'assets/images/reactions/confused.png',
                        'Ого!',
                        context,
                        post,
                      ),
                      _circleAvatarWithCaption(
                        5,
                        'assets/images/reactions/facepalm.png',
                        'Facepalm',
                        context,
                        post,
                      ),
                      _circleAvatarWithCaption(
                        6,
                        'assets/images/reactions/sad.png',
                        'Печаль',
                        context,
                        post,
                      ),
                      _circleAvatarWithCaption(
                        7,
                        'assets/images/reactions/angry.png',
                        'Ъуъ!',
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

  Widget feedPost(
    BuildContext context,
    PostWithLoadedInfo post, {
    bool isNewPost = false,
    bool showCommentsCount = false,
    bool processClicks = true,
  }) {
    const int flag = 1;
    final model = FeedScreenViewModel();
    final theme = Theme.of(context);
    final unescaper = HtmlUnescape();
    final extraColors = theme.extension<UnnMobileColors>();
    const idkWhatColor = Color(0xFF989EA9);
    final reactionsSize = MediaQuery.textScalerOf(context).scale(16.0);

    Widget getReactionImage(int postId) {
      final reactionNumber = reactionsMap[postId];

      switch (reactionNumber) {
        case 1:
          return Image.asset(
            'assets/images/reactions/like.png',
            width: 23,
            height: 23,
          );
        case 2:
          return Image.asset(
            'assets/images/reactions/love.png',
            width: 23,
            height: 23,
          );
        case 3:
          return Image.asset(
            'assets/images/reactions/laugh.png',
            width: 23,
            height: 23,
          );
        case 4:
          return Image.asset(
            'assets/images/reactions/confused.png',
            width: 23,
            height: 23,
          );
        case 5:
          return Image.asset(
            'assets/images/reactions/facepalm.png',
            width: 23,
            height: 23,
          );
        case 6:
          return Image.asset(
            'assets/images/reactions/sad.png',
            width: 23,
            height: 23,
          );
        case 7:
          return Image.asset(
            'assets/images/reactions/angry.png',
            width: 23,
            height: 23,
          );
        case 0:
        default:
          return Image.asset(
            'assets/images/reactions/default_like.png',
            width: 23,
            height: 23,
          );
      }
    }

    return GestureDetector(
      onTap: () {},
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
            if (showCommentsCount)
              const Padding(
                padding: EdgeInsets.only(left: 4, right: 4, top: 10),
                child: Divider(
                  thickness: 0.4,
                  color: idkWhatColor,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (reactionsMap[post.post.id] != null) {
                      reactionsMap[post.post.id] = 0;
                    }

                    model.addLike(post);
                  },
                  onLongPress: () {
                    chooseReaction(context, post, flag);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: idkWhatColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        getReactionImage(post.post.id),
                        const SizedBox(width: 6),
                        Text(
                          '${post.ratingList.getTotalNumberOfReactions() > 0 ? post.ratingList.getTotalNumberOfReactions() : ""}',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: idkWhatColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    if (!processClicks) {
                      return;
                    }
                    await Navigator.of(
                      context
                          .findRootAncestorStateOfType<NavigatorState>()!
                          .context,
                    ).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return CommentsPage(post: post);
                        },
                      ),
                    );
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
                Container(
                  padding: const EdgeInsets.only(
                    top: 6,
                    bottom: 6,
                    right: 8,
                    left: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (int i = 0;
                          i < post.ratingList.ratingList.length;
                          i++)
                        Positioned(
                          top: 0.0,
                          left: reactionsSize / 2 * i,
                          child: ClipOval(
                            child: Container(
                              width: 21,
                              height: 21,
                              color: const Color.fromARGB(105, 198, 217, 249),
                              child: Image.asset(
                                post.ratingList.ratingList.keys
                                    .toList(growable: false)[i]
                                    .assetName,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        '${post.ratingList.getTotalNumberOfReactions() > 0 ? post.ratingList.getTotalNumberOfReactions() : ""}',
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
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
    );
  }

  BBStylesheet getBBStyleSheet() {
    return defaultBBStylesheet()
        .replaceTag(
          UrlTag(
            onTap: (url) async {
              if (!await launchUrl(Uri.parse(url))) {
                FirebaseCrashlytics.instance.log('Could not launch url $url');
              }
            },
          ),
        )
        .addTag(custom_tags.PTag())
        .addTag(custom_tags.SizeTag())
        .addTag(
          custom_tags.VideoTag(
            onTap: (url) async {
              if (!await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.platformDefault,
              )) {
                FirebaseCrashlytics.instance.log('Could not launch url $url');
              }
            },
          ),
        )
        .addTag(custom_tags.JustifyAlignTag())
        .addTag(custom_tags.FontTag())
        .addTag(custom_tags.CodeTag())
        .addTag(custom_tags.DiskTag())
        .addTag(custom_tags.TableTag())
        .addTag(custom_tags.TRTag())
        .addTag(custom_tags.TDTag())
        .addTag(custom_tags.UserTag())
        .replaceTag(custom_tags.ColorTag())
        .replaceTag(custom_tags.ImgTag())
        .replaceTag(custom_tags.SpoilerTag());
  }

  CircleAvatar _circleAvatar(ThemeData theme, UserData? userData) {
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

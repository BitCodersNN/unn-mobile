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

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({super.key});
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
                  isNewPost:
                      model.isNewPost(model.posts[index].post.datePublish),
                  showCommentsCount: true,
                );
              },
            ),
          ),
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            if (metrics.atEdge) {
              bool isTop = metrics.pixels == 0;
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

  static Widget feedPost(
    BuildContext context,
    PostWithLoadedInfo post, {
    bool isNewPost = false,
    bool showCommentsCount = false,
    bool processClicks = true,
  }) {
    final theme = Theme.of(context);
    final unescaper = HtmlUnescape();
    return GestureDetector(
      onTap: () async {
        if (!processClicks) {
          return;
        }
        await Navigator.of(
                context.findRootAncestorStateOfType<NavigatorState>()!.context)
            .push(MaterialPageRoute(builder: (context) {
          return CommentsPage(post: post);
        }));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isNewPost
              ? theme.extension<UnnMobileColors>()!.newPostHiglaght
              : theme.extension<UnnMobileColors>()!.defaultPostHighlight,
          borderRadius: BorderRadius.circular(0.0),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 9,
              color: Color.fromRGBO(82, 125, 175, 0.2),
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
                      "${post.author.fullname.lastname} ${post.author.fullname.name} ${post.author.fullname.surname}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A63B7),
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy, HH:mm', 'ru_RU')
                          .format(post.post.datePublish),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 106, 111, 122),
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
                      "Failed to parse BBCode correctly. ",
                      style: TextStyle(color: Colors.red),
                    ),
                    const Text(
                      "This usually means on of the tags is not properly handling unexpected input.\n",
                    ),
                    const Text("Original text: "),
                    Text(post.post.detailText.replaceAll("\n", "\n#")),
                    Text(error.toString()),
                  ],
                );
              },
            ),
            const SizedBox(height: 15.0),
            for (final file in post.files)
              AttachedFile(
                fileData: file,
              ),
            if (showCommentsCount)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 0, right: 4, top: 10),
                child: Divider(
                  thickness: 0.4,
                  color: Color.fromARGB(255, 152, 158, 169),
                ),
              ),
            if (showCommentsCount)
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.message,
                      color: Color.fromARGB(255, 152, 158, 169),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      "Комментарии:",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 152, 158, 169),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "${post.post.numberOfComments}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 152, 158, 169),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  static BBStylesheet getBBStyleSheet() {
    return defaultBBStylesheet()
        .replaceTag(
          UrlTag(
            onTap: (url) async {
              if (!await launchUrl(Uri.parse(url))) {
                FirebaseCrashlytics.instance.log("Could not launch url $url");
              }
            },
          ),
        )
        .addTag(custom_tags.PTag())
        .addTag(custom_tags.SizeTag())
        .addTag(
          custom_tags.VideoTag(
            onTap: (url) async {
              if (!await launchUrl(Uri.parse(url),
                  mode: LaunchMode.platformDefault)) {
                FirebaseCrashlytics.instance.log("Could not launch url $url");
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

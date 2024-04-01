import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseView<FeedScreenViewModel>(
      builder: (context, model, child) {
        final theme = Theme.of(context);
        final unescaper = HtmlUnescape();
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
                return feedPost(theme, model, model.posts[index], unescaper);
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

  Container feedPost(ThemeData theme, FeedScreenViewModel model,
      PostWithLoadedInfo post, HtmlUnescape unescaper) {
    return Container(
      margin: const EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 12),
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        ],
      ),
    );
  }

  BBStylesheet getBBStyleSheet() {
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
        .addTag(PTag())
        .addTag(SizeTag())
        .addTag(
          VideoTag(
            onTap: (url) async {
              if (!await launchUrl(Uri.parse(url),
                  mode: LaunchMode.platformDefault)) {
                FirebaseCrashlytics.instance.log("Could not launch url $url");
              }
            },
          ),
        )
        .addTag(JustifyAlignTag())
        .addTag(FontTag())
        .addTag(CodeTag())
        .addTag(DiskTag())
        .replaceTag(NewColorTag());
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

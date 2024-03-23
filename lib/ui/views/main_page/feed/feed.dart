import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:unn_mobile/core/misc/customBBTags.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({super.key});

  final data2 = "someText [url]example.com[/url] [URL]example.com[/URL]";
  @override
  Widget build(BuildContext context) {
    return BaseView<FeedScreenViewModel>(
      builder: (context, model, child) {
        final theme = Theme.of(context);
        return FutureBuilder(
          future: model.blogPostsLoader,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    for (BlogData post in snapshot.data!)
                      Column(
                        children: [
                          const Divider(),
                          FutureBuilder(
                            future: model.getUserProfileByAuthorID(post.authorID),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var userAvatar =
                                    model.getUserAvatar(snapshot.data!);
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircleAvatar(
                                        backgroundImage: userAvatar,
                                        child: userAvatar == null
                                            ? Text(
                                                style: theme
                                                    .textTheme.headlineSmall!
                                                    .copyWith(
                                                  color: theme
                                                      .colorScheme.onBackground,
                                                ),
                                                model.getUserInitials(
                                                    snapshot.data!),
                                              )
                                            : null,
                                      ),
                                    ),
                                    Text(
                                        "${snapshot.data!.fullname.name} ${snapshot.data!.fullname.lastname}"),
                                  ],
                                );
                              } else {
                                return const Text("Загрузка");
                              }
                            },
                          ),
                          BBCodeText(
                            data: post.detailText,
                            stylesheet: defaultBBStylesheet().replaceTag(UrlTag(
                              onTap: (url) async {
                                if (!await launchUrl(Uri.parse(url))) {
                                  log("Hello");
                                }
                              },
                            )).addTag(PTag()),
                            errorBuilder: (context, error, stack) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Failed to parse BBCode correctly. ",
                                      style: TextStyle(color: Colors.red)),
                                  const Text(
                                      "This usually means on of the tags is not properly handling unexpected input.\n"),
                                  const Text("Original text: "),
                                  Text(post.detailText.replaceAll("\n", "\n#")),
                                  Text(error.toString()),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text("error");
            } else {
              return const Text("Загрузка");
            }
          },
        );
      },
      onModelReady: (model) => model.init(),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:unn_mobile/core/misc/customBBTags.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({Key? key});

  final data2 = "someText [url]example.com[/url] [URL]example.com[/URL]";

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'января';
      case 2:
        return 'февраля';
      case 3:
        return 'марта';
      case 4:
        return 'апреля';
      case 5:
        return 'мая';
      case 6:
        return 'июня';
      case 7:
        return 'июля';
      case 8:
        return 'августа';
      case 9:
        return 'сентября';
      case 10:
        return 'октября';
      case 11:
        return 'ноября';
      case 12:
        return 'декабря';
      default:
        return '';
    }
  }

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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      for (BlogData post in snapshot.data!)
                        Container(
                          margin: const EdgeInsets.only(
                              left: 0, bottom: 0, right: 0, top: 12),
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, left: 20, right: 20),
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
                              FutureBuilder(
                                future: model
                                    .getUserProfileByAuthorID(post.authorID),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var userAvatar =
                                        model.getUserAvatar(snapshot.data!);
                                    return Row(
                                      children: [
                                        SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: CircleAvatar(
                                            backgroundImage: userAvatar,
                                            child: userAvatar == null
                                                ? Text(
                                                    style: theme.textTheme
                                                        .headlineSmall!
                                                        .copyWith(
                                                      color: theme.colorScheme
                                                          .onBackground,
                                                    ),
                                                    model.getUserInitials(
                                                        snapshot.data!),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${snapshot.data!.fullname.name} ${snapshot.data!.fullname.lastname}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1A63B7),
                                              ),
                                            ),
                                            Text(
                                              DateFormat(
                                                      'd MMMM, HH:mm', 'ru_RU')
                                                  .format(post.datePublish),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: Color.fromARGB(
                                                    255, 106, 111, 122),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Text(
                                      "Загрузка...",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color:
                                            Color.fromARGB(255, 106, 111, 122),
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 16.0),
                              BBCodeText(
                                data: post.detailText,
                                stylesheet: defaultBBStylesheet().replaceTag(
                                  UrlTag(
                                    onTap: (url) async {
                                      if (!await launchUrl(Uri.parse(url))) {
                                        log("Hello");
                                      }
                                    },
                                  ),
                                ).addTag(PTag()),
                                errorBuilder: (context, error, stack) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Failed to parse BBCode correctly. ",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      const Text(
                                        "This usually means on of the tags is not properly handling unexpected input.\n",
                                      ),
                                      const Text("Original text: "),
                                      Text(post.detailText
                                          .replaceAll("\n", "\n#")),
                                      Text(error.toString()),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("error");
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
      onModelReady: (model) => model.init(),
    );
  }
}

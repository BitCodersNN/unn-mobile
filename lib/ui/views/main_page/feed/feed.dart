import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:unn_mobile/core/misc/customBBTags.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({Key? key});

  final data2 = "someText [url]example.com[/url] [URL]example.com[/URL]";
  @override
  Widget build(BuildContext context) {
    return BaseView<FeedScreenViewModel>(
      builder: (context, model, child) {
        final theme = Theme.of(context);
        return FutureBuilder(
          future: model.blogPosts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      for (final post in snapshot.data!)
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                               BoxShadow(
                                   offset: Offset(0, 0),
                                  blurRadius: 16,
                                  color: Color.fromRGBO(82, 125, 175, 0.2),
                                ),
                              ]),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                //child: Text(post.detailText),
                                child: BBCodeText(
                                  data: post.detailText,
                                  stylesheet:
                                      defaultBBStylesheet().replaceTag(UrlTag(
                                    onTap: (url) async {
                                      if (!await launchUrl(Uri.parse(url))) {
                                        log("Hello");
                                      }
                                    },
                                  )).addTag(PTag()),
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
                                          "This usually means one of the tags is not properly handling unexpected input.\n",
                                        ),
                                        const Text("Original text: "),
                                        Text(
                                          post.detailText
                                              .replaceAll("\n", "\n#"),
                                        ),
                                        Text(error.toString()),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else {
              return const Text("Загрузка...");
            }
          },
        );
      },
      onModelReady: (model) => model.init(),
    );
  }
}

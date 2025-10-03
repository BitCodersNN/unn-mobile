// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/about/about_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreenView extends StatelessWidget {
  const AboutScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<AboutViewModel>(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('О нас')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!model.initialized)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          if (model.authors.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      'Команда разработчиков',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(color: Colors.black),
                                    ),
                                  ),
                                  ...model.authors.map(
                                    (author) => _AuthorProfileWidget(author),
                                  ),
                                ],
                              ),
                            ),
                          if (model.pastAuthors.isNotEmpty) ...[
                            const Divider(),
                            ExpansionTile(
                              shape: const Border(),
                              title: Text(
                                'Прошлые участники',
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.black),
                              ),
                              dense: true,
                              children: [
                                ...model.pastAuthors.map(
                                  (author) => _AuthorProfileWidget(author),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        ],
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HtmlWidget(
                            '''
                      <p>Приложение распространяется под лицензией <a href="https://github.com/BitCodersNN/unn-mobile?tab=Apache-2.0-1-ov-file">Apache 2.0</a></p>
                      <p>Код приложения доступен <a href="https://github.com/BitCodersNN/unn-mobile">на нашем GitHub</a></p>
                      <p>По всем вопросам можно обращаться: <a href="https://t.me/unn_mobile">t.me/unn_mobile</a></p>
                      ''',
                            textStyle: const TextStyle(
                              color: Color(0xFF717A84),
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                            onTapUrl: (url) async {
                              if (!await launchUrl(Uri.parse(url))) {
                                Injector.appInstance
                                    .get<LoggerService>()
                                    .log('Could not launch url $url');
                              }
                              return true;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AuthorProfileWidget extends StatelessWidget {
  final Author profile;

  const _AuthorProfileWidget(this.profile);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 90,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 16,
              color: Color(0x20527DAF),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            ClipOval(
              child: SizedBox(
                width: 55,
                height: 55,
                child: CachedNetworkImage(
                  imageUrl: profile.avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    radius: 27.5,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullname,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF282828),
                    ),
                  ),
                  if (profile.educationGroup != null)
                    Text(
                      profile.educationGroup!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: Color(0xFF717A84),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreenView extends StatelessWidget {
  AboutScreenView({super.key});

  final List<_AuthorProfile> _authors = [
    _AuthorProfile.create('Крисеев Михаил Алексеевич', 'mikhail.png'),
    _AuthorProfile.create('Юрин Андрей Юрьевич', 'andrew.png'),
    _AuthorProfile.create('Соколова Дарья Владимировна', 'darya.png'),
  ];

  final List<_AuthorProfile> _pastAuthors = [
    _AuthorProfile.create('Ванюшкин Дмитрий Игоревич', 'dmitry.png'),
    _AuthorProfile.create(
      'Паймухин Виталий Евгеньевич',
      'vitaly.png',
      educationGroup: '3821Б1ПИис1',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('О нас')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Команда разработчиков',
                    textAlign: TextAlign.left,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: Colors.black),
                  ),
                  ..._authors.map(
                    (authorProfile) => _AuthorProfileWidget(authorProfile),
                  ),
                  const Divider(),
                  ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      'Прошлые участники',
                      textAlign: TextAlign.left,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: Colors.black),
                    ),
                    dense: true,
                    children: [
                      ..._pastAuthors.map(
                        (authorProfile) => _AuthorProfileWidget(authorProfile),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
              HtmlWidget(
                'По всем вопросам можно обращаться: <a href="https://t.me/unn_mobile">t.me/unn_mobile</a>',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorProfileWidget extends StatelessWidget {
  final _AuthorProfile profile;

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
          mainAxisAlignment: MainAxisAlignment.start,
          verticalDirection: VerticalDirection.up,
          children: [
            const SizedBox(width: 10),
            Image(image: profile.avatar, height: 55),
            const SizedBox(width: 15),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF282828),
                    ),
                  ),
                  Text(
                    profile.educationGroup,
                    overflow: TextOverflow.visible,
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

class _AuthorProfile {
  final AssetImage avatar;
  final String fullName;
  final String educationGroup;

  _AuthorProfile._(this.avatar, this.fullName, this.educationGroup);

  factory _AuthorProfile.create(
    String fullName,
    String avatarAssetName, {
    String educationGroup = '3821Б1ПР1',
  }) {
    return _AuthorProfile._(
      AssetImage('assets/images/authors/$avatarAssetName'),
      fullName,
      educationGroup,
    );
  }
}

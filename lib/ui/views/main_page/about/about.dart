import 'package:flutter/material.dart';

class AboutScreenView extends StatelessWidget {
  AboutScreenView({super.key});

  final List<_AuthorProfile> _authors = [
    _AuthorProfile.create('Крисеев Михаил Алексеевич', 'michail.png'),
    _AuthorProfile.create('Юрин Андрей Юрьевич', 'andrew.png'),
    _AuthorProfile.create('Ванюшкин Дмитрий Игоревич', 'dmitry.png'),
    _AuthorProfile.create(
      'Паймухин Виталий Евгеньевич',
      'vitaly.png',
      educationGroup: '3821Б1ПИис1',
    ),
    _AuthorProfile.create('Соколова Дарья Владимировна', 'darya.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 100),
        child: Column(
          children: [
            Column(
              children: _authors
                  .map((authorProfile) => _AuthorProfileWidget(authorProfile))
                  .toList(),
            ),
            const Text(
              'По всем вопросам можно обращаться: unnmobile@mail.ru',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF717A84),
                fontFamily: 'Inter',
                fontSize: 13,
              ),
            ),
            const Image(
              image: AssetImage('assets/images/quest/3.png'),
            ),
          ],
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

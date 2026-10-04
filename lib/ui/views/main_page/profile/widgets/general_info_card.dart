// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_card.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_info_tile.dart';

class GeneralInfoCard extends StatelessWidget {
  final UserData data;
  final bool isMe;

  const GeneralInfoCard({
    required this.data,
    this.isMe = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (data.login != null && data.login!.isNotEmpty)
        ProfileInfoTile(label: 'Логин', value: data.login!),
      if (isMe) ...[
        if (data.sex.isNotEmpty)
          ProfileInfoTile(label: 'Пол', value: _displaySex(data.sex)),
      ],
    ];
    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }
    return ProfileCard(title: 'Личная информация', tiles: tiles);
  }

  String _displaySex(String sex) => switch (sex) {
        'M' => 'Мужской',
        'F' => 'Женский',
        _ => sex,
      };
}

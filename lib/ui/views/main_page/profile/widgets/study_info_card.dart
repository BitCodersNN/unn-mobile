// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_card.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_info_tile.dart';

class StudyInfoCard extends StatelessWidget {
  final StudentData data;

  const StudyInfoCard({required this.data, super.key});

  static const Map<String, String> _eduFormNames = {
    'full-time': 'Очная',
    'distance': 'Заочная',
    'part-time': 'Очно-заочная',
  };

  @override
  Widget build(BuildContext context) {
    final edu = data.baseEduInfo;
    return ProfileCard(
      title: 'Обучение',
      tiles: [
        ProfileInfoTile(label: 'Факультет', value: edu.faculty),
        ProfileInfoTile(label: 'Направление', value: edu.eduDirection),
        if (edu.eduSpecialization != null && edu.eduSpecialization!.isNotEmpty)
          ProfileInfoTile(
            label: 'Специализация',
            value: edu.eduSpecialization!,
          ),
        ProfileInfoTile(label: 'Группа', value: edu.eduGroup),
        ProfileInfoTile(
          label: 'Форма обучения',
          value: _eduFormNames[edu.eduForm] ?? edu.eduForm,
        ),
        if (edu.eduLevel.isNotEmpty)
          ProfileInfoTile(label: 'Уровень', value: edu.eduLevel),
        ProfileInfoTile(label: 'Курс', value: '${edu.eduCourse}'),
        ProfileInfoTile(label: 'Год поступления', value: '${data.eduYear}'),
        if (data.eduStatus.isNotEmpty)
          ProfileInfoTile(label: 'Статус', value: data.eduStatus),
      ],
    );
  }
}

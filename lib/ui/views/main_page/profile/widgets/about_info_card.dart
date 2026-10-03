// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_card.dart';

class AboutInfoCard extends StatelessWidget {
  final UserData data;

  const AboutInfoCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final notes = data.notes?.trim() ?? '';
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return ProfileCard(
      title: 'О себе',
      tiles: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(notes, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}

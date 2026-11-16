// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_card.dart';
import 'package:unn_mobile/ui/widgets/context_menu/copyable_context_menu.dart';
import 'package:unn_mobile/ui/widgets/linkified_text.dart';

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
        CopyableContextMenu(
          label: 'О себе',
          value: notes,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LinkifiedText(
              text: notes,
              style: theme.textTheme.bodyLarge,
              selectable: false,
            ),
          ),
        ),
      ],
    );
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat_navigation.dart';
import 'package:unn_mobile/ui/views/main_page/profile/profile_activity_formatter.dart';
import 'package:unn_mobile/ui/widgets/user_profile_card.dart';

class ProfilePageHeader extends StatelessWidget {
  final ProfileViewModel model;

  const ProfilePageHeader({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final activity = model.userData?.lastActivityAt;
    return UserProfileCard(
      name: model.fullname,
      initials: model.initials,
      subtitle: model.profileSubtitle,
      avatarUrl: model.avatarUrl,
      isLoading: model.isLoading && model.userData == null,
      status: activity == null
          ? null
          : formatProfileActivity(activity, sex: model.userData?.sex),
      action: model.canWriteMessage
          ? FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => openUserDialog(context, model.userData!),
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: const Text('Написать'),
            )
          : null,
    );
  }
}

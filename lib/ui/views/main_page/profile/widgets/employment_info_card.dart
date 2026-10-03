// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_profile.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/ui/views/main_page/profile/widgets/profile_card.dart';

class EmploymentInfoCard extends StatelessWidget {
  final EmployeeData data;

  const EmploymentInfoCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    if (data.profiles.isEmpty) {
      return const SizedBox.shrink();
    }
    return ProfileCard(
      title: 'Позиции',
      tiles: [
        for (final profile in data.profiles)
          _EmployeeProfileSection(profile: profile),
      ],
    );
  }
}

class _EmployeeProfileSection extends StatelessWidget {
  final EmployeeProfile profile;

  const _EmployeeProfileSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final departments = profile.previewEmployeeProfile.departments;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          leading: const Icon(Icons.badge_outlined),
          title: Text(
            profile.previewEmployeeProfile.jobTitle,
            style: theme.textTheme.titleSmall,
          ),
          subtitle: profile.jobType.isNotEmpty ? Text(profile.jobType) : null,
        ),
        if (departments.isNotEmpty)
          ListTile(
            dense: true,
            title: Text('Подразделение', style: theme.textTheme.bodySmall),
            subtitle: Text(
              departments.map((department) => department.title).join(', '),
            ),
          ),
        if (profile.manager != null) _ManagerTile(manager: profile.manager!),
      ],
    );
  }
}

class _ManagerTile extends StatelessWidget {
  final UserShortInfo manager;

  const _ManagerTile({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoSrc = manager.photoSrc;
    final hasPhoto = photoSrc != null && photoSrc.isNotEmpty;
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: hasPhoto ? CachedNetworkImageProvider(photoSrc) : null,
        child: hasPhoto
            ? null
            : Text(
                generateInitials(manager.fullname?.split(' ') ?? []),
                style: theme.textTheme.labelMedium,
              ),
      ),
      title: Text('Руководитель', style: theme.textTheme.bodySmall),
      subtitle: Text(manager.fullname ?? ''),
    );
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/models/profile/employee/preview_employee.dart';
import 'package:unn_mobile/core/models/profile/profile_preview.dart';
import 'package:unn_mobile/core/models/profile/student/preview_student.dart';

class PersonSearchTile extends StatelessWidget {
  final ProfilePreview person;
  final VoidCallback onTap;

  const PersonSearchTile({
    required this.person,
    required this.onTap,
    super.key,
  });

  String _description() => switch (person) {
    final PreviewStudent student => [
      student.baseEduInfo.eduGroup,
      student.baseEduInfo.faculty,
    ].where((value) => value.trim().isNotEmpty).join(' · '),
    final PreviewEmployee employee =>
      employee.profiles
          .map(
            (profile) => [
              profile.jobTitle,
              ...profile.departments.map(
                (department) => department.shortTitle.isNotEmpty
                    ? department.shortTitle
                    : department.title,
              ),
            ].where((value) => value.trim().isNotEmpty).join(' · '),
          )
          .where((value) => value.isNotEmpty)
          .toSet()
          .join('\n'),
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fullname = person.fullname?.trim();
    final name = fullname == null || fullname.isEmpty ? 'Без имени' : fullname;
    final description = _description();
    final initials = Text(
      generateInitials(name.split(' ')),
      style: theme.textTheme.titleSmall?.copyWith(
        color: colors.onPrimaryContainer,
      ),
    );
    final photoUrl = person.photoSrc;
    return Material(
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ExcludeSemantics(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: colors.primaryContainer,
            child: photoUrl == null || photoUrl.isEmpty
                ? initials
                : ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Center(child: initials),
                      errorWidget: (_, _, _) => Center(child: initials),
                    ),
                  ),
          ),
        ),
        title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: description.isEmpty
            ? null
            : Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colors.onSurfaceVariant,
          size: 22,
        ),
        onTap: onTap,
      ),
    );
  }
}

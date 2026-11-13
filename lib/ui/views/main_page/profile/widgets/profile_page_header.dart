// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat_navigation.dart';
import 'package:unn_mobile/ui/views/main_page/profile/profile_activity_formatter.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_screen.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class ProfilePageHeader extends StatelessWidget {
  final ProfileViewModel model;

  const ProfilePageHeader({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumn =
                  constraints.maxWidth < 260 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24;
              final avatar = _ProfileAvatar(model: model);
              final identity = _ProfileIdentity(model: model);
              return useColumn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [avatar, const SizedBox(height: 12), identity],
                    )
                  : Row(
                      children: [
                        avatar,
                        const SizedBox(width: 16),
                        Expanded(child: identity),
                      ],
                    );
            },
          ),
          if (model.canWriteMessage) ...[
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
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
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ProfileViewModel model;

  const _ProfileAvatar({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final image = model.hasAvatar
        ? CachedNetworkImageProvider(model.avatarUrl!)
        : null;
    final isLoading = model.isLoading && model.userData == null;
    return Semantics(
      button: image != null,
      label: image != null ? 'Открыть фото профиля' : 'Аватар профиля',
      child: GestureDetector(
        onTap: image == null
            ? null
            : () => showImageViewer(context, images: [image]),
        child: SizedBox.square(
          dimension: 88,
          child: ShimmerLoading(
            isLoading: isLoading,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                backgroundImage: image,
                onBackgroundImageError: image != null ? (_, _) {} : null,
                child: image != null
                    ? null
                    : Text(
                        model.initials,
                        style: theme.textTheme.headlineSmall,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  final ProfileViewModel model;

  const _ProfileIdentity({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLoading = model.isLoading && model.userData == null;
    final activity = model.userData?.lastActivityAt;
    final subtitle = model.profileSubtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          SizedBox(
            height: 28,
            width: double.infinity,
            child: ShimmerLoading(
              isLoading: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          )
        else
          Text(
            model.fullname,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.primary),
          ),
        ],
        if (activity != null) ...[
          const SizedBox(height: 6),
          Text(
            formatProfileActivity(activity, sex: model.userData?.sex),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/context_menu/copyable_context_menu.dart';
import 'package:unn_mobile/ui/widgets/image_viewer_screen.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

enum UserProfileCardLayout { compact, centered }

class UserProfileCard extends StatelessWidget {
  final String name;
  final String initials;
  final String subtitle;
  final String? avatarUrl;
  final String? status;
  final bool isLoading;
  final bool enablePhotoViewer;
  final Widget? action;
  final UserProfileCardLayout layout;

  const UserProfileCard({
    required this.name,
    required this.initials,
    this.subtitle = '',
    this.avatarUrl,
    this.status,
    this.isLoading = false,
    this.enablePhotoViewer = true,
    this.action,
    this.layout = UserProfileCardLayout.compact,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final centered = layout == UserProfileCardLayout.centered;
    final card = Container(
      padding: centered
          ? const EdgeInsets.symmetric(horizontal: 12)
          : const EdgeInsets.all(20),
      decoration: centered
          ? null
          : BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumn =
                  centered ||
                  constraints.maxWidth < 260 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24;
              final avatar = _ProfileAvatar(
                avatarUrl: avatarUrl,
                initials: initials,
                isLoading: isLoading,
                enablePhotoViewer: enablePhotoViewer,
                framed: !centered,
              );
              final identity = _ProfileIdentity(
                name: name,
                subtitle: subtitle,
                status: status,
                isLoading: isLoading,
                centered: centered,
              );
              return useColumn
                  ? Column(
                      crossAxisAlignment: centered
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        avatar,
                        SizedBox(height: centered ? 18 : 12),
                        identity,
                      ],
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
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
    return isLoading ? Shimmer(child: card) : card;
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final bool isLoading;
  final bool enablePhotoViewer;
  final bool framed;

  const _ProfileAvatar({
    required this.avatarUrl,
    required this.initials,
    required this.isLoading,
    required this.enablePhotoViewer,
    required this.framed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final image = avatarUrl?.isNotEmpty ?? false
        ? CachedNetworkImageProvider(avatarUrl!)
        : null;
    final canOpenPhoto = image != null && enablePhotoViewer;
    return Semantics(
      button: canOpenPhoto,
      label: canOpenPhoto ? 'Открыть фото профиля' : 'Аватар профиля',
      child: GestureDetector(
        onTap: !canOpenPhoto
            ? null
            : () => showImageViewer(context, images: [image]),
        child: SizedBox.square(
          dimension: framed ? 88 : 104,
          child: ShimmerLoading(
            isLoading: isLoading,
            child: Container(
              padding: framed ? const EdgeInsets.all(4) : EdgeInsets.zero,
              decoration: framed
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.2),
                      ),
                    )
                  : null,
              child: CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                backgroundImage: image,
                onBackgroundImageError: image != null ? (_, _) {} : null,
                child: image != null
                    ? null
                    : Text(
                        initials,
                        style: framed
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.headlineLarge,
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
  final String name;
  final String subtitle;
  final String? status;
  final bool isLoading;
  final bool centered;

  const _ProfileIdentity({
    required this.name,
    required this.subtitle,
    required this.status,
    required this.isLoading,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
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
          CopyableContextMenu(
            label: 'ФИО',
            value: name,
            child: Text(
              name,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style:
                  (centered
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.titleLarge)
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
            ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          CopyableContextMenu(
            label: 'Информация о пользователе',
            value: subtitle,
            child: Text(
              subtitle,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: centered
                  ? theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    )
                  : theme.textTheme.bodyMedium?.copyWith(color: colors.primary),
            ),
          ),
        ],
        if (status?.isNotEmpty ?? false) ...[
          const SizedBox(height: 6),
          CopyableContextMenu(
            label: 'Последняя активность',
            value: status!,
            child: Text(
              status!,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

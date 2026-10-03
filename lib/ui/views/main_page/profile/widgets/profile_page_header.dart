// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class ProfilePageHeader extends StatelessWidget {
  final ProfileViewModel model;

  const ProfilePageHeader({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = model.isLoading && model.userData == null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShimmerLoading(
          isLoading: model.isLoading,
          child: CircleAvatar(
            radius: 44,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: model.hasAvatar
                ? CachedNetworkImageProvider(model.avatarUrl!)
                : null,
            child: model.hasAvatar
                ? null
                : Text(
                    model.initials,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          )
        else
          Text(
            model.fullname,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall,
          ),
      ],
    );
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class MainPageMenu extends StatelessWidget {
  final MainPageViewModel model;

  const MainPageMenu({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: ListenableBuilder(
        listenable: model,
        builder: (context, _) => OnlineStatusBuilder(
          builder: (context, isOnline) => ValueListenableBuilder<List<String>>(
            valueListenable: AppSettings.tabBarPaths,
            builder: (context, paths, _) {
              final routes = [
                for (final route in MainPageRouting.navbarRoutes)
                  if (route.pagePath != 'more' &&
                      !paths.contains(route.pagePath))
                    route,
                for (final route in model.routes)
                  if (!route.onlineOnly || isOnline) route,
              ];
              return SafeArea(
                bottom: false,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Открыть мой профиль',
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            pressedOpacity: 0.75,
                            onPressed: () => context.go(
                              mainPageDestinationLocation('myProfile'),
                            ),
                            child: _buildProfile(context),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Material(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var index = 0;
                                  index < routes.length;
                                  index++) ...[
                                if (index > 0)
                                  Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    indent: 56,
                                    endIndent: 16,
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                _buildDestination(context, routes[index]),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDestination(BuildContext context, MainPageRouteData route) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minVerticalPadding: 12,
      minLeadingWidth: 24,
      leading: Icon(
        route.unselectedIcon,
        color: theme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(route.pageTitle, style: theme.textTheme.bodyLarge),
      trailing: Icon(
        Icons.chevron_right,
        size: 23,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      enabled: !route.isDisabled,
      onTap: () => context.go(
        mainPageDestinationLocation(route.pagePath),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final profile = model.profileViewModel;
    if (profile == null) {
      return _profileContent(context, null);
    }
    return ListenableBuilder(
      listenable: profile,
      builder: (context, _) => _profileContent(context, profile),
    );
  }

  Widget _profileContent(BuildContext context, ProfileViewModel? profile) {
    final theme = Theme.of(context);
    final isLoading = model.isBusy || (profile?.isLoading ?? false);
    return ShimmerLoading(
      isLoading: isLoading,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              backgroundImage: profile != null && profile.hasAvatar
                  ? CachedNetworkImageProvider(profile.avatarUrl!)
                  : null,
              child: profile == null || !profile.hasAvatar
                  ? Text(
                      profile?.initials ?? '?',
                      style: theme.textTheme.headlineLarge,
                    )
                  : null,
            ),
            const SizedBox(height: 18),
            Text(
              profile?.fullname ??
                  (isLoading ? 'Загрузка профиля' : 'Профиль недоступен'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (profile != null && profile.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                profile.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

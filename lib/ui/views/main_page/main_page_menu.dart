// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
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
      appBar: AppBar(
        title: const Text('Ещё'),
        forceMaterialTransparency: true,
      ),
      body: ListenableBuilder(
        listenable: model,
        builder: (context, _) => OnlineStatusBuilder(
          builder: (context, isOnline) => SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProfile(context),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: AppSettings.tabBarPaths,
                    builder: (context, paths, _) => Column(
                      children: [
                        for (final route in MainPageRouting.navbarRoutes)
                          if (!paths.contains(route.pagePath) &&
                              route.pagePath != '/more')
                            ListTile(
                              leading: Icon(route.unselectedIcon),
                              title: Text(route.pageTitle),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  context.go(mainPageRoute + route.pagePath),
                            ),
                      ],
                    ),
                  ),
                  Material(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final route in model.routes)
                          if (!route.onlineOnly || isOnline)
                            ListTile(
                              leading: Icon(route.unselectedIcon),
                              title: Text(route.pageTitle),
                              trailing: const Icon(Icons.chevron_right),
                              enabled: !route.isDisabled,
                              onTap: () => context.go(
                                '$mainPageRoute/more/$drawerRoutePrefix/${route.pagePath}',
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final theme = Theme.of(context);
    final profile = model.profileViewModel;
    return ShimmerLoading(
      isLoading: model.isBusy,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: profile != null && profile.hasAvatar
              ? CachedNetworkImageProvider(profile.avatarUrl!)
              : null,
          child: profile == null || !profile.hasAvatar
              ? Text(profile?.initials ?? '?')
              : null,
        ),
        title: Text(
          profile?.fullname ?? 'Ошибка загрузки',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: profile == null ? null : Text(profile.description),
      ),
    );
  }
}

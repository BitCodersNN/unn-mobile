// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/birthday/birthday_greeting_manager.dart';
import 'package:unn_mobile/core/misc/menu_order_preferences.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/ui/birthday/birthday_banner.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_route_data.dart';
import 'package:unn_mobile/ui/views/main_page/menu/reorderable_menu_list.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class MainPageMenu extends StatelessWidget {
  const MainPageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: OnlineStatusBuilder(
        builder: (context, isOnline) {
          final router = AppRouter.of(context);
          final configuration = router.configuration;
          final routes = configuration.tabs.last.subroutes
              .where(
                (route) => !route.isDisabled && (!route.onlineOnly || isOnline),
              )
              .toList(growable: false);
          return ValueListenableBuilder<List<String>>(
            valueListenable: AppSettings.moreMenuPaths,
            builder: (context, savedPaths, _) {
              final byPath = {
                for (final route in routes) route.pagePath: route,
              };
              final ordered = MenuOrderPreferences.orderedPaths(
                byPath.keys,
                savedPaths,
              ).map((path) => byPath[path]!).toList(growable: false);
              return ReorderableMenuList(
                routes: ordered,
                header: _buildHeader(context, router),
                itemBuilder: _buildDestination,
                onReorder: (from, to) => _reorder(
                  context,
                  routes: ordered,
                  available: configuration.destinations,
                  from: from,
                  to: to,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _reorder(
    BuildContext context, {
    required List<MainPageRouteData> routes,
    required List<MainPageRouteData> available,
    required int from,
    required int to,
  }) async {
    if (from == to) {
      return;
    }
    final paths = MenuOrderPreferences.reorder(
      saved: AppSettings.moreMenuPaths.value,
      available: available.map((route) => route.pagePath),
      visible: routes.map((route) => route.pagePath).toList(),
      from: from,
      to: to,
    );
    try {
      await AppSettings.updateMoreMenuPaths(paths);
    } catch (error, stack) {
      Injector.appInstance.get<LoggerService>().logError(error, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить порядок разделов'),
          ),
        );
      }
    }
  }

  Widget _buildHeader(BuildContext context, AppRouter router) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: 'Открыть мой профиль',
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            pressedOpacity: 0.75,
            onPressed: () => router.goToDestination(
              MainPagePaths.myProfile,
              initialLocation: true,
            ),
            child: _buildProfile(context),
          ),
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: router.router.routeInformationProvider,
          builder: (context, _) => BirthdayBanner(
            userStorage: Injector.appInstance.get<CurrentUserSyncStorage>(),
            manager: Injector.appInstance.get<BirthdayGreetingManager>(),
            isActive:
                router.router.routeInformationProvider.value.uri.path ==
                router.locationFor(MainPagePaths.more),
          ),
        ),
      ],
    ),
  );

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
      onTap: () =>
          AppRouter.of(context)
              .goToDestination(route.pagePath, initialLocation: true),
    );
  }

  Widget _buildProfile(BuildContext context) => Shimmer(
    child: BaseView<ProfileViewModel>(
      createModel: ProfileViewModel.currentUser,
      onDispose: (model) => model.dispose(),
      builder: (context, model, _) => _profileContent(context, model),
    ),
  );

  Widget _profileContent(BuildContext context, ProfileViewModel profile) {
    final theme = Theme.of(context);
    final isLoading = profile.isLoading;
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
              backgroundImage: profile.hasAvatar
                  ? CachedNetworkImageProvider(profile.avatarUrl!)
                  : null,
              child: !profile.hasAvatar
                  ? Text(profile.initials, style: theme.textTheme.headlineLarge)
                  : null,
            ),
            const SizedBox(height: 18),
            Text(
              isLoading ? 'Загрузка профиля' : profile.fullname,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (profile.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                profile.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

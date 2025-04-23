// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/ui/views/main_page/about/about.dart';
import 'package:unn_mobile/ui/views/main_page/certificates_online/certificates_online.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/announcements_page.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/comments_page.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/pinned_posts_page.dart';
import 'package:unn_mobile/ui/views/main_page/grades/grades.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule.dart';
import 'package:unn_mobile/ui/views/main_page/settings/settings.dart';
import 'package:unn_mobile/ui/views/main_page/donations/donations.dart';
import 'package:unn_mobile/ui/views/main_page/source/source.dart';

class MainPageRouteData {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String pageTitle;
  final String pageRoute;
  final Widget Function(BuildContext, GoRouterState) builder;
  final bool isDisabled;
  final List<Type> userTypes;
  final List<MainPageRouteData> subroutes;
  final bool onlineOnly;

  const MainPageRouteData(
    this.selectedIcon,
    this.unselectedIcon,
    this.pageTitle,
    this.pageRoute, {
    this.onlineOnly = false,
    this.subroutes = const [],
    this.isDisabled = false,
    required this.userTypes,
    required this.builder,
  });
}

final MainPageRouteData postCommentsRoute = MainPageRouteData(
  Icons.comment,
  Icons.comment,
  'Комментарии к записи',
  'comments/:postId',
  builder: (_, state) => CommentsPage(
    postId: int.tryParse(state.pathParameters['postId'] ?? '0') ?? 0,
  ),
  isDisabled: false,
  userTypes: [],
);
final MainPageRouteData pinnedPostsRoute = MainPageRouteData(
  Icons.pin,
  Icons.pin,
  'Закреплённые посты',
  'pinned',
  userTypes: [],
  builder: (_, __) => const PinnedPostsPage(),
  subroutes: [
    postCommentsRoute,
  ],
);
final MainPageRouteData announcementsRoute = MainPageRouteData(
  Icons.label_important,
  Icons.label_important,
  'Важные посты',
  'announcements',
  userTypes: [],
  builder: (_, __) => const AnnouncementsPage(),
);

int _navbarIndex = 0; // I hate myself

class MainPageRouting {
  static final List<MainPageRouteData> navbarRoutes = [
    MainPageRouteData(
      Icons.star,
      Icons.star_border,
      'Лента',
      '/feed',
      builder: (_, __) => FeedScreenView(
        routeIndex: _navbarIndex++,
      ),
      userTypes: [],
      subroutes: [
        postCommentsRoute,
        pinnedPostsRoute,
        announcementsRoute,
      ],
    ),
    MainPageRouteData(
      Icons.calendar_month,
      Icons.calendar_month_outlined,
      'Расписание',
      '/schedule',
      builder: (_, __) => ScheduleScreenView(
        routeIndex: _navbarIndex++,
      ),
      userTypes: [],
    ),
    MainPageRouteData(
      Icons.map,
      Icons.map_outlined,
      'Карта',
      '/map',
      builder: (_, __) => const Placeholder(),
      isDisabled: true,
      userTypes: [],
    ),
    MainPageRouteData(
      Icons.menu_book,
      Icons.menu_book_outlined,
      'Материалы',
      '/source',
      builder: (_, __) => const SourcePageView(
        routeIndex: 3,
      ),
      isDisabled: false,
      userTypes: [],
    ),
  ];

  static final List<MainPageRouteData> drawerRoutes = [
    MainPageRouteData(
      Icons.book,
      Icons.book_outlined,
      'Зачётная книжка',
      'grades',
      builder: (_, __) => const GradesScreenView(),
      userTypes: [StudentData],
    ),
    MainPageRouteData(
      Icons.description,
      Icons.description_outlined,
      'Справки онлайн',
      'online_certificates',
      builder: (_, __) => const OnlineCertificatesScreenView(),
      userTypes: [StudentData],
    ),
    MainPageRouteData(
      Icons.settings,
      Icons.settings_outlined,
      'Настройки',
      'settings',
      builder: (_, __) => const SettingsScreenView(),
      userTypes: [],
    ),
    MainPageRouteData(
      Icons.credit_card,
      Icons.credit_card_outlined,
      'Поддержать',
      'donations',
      builder: (_, __) => const DonationsScreenView(),
      userTypes: [],
      onlineOnly: true,
    ),
    MainPageRouteData(
      Icons.info,
      Icons.info_outline,
      'О нас',
      'about',
      builder: (_, __) => AboutScreenView(),
      userTypes: [],
    ),
  ];
  static final List<MainPageRouteData> _activeNavbarRoutes =
      navbarRoutes.where((e) => e.isDisabled == false).toList();

  static List<MainPageRouteData> get activeNavbarRoutes => _activeNavbarRoutes;
}

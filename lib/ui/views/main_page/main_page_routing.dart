// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_page_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/about/about.dart';
import 'package:unn_mobile/ui/views/main_page/certificates_online/certificates_online.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat_inside.dart';
import 'package:unn_mobile/ui/views/main_page/donations/donations.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/comments_page.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/pinned_posts_page.dart';
import 'package:unn_mobile/ui/views/main_page/grades/grades.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_menu.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_route_data.dart';
import 'package:unn_mobile/ui/views/main_page/profile/profile_page.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule_screen_view.dart';
import 'package:unn_mobile/ui/views/main_page/settings/settings.dart';
import 'package:unn_mobile/ui/views/main_page/source/source.dart';

export 'package:unn_mobile/ui/views/main_page/main_page_route_data.dart';

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

final MainPageRouteData feedUserProfileRoute = MainPageRouteData(
  Icons.person,
  Icons.person_outline,
  'Профиль',
  'profile/:userId',
  userTypes: [],
  builder: (_, state) => ProfilePage(
    userId: int.tryParse(state.pathParameters['userId'] ?? '0') ?? 0,
    loadFromPost: true,
  ),
);

final List<MainPageRouteData> mainPageRoutes = [
  MainPageRouteData(
    Icons.star,
    Icons.star_border,
    'Лента',
    MainPagePaths.feed,
    builder: (_, __) => const FeedScreenView(),
    onReselect: _refresh<FeedScreenViewModel>,
    userTypes: [],
    subroutes: [
      postCommentsRoute,
      pinnedPostsRoute,
      feedUserProfileRoute,
    ],
  ),
  MainPageRouteData(
    Icons.calendar_month,
    Icons.calendar_month_outlined,
    'Расписание',
    MainPagePaths.schedule,
    builder: (_, __) => const ScheduleScreenView(),
    onReselect: _refresh<ScheduleScreenViewModel>,
    userTypes: [],
  ),
  MainPageRouteData(
    Icons.chat,
    Icons.chat_bubble_outline,
    'Сообщения',
    MainPagePaths.chats,
    builder: (_, __) => const ChatScreenView(),
    onReselect: _refresh<ChatScreenViewModel>,
    subroutes: [
      MainPageRouteData(
        Icons.chat,
        Icons.chat,
        'Чат',
        'stored',
        builder: (_, state) => const ChatInside(),
        userTypes: [],
      ),
      MainPageRouteData(
        Icons.chat,
        Icons.chat,
        'Чат',
        ':chatId',
        builder: (_, state) => ChatInside(
          chatId: int.tryParse(state.pathParameters['chatId'] ?? '0') ?? 0,
        ),
        userTypes: [],
      ),
    ],
    isDisabled: false,
    userTypes: [],
  ),
  MainPageRouteData(
    Icons.menu_book,
    Icons.menu_book_outlined,
    'Материалы',
    MainPagePaths.source,
    builder: (_, __) => const SourcePageView(),
    onReselect: _refresh<SourcePageViewModel>,
    isDisabled: false,
    userTypes: [],
  ),
  MainPageRouteData(
    Icons.menu,
    Icons.menu,
    'Ещё',
    MainPagePaths.more,
    builder: (context, _) => MainPageMenu(
      model: context.read<MainPageViewModel>(),
    ),
    userTypes: [],
  ),
  MainPageRouteData(
    Icons.person,
    Icons.person_outline,
    'Мой профиль',
    MainPagePaths.myProfile,
    userTypes: [],
    builder: (_, __) => const ProfilePage(isMe: true),
  ),
  MainPageRouteData(
    Icons.book,
    Icons.book_outlined,
    'Зачётная книжка',
    MainPagePaths.grades,
    builder: (_, __) => const GradesScreenView(),
    userTypes: [StudentData],
  ),
  MainPageRouteData(
    Icons.description,
    Icons.description_outlined,
    'Справки онлайн',
    MainPagePaths.onlineCertificates,
    builder: (_, __) => const OnlineCertificatesScreenView(),
    userTypes: [StudentData],
  ),
  MainPageRouteData(
    Icons.settings,
    Icons.settings_outlined,
    'Настройки',
    MainPagePaths.settings,
    builder: (_, __) => const SettingsScreenView(),
    userTypes: [],
  ),
  MainPageRouteData(
    Icons.credit_card,
    Icons.credit_card_outlined,
    'Поддержать',
    MainPagePaths.donations,
    builder: (_, __) => const DonationsScreenView(),
    userTypes: [],
    onlineOnly: true,
  ),
  MainPageRouteData(
    Icons.info,
    Icons.info_outline,
    'О нас',
    MainPagePaths.about,
    builder: (_, __) => const AboutScreenView(),
    userTypes: [],
  ),
];

void _refresh<T extends BaseViewModel>() {
  final model = Injector.appInstance
      .get<MainPageRoutesViewModelsFactory>()
      .getCached<T>();
  if (model case final MainPageRouteViewModel routeModel) {
    routeModel.refresh();
  }
}

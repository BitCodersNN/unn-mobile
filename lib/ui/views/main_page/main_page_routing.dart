import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/student_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/ui/views/main_page/about/about.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/comments_page.dart';
import 'package:unn_mobile/ui/views/main_page/grades/grades.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/schedule.dart';
import 'package:unn_mobile/ui/views/main_page/settings/settings.dart';
import 'package:unn_mobile/ui/views/main_page/certificates_online/certificates_online.dart';
import 'package:unn_mobile/ui/views/main_page/donations/donations.dart';

class MainPageRouteData {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String pageTitle;
  final String pageRoute;
  final Widget Function(BuildContext) builder;
  final bool isDisabled;
  final List<Type> userTypes;
  final List<MainPageRouteData> subroutes;

  const MainPageRouteData(
    this.selectedIcon,
    this.unselectedIcon,
    this.pageTitle,
    this.pageRoute, {
    this.subroutes = const [],
    this.isDisabled = false,
    required this.userTypes,
    required this.builder,
  });
}

class MainPageRouting {
  static final List<MainPageRouteData> navbarRoutes = [
    MainPageRouteData(
      Icons.star,
      Icons.star_border,
      'Лента',
      '/feed',
      builder: (p0) => const FeedScreenView(),
      userTypes: [
        StudentData,
        EmployeeData,
        UserData,
      ],
      subroutes: [
        MainPageRouteData(
          Icons.comment,
          Icons.comment,
          'Комментарии к записи',
          'comments',
          builder: (p0) => const CommentsPage(),
          isDisabled: false,
          userTypes: [StudentData, EmployeeData, UserData],
        ),
      ],
    ),
    MainPageRouteData(
      Icons.calendar_month,
      Icons.calendar_month_outlined,
      'Расписание',
      '/schedule',
      builder: (p0) => const ScheduleScreenView(),
      userTypes: [StudentData, EmployeeData, UserData],
    ),
    MainPageRouteData(
      Icons.map,
      Icons.map_outlined,
      'Карта',
      '/map',
      builder: (p0) => const Placeholder(),
      isDisabled: true,
      userTypes: [StudentData, EmployeeData, UserData],
    ),
    MainPageRouteData(
      Icons.menu_book,
      Icons.menu_book_outlined,
      'Материалы',
      '/source',
      builder: (p0) => const Placeholder(),
      isDisabled: true,
      userTypes: [StudentData, EmployeeData, UserData],
    ),
  ];

  static final List<MainPageRouteData> drawerRoutes = [
    MainPageRouteData(
      Icons.book,
      Icons.book_outlined,
      'Зачётная книжка',
      'grades',
      builder: (p0) => const GradesScreenView(),
      userTypes: [StudentData],
    ),
    MainPageRouteData(
      Icons.description,
      Icons.description_outlined,
      'Справки онлайн',
      'online_certificates',
      builder: (p0) => const OnlineCertificatesScreenView(),
      userTypes: [],
    ),
    MainPageRouteData(
      Icons.settings,
      Icons.settings_outlined,
      'Настройки',
      'settings',
      builder: (p0) => const SettingsScreenView(),
      userTypes: [StudentData, EmployeeData],
    ),
    MainPageRouteData(
      Icons.credit_card,
      Icons.credit_card_outlined,
      'Поддержать',
      'donations',
      builder: (p0) => const DonationsScreenView(),
      userTypes: [StudentData, EmployeeData, UserData],
    ),
    MainPageRouteData(
      Icons.info,
      Icons.info_outline,
      'О нас',
      'about',
      builder: (p0) => AboutScreenView(),
      userTypes: [StudentData, EmployeeData],
    ),
  ];
  static final List<MainPageRouteData> _activeNavbarRoutes =
      navbarRoutes.where((e) => e.isDisabled == false).toList();

  static List<MainPageRouteData> get activeNavbarRoutes => _activeNavbarRoutes;
}

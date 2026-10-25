// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainPageRouteData {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String pageTitle;
  final String pagePath;
  final Widget Function(BuildContext, GoRouterState) builder;
  final bool isDisabled;
  final List<Type> userTypes;
  final List<MainPageRouteData> subroutes;
  final bool onlineOnly;
  final ValueChanged<BuildContext>? onReselect;

  const MainPageRouteData(
    this.selectedIcon,
    this.unselectedIcon,
    this.pageTitle,
    this.pagePath, {
    required this.userTypes,
    required this.builder,
    this.onlineOnly = false,
    this.onReselect,
    this.subroutes = const [],
    this.isDisabled = false,
  });

  MainPageRouteData copyWith({
    IconData? selectedIcon,
    IconData? unselectedIcon,
    String? pageTitle,
    String? pagePath,
    Widget Function(BuildContext, GoRouterState)? builder,
    bool? isDisabled,
    List<Type>? userTypes,
    List<MainPageRouteData>? subroutes,
    bool? onlineOnly,
    ValueChanged<BuildContext>? onReselect,
  }) =>
      MainPageRouteData(
        selectedIcon ?? this.selectedIcon,
        unselectedIcon ?? this.unselectedIcon,
        pageTitle ?? this.pageTitle,
        pagePath ?? this.pagePath,
        onlineOnly: onlineOnly ?? this.onlineOnly,
        onReselect: onReselect ?? this.onReselect,
        subroutes: subroutes ?? this.subroutes,
        isDisabled: isDisabled ?? this.isDisabled,
        userTypes: userTypes ?? this.userTypes,
        builder: builder ?? this.builder,
      );
}

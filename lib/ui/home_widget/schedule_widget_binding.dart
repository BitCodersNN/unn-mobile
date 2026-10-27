// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';
import 'package:unn_mobile/ui/main_page_locations.dart';
import 'package:unn_mobile/ui/router.dart';

class ScheduleWidgetBinding with WidgetsBindingObserver {
  final ScheduleWidgetService _service;
  final ScheduleWidgetPlatform _platform;
  final CurrentUserSyncStorage _user;
  final AppRouter _router;
  final VoidCallback _onOpen;
  bool _pendingOpen = false;
  bool _disposed = false;
  late bool _useRasp;

  ScheduleWidgetBinding(
    this._service,
    this._platform,
    this._user,
    this._router,
    this._onOpen,
  );

  void start() {
    _useRasp = AppSettings.useRaspSchedule;
    WidgetsBinding.instance.addObserver(this);
    _user.addListener(_refresh);
    _router.router.routerDelegate.addListener(_openIfReady);
    AppSettings.optionsSaved.subscribe(_onSettingsChanged);
    _platform.setOpenHandler(_requestOpen);
    unawaited(_consumeLaunch());
    _refresh();
  }

  Future<void> _consumeLaunch() async {
    if (await _platform.consumeLaunch() && !_disposed) {
      _requestOpen();
    }
  }

  void _requestOpen() {
    _pendingOpen = true;
    _openIfReady();
  }

  void _openIfReady() {
    final path = _router.router.routeInformationProvider.value.uri.path;
    if (!_pendingOpen || !path.startsWith('$mainPageRoute/')) {
      return;
    }
    _pendingOpen = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) {
        return;
      }
      final path = _router.router.routeInformationProvider.value.uri.path;
      if (!path.startsWith('$mainPageRoute/')) {
        _pendingOpen = true;
        return;
      }
      _onOpen();
      _router.goToDestination(MainPagePaths.schedule, initialLocation: true);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _refresh() {
    if (_user.currentUserData != null) {
      unawaited(_service.refresh());
    }
  }

  void _onSettingsChanged(dynamic _) {
    if (_useRasp != AppSettings.useRaspSchedule) {
      _useRasp = AppSettings.useRaspSchedule;
      _refresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_consumeLaunch());
      _refresh();
    }
  }

  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _user.removeListener(_refresh);
    _router.router.routerDelegate.removeListener(_openIfReady);
    AppSettings.optionsSaved.unsubscribe(_onSettingsChanged);
    _platform.setOpenHandler(null);
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/services/interfaces/birthday/birthday_greeting_service.dart';
import 'package:unn_mobile/ui/birthday/birthday_greeting.dart';

class BirthdayGreetingHost extends StatefulWidget {
  final CurrentUserSyncStorage userStorage;
  final BirthdayGreetingService service;
  final bool enabled;
  final Widget child;

  const BirthdayGreetingHost({
    required this.userStorage,
    required this.service,
    required this.enabled,
    required this.child,
    super.key,
  });

  @override
  State<BirthdayGreetingHost> createState() => _BirthdayGreetingHostState();
}

class _BirthdayGreetingHostState extends State<BirthdayGreetingHost>
    with WidgetsBindingObserver {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.userStorage.addListener(_scheduleCheck);
    _scheduleCheck();
  }

  @override
  void didUpdateWidget(BirthdayGreetingHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userStorage != widget.userStorage) {
      oldWidget.userStorage.removeListener(_scheduleCheck);
      widget.userStorage.addListener(_scheduleCheck);
    }
    if (widget.enabled && !oldWidget.enabled ||
        widget.userStorage != oldWidget.userStorage) {
      _scheduleCheck();
    }
  }

  void _scheduleCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_check());
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  bool get _canPresent =>
      mounted &&
      widget.enabled &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed) &&
      (ModalRoute.of(context)?.isCurrent ?? false);

  Future<void> _check() async {
    if (_checking || !_canPresent) {
      return;
    }
    final user = widget.userStorage.currentUserData;
    if (user == null) {
      return;
    }
    _checking = true;
    try {
      await _presentIfEligible(user.userId, DateTime.now());
    } finally {
      _checking = false;
    }
  }

  Future<void> _presentIfEligible(int userId, DateTime date) async {
    final user = widget.userStorage.currentUserData;
    if (user == null || !await widget.service.shouldShow(user, date)) {
      return;
    }
    final now = DateTime.now();
    if (!mounted ||
        !_canPresent ||
        widget.userStorage.currentUserData?.userId != userId ||
        now.year != date.year ||
        now.month != date.month ||
        now.day != date.day) {
      return;
    }
    final service = widget.service;
    await showGeneralDialog<void>(
      context: context,
      routeSettings: const RouteSettings(name: 'birthday-greeting'),
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 450),
      pageBuilder: (context, _, __) => BirthdayGreeting(
        onShown: () => unawaited(service.markShown(userId, date)),
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleCheck();
    }
  }

  @override
  void dispose() {
    widget.userStorage.removeListener(_scheduleCheck);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

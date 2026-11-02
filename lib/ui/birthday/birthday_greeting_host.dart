// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/birthday/birthday_greeting_manager.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/ui/birthday/birthday_greeting.dart';

class BirthdayGreetingHost extends StatefulWidget {
  final CurrentUserSyncStorage userStorage;
  final BirthdayGreetingManager manager;
  final Future<void> Function() onComplete;
  final Widget child;

  const BirthdayGreetingHost({
    required this.userStorage,
    required this.manager,
    required this.onComplete,
    required this.child,
    super.key,
  });

  @override
  State<BirthdayGreetingHost> createState() => _BirthdayGreetingHostState();
}

class _BirthdayGreetingHostState extends State<BirthdayGreetingHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_check());
      }
    });
  }

  bool get _canPresent =>
      mounted &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed) &&
      (ModalRoute.of(context)?.isCurrent ?? false);

  Future<void> _check() async {
    try {
      if (!_canPresent) {
        return;
      }
      final user = widget.userStorage.currentUserData;
      if (user != null) {
        await _presentIfEligible(user.userId, DateTime.now());
      }
    } finally {
      if (mounted) {
        await widget.onComplete();
      }
    }
  }

  Future<void> _presentIfEligible(int userId, DateTime date) async {
    final user = widget.userStorage.currentUserData;
    if (user == null || !await widget.manager.shouldShow(user, date)) {
      return;
    }
    if (!mounted || widget.userStorage.currentUserData?.userId != userId) {
      return;
    }
    final greeting = await widget.manager.getGreeting(userId);
    final now = DateTime.now();
    if (greeting == null ||
        !mounted ||
        !_canPresent ||
        widget.userStorage.currentUserData?.userId != userId ||
        now.year != date.year ||
        now.month != date.month ||
        now.day != date.day) {
      return;
    }
    final manager = widget.manager;
    await showGeneralDialog<void>(
      context: context,
      routeSettings: const RouteSettings(name: 'birthday-greeting'),
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 450),
      pageBuilder: (context, _, _) => BirthdayGreeting(
        greeting: greeting,
        onShown: () => unawaited(manager.markShown(userId, date)),
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

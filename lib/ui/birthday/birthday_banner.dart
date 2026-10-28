// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/birthday/birthday_greeting_manager.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/birthday/birthday_greeting_data.dart';
import 'package:unn_mobile/ui/birthday/birthday_balloon.dart';

class BirthdayBanner extends StatefulWidget {
  final CurrentUserSyncStorage userStorage;
  final BirthdayGreetingManager manager;
  final bool isActive;

  const BirthdayBanner({
    required this.userStorage,
    required this.manager,
    required this.isActive,
    super.key,
  });

  @override
  State<BirthdayBanner> createState() => _BirthdayBannerState();
}

class _BirthdayBannerState extends State<BirthdayBanner>
    with WidgetsBindingObserver {
  Timer? _midnightTimer;
  BirthdayGreetingData? _greeting;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.userStorage.addListener(_loadGreeting);
    _scheduleMidnight();
    _loadGreeting();
  }

  @override
  void didUpdateWidget(BirthdayBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userStorage != widget.userStorage) {
      oldWidget.userStorage.removeListener(_loadGreeting);
      widget.userStorage.addListener(_loadGreeting);
    }
    if (!widget.isActive) {
      _generation++;
    } else if (!oldWidget.isActive ||
        oldWidget.userStorage != widget.userStorage ||
        oldWidget.manager != widget.manager) {
      _loadGreeting();
    }
  }

  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(midnight.difference(now), _refreshDate);
  }

  void _refreshDate() {
    _loadGreeting();
    _scheduleMidnight();
  }

  void _loadGreeting() {
    final generation = ++_generation;
    if (!widget.isActive) {
      return;
    }
    final user = widget.userStorage.currentUserData;
    if (user == null || !widget.manager.isBirthday(user, DateTime.now())) {
      setState(() => _greeting = null);
      return;
    }
    unawaited(_selectGreeting(user.userId, generation));
  }

  Future<void> _selectGreeting(int userId, int generation) async {
    final greeting = await widget.manager.getGreeting(
      userId,
      previousId: _greeting?.id,
    );
    if (!mounted || generation != _generation || !widget.isActive) {
      return;
    }
    final user = widget.userStorage.currentUserData;
    if (user?.userId != userId ||
        user == null ||
        !widget.manager.isBirthday(user, DateTime.now())) {
      setState(() => _greeting = null);
      return;
    }
    setState(() => _greeting = greeting);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDate();
    } else {
      _generation++;
      _midnightTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    widget.userStorage.removeListener(_loadGreeting);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _greeting == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _BirthdayCard(greeting: _greeting!),
        );
}

class _BirthdayCard extends StatelessWidget {
  final BirthdayGreetingData greeting;

  const _BirthdayCard({required this.greeting});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(colors.surface, colors.primaryContainer, 0.65)!,
              Color.lerp(colors.surface, colors.tertiaryContainer, 0.45)!,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showBalloons = constraints.maxWidth >= 290 &&
                  MediaQuery.textScalerOf(context).scale(20) <= 28;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          greeting.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          greeting.shortMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showBalloons) ...[
                    const SizedBox(width: 12),
                    const ExcludeSemantics(
                      child: CustomPaint(
                        size: Size(72, 100),
                        painter: _BirthdayCardBalloons(),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BirthdayCardBalloons extends CustomPainter {
  const _BirthdayCardBalloons();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(size.width * 0.72, size.height * 0.48)
      ..rotate(0.18);
    paintBirthdayBalloon(
      canvas,
      width: 34,
      height: 43,
      color: const Color(0xFFF2B8A2),
    );
    canvas
      ..restore()
      ..save()
      ..translate(size.width * 0.32, size.height * 0.3)
      ..rotate(-0.16);
    paintBirthdayBalloon(
      canvas,
      width: 38,
      height: 48,
      color: const Color(0xFF71CFC0),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BirthdayCardBalloons oldDelegate) => false;
}

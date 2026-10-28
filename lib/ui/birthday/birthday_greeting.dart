// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/ui/birthday/birthday_balloons.dart';

class BirthdayGreeting extends StatefulWidget {
  final VoidCallback onShown;

  const BirthdayGreeting({required this.onShown, super.key});

  @override
  State<BirthdayGreeting> createState() => _BirthdayGreetingState();
}

class _BirthdayGreetingState extends State<BirthdayGreeting>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..addListener(_onAnimation);
  late final CurvedAnimation _reveal = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.32, 0.82, curve: Curves.easeOutCubic),
  );
  static const _hapticMoments = [0.06, 0.2, 0.36, 0.55];
  int _nextHaptic = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onShown();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _nextHaptic = _hapticMoments.length;
      _controller.value = 1;
    } else if (!_started) {
      _controller.forward();
    }
    _started = true;
  }

  void _onAnimation() {
    if (_nextHaptic < _hapticMoments.length &&
        _controller.value >= _hapticMoments[_nextHaptic]) {
      _nextHaptic++;
      triggerHaptic(HapticIntensity.light);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller.value < 1) {
        _controller.forward();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reveal.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFF8FAF7),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.25),
                  radius: 1.15,
                  colors: [Color(0xFFE5F4EF), Color(0xFFFAF5EF)],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeTransition(
                  opacity: _reveal,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(_reveal),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFFB89050),
                              size: 36,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'С днём\nрождения!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w700,
                                    height: 1.13,
                                    letterSpacing: -1.5,
                                    color: const Color(0xFF244D46),
                                  ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Пусть впереди будет много радостных открытий, '
                              'тёплых встреч и поводов гордиться собой.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.55,
                                color: Color(0xFF5B756F),
                              ),
                            ),
                            const SizedBox(height: 36),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF286F62),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Спасибо!'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: BirthdayBalloons(_controller)),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: IconButton(
                    tooltip: 'Закрыть поздравление',
                    onPressed: () => Navigator.of(context).pop(),
                    color: const Color(0xFF5B756F),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

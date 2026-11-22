// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/models/giveaway_promo/announcement_catalog.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class DefaultEntranceFrame {
  final double opacity;
  final double scale;
  final double dy;

  const DefaultEntranceFrame({
    required this.opacity,
    required this.scale,
    required this.dy,
  });
}

class F1TowFrame {
  final double cardDy;
  final double cableGap;
  final double wheelAngle;
  final double speedIntensity;
  final double slipIntensity;
  final double carShakeDx;
  final double towOpacity;

  const F1TowFrame({
    required this.cardDy,
    required this.cableGap,
    required this.wheelAngle,
    required this.speedIntensity,
    required this.slipIntensity,
    required this.carShakeDx,
    required this.towOpacity,
  });
}

class GiveawayPromoViewModel extends BaseViewModel {
  static const wheelspinStart = 0.22;
  static const wheelspinEnd = 0.50;
  static const wheelspinHapticStep = 0.032;
  static const f1TowDuration = Duration(milliseconds: 3600);
  static const defaultAnimationDuration = Duration(milliseconds: 420);

  final AnnouncementCategory category;
  final AnnouncementAnimation animation;
  final String? badge;
  final String title;
  final String body;
  final String? actionLabel;
  final String? telegramUrl;
  final String? actionUrl;
  final List<ImageProvider> images;
  final VoidCallback? onShown;
  final FutureOr<void> Function()? onTelegramTap;
  final FutureOr<void> Function()? onDismissed;
  final Future<bool> Function(String url) onOpenUrl;

  double _nextWheelspinHapticT = wheelspinStart;
  bool _shownNotified = false;
  bool _closing = false;
  bool _isSubmitting = false;
  bool _actionCompleted = false;
  bool _dismissNotified = false;

  GiveawayPromoViewModel({
    required this.onOpenUrl,
    this.category = AnnouncementCategory.giveaway,
    this.animation = AnnouncementAnimation.f1Tow,
    this.badge,
    this.title = '',
    this.body = '',
    this.actionLabel,
    this.telegramUrl,
    this.actionUrl,
    this.images = const [],
    this.onShown,
    this.onTelegramTap,
    this.onDismissed,
  });

  bool get isF1Tow => animation == AnnouncementAnimation.f1Tow;

  Duration get animationDuration =>
      isF1Tow ? f1TowDuration : defaultAnimationDuration;

  String? get trimmedBadge => _trimOrNull(badge);

  bool get hasBadge => trimmedBadge != null;

  String? get trimmedActionLabel => _trimOrNull(actionLabel);

  String? get effectiveActionUrl => _trimOrNull(actionUrl ?? telegramUrl);

  bool get hasAction =>
      trimmedActionLabel != null && effectiveActionUrl != null;

  bool get isSubmitting => _isSubmitting;

  bool get isClosing => _closing;

  void notifyShown() {
    if (_shownNotified) {
      return;
    }
    _shownNotified = true;
    onShown?.call();
  }

  void markAnimationsDisabled() {
    _nextWheelspinHapticT = wheelspinEnd + wheelspinHapticStep;
  }

  bool consumeWheelspinHapticTick(
    double t, {
    required bool isAnimating,
    required bool disableAnimations,
  }) {
    if (!isF1Tow || !isAnimating || _closing || disableAnimations) {
      return false;
    }
    if (t < wheelspinStart || t > wheelspinEnd || t < _nextWheelspinHapticT) {
      return false;
    }
    do {
      _nextWheelspinHapticT += wheelspinHapticStep;
    } while (_nextWheelspinHapticT <= t &&
        _nextWheelspinHapticT <= wheelspinEnd);
    return true;
  }

  Future<bool> submitAction() async {
    if (_isSubmitting || _closing) {
      return false;
    }
    _isSubmitting = true;
    notifyListeners();
    final succeeded = await _tryPerformAction();
    if (succeeded) {
      _actionCompleted = true;
      return true;
    }
    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  bool beginClose() {
    if (_closing) {
      return false;
    }
    _closing = true;
    _notifyDismissedIfNeeded();
    return true;
  }

  void handleRoutePopped() {
    _closing = true;
    _notifyDismissedIfNeeded();
  }

  F1TowFrame computeChoreography({
    required double t,
    required double viewportHeight,
    required double carHeight,
  }) {
    final pullDistance = viewportHeight * 0.78 + 120.0;
    final towOpacity = t <= 0.82
        ? 1.0
        : (1.0 - ((t - 0.82) / 0.10).clamp(0.0, 1.0));

    final double cardProgress;
    final double cableGap;
    final double wheelAngle;
    final double speedIntensity;
    var slipIntensity = 0.0;
    var carShakeDx = 0.0;

    if (t <= 0.22) {
      // Phase 1: Car emerges from the bottom edge pulling the tow cable taut.
      final u = (t / 0.22).clamp(0.0, 1.0);
      final ease = Curves.easeOutQuad.transform(u);
      cardProgress = ease * 0.28;
      cableGap = 44.0 + 24.0 * ease;
      wheelAngle = u * 8.0;
      speedIntensity = 0.55 * (1.0 - 0.5 * u);
    } else if (t <= 0.50) {
      // Phase 2: Wheelspin / struggle as the heavy card enters the viewport.
      final u = ((t - 0.22) / 0.28).clamp(0.0, 1.0);
      cardProgress = 0.28 + u * 0.14;
      slipIntensity = math.sin(u * math.pi);
      final cableStretch = math.sin(u * 6.0 * math.pi) * 1.2 * slipIntensity;
      cableGap = 68.0 + 8.0 * u + cableStretch;
      carShakeDx = math.sin(t * 110.0) * 2.5 * slipIntensity;
      wheelAngle = 8.0 + u * 26.0;
      speedIntensity = 0.275 * (1.0 - slipIntensity) + 0.15 * slipIntensity;
    } else if (t <= 0.82) {
      // Phase 3: Car regains traction and pulls the card to center.
      final u = ((t - 0.50) / 0.32).clamp(0.0, 1.0);
      final ease = Curves.easeInOutCubic.transform(u);
      cardProgress = 0.42 + ease * 0.58;
      cableGap = 76.0 - 24.0 * ease;
      wheelAngle = 34.0 + u * 12.0;
      speedIntensity = 0.275 + 0.45 * math.sin(u * math.pi);
    } else {
      // Phase 4: Tow cable detaches and car accelerates off the top edge.
      final u = ((t - 0.82) / 0.18).clamp(0.0, 1.0);
      final exitProgress = Curves.easeInCubic.transform(u);
      cardProgress = 1.0;
      cableGap =
          52.0 + exitProgress * (viewportHeight * 0.75 + carHeight + 80.0);
      wheelAngle = 46.0 + exitProgress * 14.0;
      speedIntensity = 0.275 + 0.725 * exitProgress;
    }

    return F1TowFrame(
      cardDy: (1.0 - cardProgress) * pullDistance,
      cableGap: cableGap,
      wheelAngle: wheelAngle,
      speedIntensity: speedIntensity,
      slipIntensity: slipIntensity,
      carShakeDx: carShakeDx,
      towOpacity: towOpacity,
    );
  }

  double computeDefaultEntranceProgress(double t) =>
      Curves.easeOutQuart.transform(t.clamp(0.0, 1.0));

  DefaultEntranceFrame computeDefaultEntranceFrame(double t) {
    final clamped = t.clamp(0.0, 1.0);
    final motion = computeDefaultEntranceProgress(clamped);
    final opacity = Curves.easeOutCubic.transform(
      (clamped / 0.75).clamp(0.0, 1.0),
    );
    return DefaultEntranceFrame(
      opacity: opacity,
      scale: 0.92 + 0.08 * motion,
      dy: 18.0 * (1.0 - motion),
    );
  }

  Future<bool> _tryPerformAction() async {
    try {
      return await _performAction();
    } catch (_) {
      return false;
    }
  }

  Future<bool> _performAction() async {
    final url = effectiveActionUrl;
    if (url == null) {
      return false;
    }
    await onTelegramTap?.call();
    await onOpenUrl(url);
    return true;
  }

  void _notifyDismissedIfNeeded() {
    if (!_actionCompleted && !_dismissNotified) {
      _dismissNotified = true;
      unawaited(Future<void>.sync(() => onDismissed?.call()));
    }
  }

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

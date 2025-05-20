import 'package:flutter/services.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';

enum HapticIntensity {
  selection,
  light,
  medium,
  heavy,
  vibrate,
}

final _hapticHandlers = {
  HapticIntensity.selection: () => HapticFeedback.selectionClick(),
  HapticIntensity.light: () => HapticFeedback.lightImpact(),
  HapticIntensity.medium: () => HapticFeedback.mediumImpact(),
  HapticIntensity.heavy: () => HapticFeedback.heavyImpact(),
  HapticIntensity.vibrate: () => HapticFeedback.vibrate(),
};

void triggerHaptic(HapticIntensity intensity) {
  if (!AppSettings.vibrationEnabled) return;

  _hapticHandlers[intensity]?.call() ??
      _hapticHandlers[HapticIntensity.light]!();
}

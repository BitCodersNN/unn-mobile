// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:ui';

import 'package:flutter/foundation.dart';

enum PaletteCategory { base, schedule, grades, effects }

enum PaletteColorSlot {
  surface(PaletteCategory.base),
  cardSurface(PaletteCategory.base),
  importantPostHighlight(PaletteCategory.base),
  primary(PaletteCategory.base),
  secondary(PaletteCategory.base),
  onSurface(PaletteCategory.base),
  onSurfaceVariant(PaletteCategory.base),
  outlineVariant(PaletteCategory.base),
  wideButtonBottom(PaletteCategory.base),
  scheduleDayHighlight(PaletteCategory.schedule),
  scheduleSubjectHighlight(PaletteCategory.schedule),
  subjectLecture(PaletteCategory.schedule),
  subjectPractice(PaletteCategory.schedule),
  subjectLab(PaletteCategory.schedule),
  subjectExam(PaletteCategory.schedule),
  subjectConsult(PaletteCategory.schedule),
  subjectUnknown(PaletteCategory.schedule),
  markExcellent(PaletteCategory.grades),
  markGood(PaletteCategory.grades),
  markSatisfactory(PaletteCategory.grades),
  markUnsatisfactory(PaletteCategory.grades),
  markCredited(PaletteCategory.grades),
  markNoShow(PaletteCategory.grades),
  shimmerBase(PaletteCategory.effects),
  shimmerHighlight(PaletteCategory.effects);

  final PaletteCategory category;

  const PaletteColorSlot(this.category);

  bool get isBaseAccent =>
      this == PaletteColorSlot.primary || this == PaletteColorSlot.secondary;
}

abstract final class _JsonKeys {
  static const primary = 'primary';
  static const secondary = 'secondary';
  static const overrides = 'overrides';
}

@immutable
class CustomPaletteConfig {
  static const Color defaultLightPrimary = Color(0xFF00BBB0);
  static const Color defaultLightSecondary = Color(0xFF006254);
  static const Color defaultDarkPrimary = Color(0xFF529388);
  static const Color defaultDarkSecondary = Color(0xFF3B766C);

  final Color primary;
  final Color secondary;
  final Map<PaletteColorSlot, Color> overrides;

  CustomPaletteConfig({
    required this.primary,
    required this.secondary,
    Map<PaletteColorSlot, Color> overrides = const {},
  }) : overrides = Map.unmodifiable(
         Map.fromEntries(
           overrides.entries.where((entry) => !entry.key.isBaseAccent),
         ),
       );

  factory CustomPaletteConfig.defaultLight() => CustomPaletteConfig(
    primary: defaultLightPrimary,
    secondary: defaultLightSecondary,
  );

  factory CustomPaletteConfig.defaultDark() => CustomPaletteConfig(
    primary: defaultDarkPrimary,
    secondary: defaultDarkSecondary,
  );

  Color? overrideOf(PaletteColorSlot slot) => switch (slot) {
    PaletteColorSlot.primary => primary,
    PaletteColorSlot.secondary => secondary,
    _ => overrides[slot],
  };

  bool isCustomized(PaletteColorSlot slot) =>
      slot.isBaseAccent || overrides.containsKey(slot);

  CustomPaletteConfig withSlotColor(PaletteColorSlot slot, Color color) =>
      switch (slot) {
        PaletteColorSlot.primary => CustomPaletteConfig(
          primary: color,
          secondary: secondary,
          overrides: overrides,
        ),
        PaletteColorSlot.secondary => CustomPaletteConfig(
          primary: primary,
          secondary: color,
          overrides: overrides,
        ),
        _ => CustomPaletteConfig(
          primary: primary,
          secondary: secondary,
          overrides: {...overrides, slot: color},
        ),
      };

  CustomPaletteConfig clearSlot(PaletteColorSlot slot) {
    if (slot.isBaseAccent || !overrides.containsKey(slot)) {
      return this;
    }
    final updated = Map<PaletteColorSlot, Color>.from(overrides)..remove(slot);
    return CustomPaletteConfig(
      primary: primary,
      secondary: secondary,
      overrides: updated,
    );
  }

  Map<String, Object?> toJson() => {
    _JsonKeys.primary: primary.toARGB32(),
    _JsonKeys.secondary: secondary.toARGB32(),
    if (overrides.isNotEmpty)
      _JsonKeys.overrides: {
        for (final entry in overrides.entries)
          entry.key.name: entry.value.toARGB32(),
      },
  };

  static CustomPaletteConfig? tryFromJson(Object? raw) {
    if (raw is! Map<Object?, Object?>) {
      return null;
    }
    final primaryValue = raw[_JsonKeys.primary];
    final secondaryValue = raw[_JsonKeys.secondary];
    if (primaryValue is! int || secondaryValue is! int) {
      return null;
    }
    final overridesRaw = raw[_JsonKeys.overrides];
    final parsedOverrides = <PaletteColorSlot, Color>{};
    if (overridesRaw != null) {
      if (overridesRaw is! Map<Object?, Object?>) {
        return null;
      }
      for (final entry in overridesRaw.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || value is! int) {
          continue;
        }
        final slot = PaletteColorSlot.values
            .where((candidate) => candidate.name == key)
            .firstOrNull;
        if (slot != null && !slot.isBaseAccent) {
          parsedOverrides[slot] = _opaqueColor(value);
        }
      }
    }
    return CustomPaletteConfig(
      primary: _opaqueColor(primaryValue),
      secondary: _opaqueColor(secondaryValue),
      overrides: parsedOverrides,
    );
  }

  static Color _opaqueColor(int value) =>
      Color(0xFF000000 | (value & 0xFFFFFF));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPaletteConfig &&
          primary == other.primary &&
          secondary == other.secondary &&
          mapEquals(overrides, other.overrides);

  @override
  int get hashCode => Object.hash(
    primary,
    secondary,
    Object.hashAllUnordered(
      overrides.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

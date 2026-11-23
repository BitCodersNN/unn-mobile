// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PaletteCategory {
  base('База'),
  schedule('Расписание'),
  grades('Зачётка'),
  effects('Эффекты');

  final String label;

  const PaletteCategory(this.label);
}

enum PaletteColorSlot {
  surface(PaletteCategory.base, 'Фон экрана'),
  cardSurface(PaletteCategory.base, 'Карточки'),
  importantPostHighlight(PaletteCategory.base, 'Важный пост'),
  primary(PaletteCategory.base, 'Основной акцент'),
  secondary(PaletteCategory.base, 'Доп. акцент'),
  onSurface(PaletteCategory.base, 'Основной текст'),
  onSurfaceVariant(PaletteCategory.base, 'Вторичный текст'),
  outlineVariant(PaletteCategory.base, 'Разделители'),
  wideButtonBottom(PaletteCategory.base, 'Низ кнопки'),
  scheduleDayHighlight(PaletteCategory.schedule, 'Подсветка дня'),
  scheduleSubjectHighlight(PaletteCategory.schedule, 'Текущая пара'),
  subjectLecture(PaletteCategory.schedule, 'Лекция'),
  subjectPractice(PaletteCategory.schedule, 'Практика'),
  subjectLab(PaletteCategory.schedule, 'Лабораторная'),
  subjectExam(PaletteCategory.schedule, 'Экзамен'),
  subjectConsult(PaletteCategory.schedule, 'Консультация'),
  subjectUnknown(PaletteCategory.schedule, 'Другое'),
  markExcellent(PaletteCategory.grades, 'Отлично'),
  markGood(PaletteCategory.grades, 'Хорошо'),
  markSatisfactory(PaletteCategory.grades, 'Удовлетворительно'),
  markUnsatisfactory(PaletteCategory.grades, 'Неудовлетворительно'),
  markCredited(PaletteCategory.grades, 'Зачтено'),
  markNoShow(PaletteCategory.grades, 'Неявка'),
  shimmerBase(PaletteCategory.effects, 'База шиммера'),
  shimmerHighlight(PaletteCategory.effects, 'Блик шиммера');

  final PaletteCategory category;
  final String label;

  const PaletteColorSlot(this.category, this.label);

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
    primary: const Color(0xFF00BBB0),
    secondary: const Color(0xFF006254),
  );

  factory CustomPaletteConfig.defaultDark() => CustomPaletteConfig(
    primary: const Color(0xFF529388),
    secondary: const Color(0xFF3B766C),
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
          parsedOverrides[slot] = Color(value);
        }
      }
    }
    return CustomPaletteConfig(
      primary: Color(primaryValue),
      secondary: Color(secondaryValue),
      overrides: parsedOverrides,
    );
  }

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

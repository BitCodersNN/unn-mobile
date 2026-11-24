// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/models/common/custom_palette_config.dart';

extension PaletteCategoryLabel on PaletteCategory {
  String get label => switch (this) {
    PaletteCategory.base => 'База',
    PaletteCategory.schedule => 'Расписание',
    PaletteCategory.grades => 'Зачётка',
    PaletteCategory.effects => 'Эффекты',
  };
}

extension PaletteColorSlotLabel on PaletteColorSlot {
  String get label => switch (this) {
    PaletteColorSlot.surface => 'Фон экрана',
    PaletteColorSlot.cardSurface => 'Карточки',
    PaletteColorSlot.importantPostHighlight => 'Важный пост',
    PaletteColorSlot.primary => 'Основной акцент',
    PaletteColorSlot.secondary => 'Доп. акцент',
    PaletteColorSlot.onSurface => 'Основной текст',
    PaletteColorSlot.onSurfaceVariant => 'Вторичный текст',
    PaletteColorSlot.outlineVariant => 'Разделители',
    PaletteColorSlot.wideButtonBottom => 'Низ кнопки',
    PaletteColorSlot.subjectLecture => 'Лекция',
    PaletteColorSlot.subjectPractice => 'Практика',
    PaletteColorSlot.subjectLab => 'Лабораторная',
    PaletteColorSlot.subjectExam => 'Экзамен',
    PaletteColorSlot.subjectConsult => 'Консультация',
    PaletteColorSlot.subjectUnknown => 'Другое',
    PaletteColorSlot.markExcellent => 'Отлично',
    PaletteColorSlot.markGood => 'Хорошо',
    PaletteColorSlot.markSatisfactory => 'Удовлетворительно',
    PaletteColorSlot.markUnsatisfactory => 'Неудовлетворительно',
    PaletteColorSlot.markCredited => 'Зачтено',
    PaletteColorSlot.markNoShow => 'Неявка',
    PaletteColorSlot.shimmerBase => 'База шиммера',
    PaletteColorSlot.shimmerHighlight => 'Блик шиммера',
  };
}

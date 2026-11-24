// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/core/models/schedule/subject_type.dart';
import 'package:unn_mobile/ui/theme/palette_slot_labels.dart';

@immutable
class SchedulePreviewSample {
  final SubjectType type;
  final PaletteColorSlot slot;
  final String title;
  final String startTime;
  final String endTime;
  final String room;
  final bool isCurrent;

  const SchedulePreviewSample({
    required this.type,
    required this.slot,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.isCurrent = false,
  });

  String get scheduleSubtitle => '$startTime–$endTime · ${slot.label} · $room';

  String get compactScheduleSubtitle => '$startTime–$endTime · $room';

  String get widgetSubtitle => '${isCurrent ? 'Сейчас' : slot.label} · $room';
}

const List<SchedulePreviewSample> schedulePreviewSamples = [
  SchedulePreviewSample(
    type: SubjectType.lecture,
    slot: PaletteColorSlot.subjectLecture,
    title: 'Математический анализ',
    startTime: '09:00',
    endTime: '10:30',
    room: 'Ауд. 214',
    isCurrent: true,
  ),
  SchedulePreviewSample(
    type: SubjectType.practice,
    slot: PaletteColorSlot.subjectPractice,
    title: 'Дискретная математика',
    startTime: '10:40',
    endTime: '12:10',
    room: 'Ауд. 305',
  ),
  SchedulePreviewSample(
    type: SubjectType.lab,
    slot: PaletteColorSlot.subjectLab,
    title: 'Программирование',
    startTime: '12:20',
    endTime: '13:50',
    room: 'К. 2-410',
  ),
  SchedulePreviewSample(
    type: SubjectType.exam,
    slot: PaletteColorSlot.subjectExam,
    title: 'Алгоритмы и структуры',
    startTime: '14:10',
    endTime: '15:40',
    room: 'Ауд. 112',
  ),
  SchedulePreviewSample(
    type: SubjectType.consult,
    slot: PaletteColorSlot.subjectConsult,
    title: 'Линейная алгебра',
    startTime: '15:50',
    endTime: '17:20',
    room: 'Ауд. 208',
  ),
  SchedulePreviewSample(
    type: SubjectType.unknown,
    slot: PaletteColorSlot.subjectUnknown,
    title: 'Научный семинар',
    startTime: '17:30',
    endTime: '19:00',
    room: 'Ауд. 402',
  ),
];

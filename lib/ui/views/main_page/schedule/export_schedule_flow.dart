// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_range_type.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/export_schedule_service.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/widgets/dialogs/message_dialog.dart';

Future<void> runExportFlow(
  BuildContext context,
  ScheduleScreenViewModel model,
) async {
  final permission = await model.askForExportPermission();

  if (permission == RequestCalendarPermissionResult.permanentlyDenied) {
    if (context.mounted) {
      final result = await showOkCancelAlertDialog(
        context: context,
        title: 'Доступ к календарю',
        message:
            'Приложению запрещён доступ к календарю. Разрешите его в настройках, чтобы экспортировать расписание.',
        okLabel: 'Настройки',
        cancelLabel: 'Отмена',
      );
      if (result == OkCancelResult.ok && context.mounted) {
        await model.openSettingsWindow();
      }
    }
    return;
  }

  if (permission != RequestCalendarPermissionResult.allowed) {
    return;
  }
  if (!context.mounted) {
    return;
  }

  final actions = DateTimeRangeType.values
      .map(
        (type) => AlertDialogAction<DateTimeRangeType>(
          key: type,
          label: type.label,
          isDefaultAction: type == DateTimeRangeType.untilEndOfWeek,
        ),
      )
      .toList();

  final selectedType = await showConfirmationDialog<DateTimeRangeType>(
    context: context,
    title: 'Экспортировать расписание',
    actions: actions,
    cancelLabel: 'Отмена',
  );
  if (selectedType == null) {
    return;
  }

  final result = await model.exportSchedule(selectedType);
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Экспорт завершён'),
    ),
  );

  if (Platform.isAndroid) {
    await showMessage(
      context,
      result
          ? 'Расписание экспортировано в календарь "Расписание ННГУ". \n'
              'Возможно, понадобится включить настройку Device Calendar в приложении календаря.'
          : 'Не удалось экспортировать. Попробуйте снова.',
      messageKey: result ? 'export_schedule_success' : null,
    );
  }
}

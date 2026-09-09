// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/services/interfaces/common/message_ignore_service.dart';

Future<void> showAnalyticsConfirmation(BuildContext context) async {
  const analyticsConfirmKey = 'analyticsConfirmationShown';
  final messageIgnoreService = Injector.appInstance.get<MessageIgnoreService>();

  if (await messageIgnoreService.isMessageIgnored(analyticsConfirmKey)) {
    return;
  }

  if (!context.mounted) {
    return;
  }

  final result = await showAlertDialog<bool>(
    context: context,
    title: 'Телеметрия',
    message:
        'Приложение использует сервисы Firebase Crashlytics и Firebase Analytics '
        'для сбора данных о сбоях в приложении с целью их последующего исправления, '
        'а также для получения обобщённой анонимной информации о действиях в приложении.\n'
        'Вы можете отказаться от этого (изменить решение можно будет в настройках приложения)',
    actions: [
      const AlertDialogAction<bool>(
        key: false,
        label: 'Отказаться',
        isDestructiveAction: true,
      ),
      const AlertDialogAction<bool>(
        key: true,
        label: 'ОК',
        isDefaultAction: true,
      ),
    ],
  );

  if (result != null) {
    AppSettings.analyticsEnabled = result;
  }

  await Future.wait([
    AppSettings.save(),
    messageIgnoreService.addIgnoreMessageKey(analyticsConfirmKey),
  ]);
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/services/interfaces/common/message_ignore_service.dart';
import 'package:unn_mobile/ui/widgets/adaptive_dialog_action.dart';

class AnalyticsConfirmDialog extends StatelessWidget {
  const AnalyticsConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: const Text('Телеметрия'),
        content: const Text(
            'Приложение использует сервисы Firebase Crashlytics и Firebase Analytics '
            'для сбора данных о сбоях в приложении с целью их последующего исправления, '
            'а также для получения обобщённой анонимной информации о действиях в приложении.\n'
            'Вы можете отказаться от этого (изменить решение можно будет в настройках приложения)'),
        actions: [
          AdaptiveDialogAction(
            onPressed: () {
              Navigator.of(context).pop<bool>(false);
            },
            child: const Text('Отказаться'),
          ),
          AdaptiveDialogAction(
            onPressed: () {
              Navigator.of(context).pop<bool>(true);
            },
            child: const Text('ОК'),
          ),
        ],
      );
}

Future<void> showAnalyticsConfirmation(BuildContext context) async {
  const analyticsConfirmKey = 'analyticsConfirmationShown';
  final messageIgnoreService = Injector.appInstance.get<MessageIgnoreService>();

  if (await messageIgnoreService.isMessageIgnored(analyticsConfirmKey)) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const AnalyticsConfirmDialog(),
  );

  if (result != null) {
    AppSettings.analyticsEnabled = result;
  }

  await Future.wait([
    AppSettings.save(),
    messageIgnoreService.addIgnoreMessageKey(analyticsConfirmKey),
  ]);
}

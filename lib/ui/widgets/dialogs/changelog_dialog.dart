// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:unn_mobile/core/constants/changelog.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/ui/widgets/adaptive_dialog_action.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Список изменений: '),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: SingleChildScrollView(
              child: Text(changelogString),
            ),
          ),
          const Divider(),
          BBCodeText(
            data:
                'Также, подписывайтесь на наш [URL=https://t.me/unn_mobile]Telegram-канал[/URL]',
            stylesheet: getBBStyleSheet(),
          ),
        ],
      ),
      actions: [
        AdaptiveDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

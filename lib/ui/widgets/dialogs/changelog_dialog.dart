// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:unn_mobile/core/constants/changelog.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: const Text('Список изменений'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: BBCodeText(
                  data: changelogString,
                  stylesheet: getBBStyleSheet(),
                ),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
}

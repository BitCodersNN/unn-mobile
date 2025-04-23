// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/common/message_ignore_service.dart';
import 'package:unn_mobile/ui/widgets/adaptive_dialog_action.dart';

class MessageDialog extends StatefulWidget {
  const MessageDialog({
    super.key,
    required this.message,
    this.canBeIgnored = false,
    this.messageKey = '',
  });

  final Widget message;

  final String messageKey;
  final bool canBeIgnored;

  @override
  State<MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  bool ignoreCheckbox = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      content: SingleChildScrollView(
        child: Column(
          children: [
            widget.message,
            if (widget.canBeIgnored && widget.messageKey.isNotEmpty)
              Row(
                children: [
                  Checkbox(
                    value: ignoreCheckbox,
                    onChanged: (value) {
                      setState(() {
                        ignoreCheckbox = value ?? false;
                      });
                    },
                  ),
                  const Text('Больше не показывать'),
                ],
              ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      buttonPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actions: <Widget>[
        AdaptiveDialogAction(
          child: const Text('OK'),
          onPressed: () async {
            Navigator.of(context).pop<bool>(ignoreCheckbox);
          },
        ),
      ],
    );
  }
}

/// Показывает сообщение. Параметр [messageKey] присваивает данному
/// сообщению ключ, что позволит пользователю отключить показ такого сообщения
/// в следующие разы.
Future<void> showMessage(
  BuildContext context,
  String text, {
  String? messageKey,
}) async {
  final MessageIgnoreService messageIgnoreService =
      Injector.appInstance.get<MessageIgnoreService>();
  if (messageKey != null &&
      await messageIgnoreService.isMessageIgnored(messageKey)) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final ignoredNow = await showDialog(
    context: context,
    builder: (context) {
      return MessageDialog(
        message: Text(
          text,
          textAlign: TextAlign.center,
        ),
        messageKey: messageKey ?? '',
        canBeIgnored: messageKey != null,
      );
    },
  );
  if (messageKey != null && ignoredNow) {
    await messageIgnoreService.addIgnoreMessageKey(messageKey);
  }
}

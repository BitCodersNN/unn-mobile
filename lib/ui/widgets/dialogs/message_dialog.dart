import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/adaptive_dialog_action.dart';

class MessageDialog extends StatelessWidget {
  const MessageDialog({
    super.key,
    required this.message,
  });

  final Text message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      content: message,
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      buttonPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actions: <Widget>[
        AdaptiveDialogAction(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

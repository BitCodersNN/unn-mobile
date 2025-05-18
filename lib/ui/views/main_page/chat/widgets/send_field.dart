// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_inside_view_model.dart';

class SendField extends StatefulWidget {
  const SendField({
    super.key,
    required this.model,
  });

  final ChatInsideViewModel model;

  @override
  State<SendField> createState() => _SendFieldState();
}

class _SendFieldState extends State<SendField> {
  late TextEditingController _textController;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.attach_file),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
            child: TextField(
              controller: _textController,
              autocorrect: true,
              enableSuggestions: true,
              enabled: !widget.model.isBusy,
              decoration: const InputDecoration(hintText: 'Текст сообщения'),
            ),
          ),
        ),
        IconButton(
          onPressed: widget.model.isBusy
              ? null //
              : () async {
                  final text = _textController.text;
                  if (text.isEmpty) {
                    return;
                  }
                  _textController.text = '';
                  if (!await widget.model.sendMessage(text)) {
                    _textController.text = text;
                  }
                },
          color: theme.primaryColorDark,
          disabledColor: theme.disabledColor,
          icon: const Icon(
            Icons.send,
          ),
        ),
      ],
    );
  }
}

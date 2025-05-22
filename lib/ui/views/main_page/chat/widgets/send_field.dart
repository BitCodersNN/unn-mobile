// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';
import 'package:unn_mobile/core/models/dialog/message/reply_info.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_inside_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/chat/widgets/message.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        if (widget.model.replyMessage != null)
          Row(
            children: [
              Expanded(
                child: MessageWidget.buildReplyMessage(
                  context,
                  ReplyInfo(
                    replyMessage: widget.model.replyMessage!,
                    messageStatus: widget.model.replyMessage!.messageStatus,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.model.replyMessage = null;
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                final files = await showModalBottomSheet<Iterable<String>?>(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Выбрать из галереи'),
                          leading: const Icon(Icons.image),
                          onTap: () async {
                            final files = await openUploadFilePicker(true);
                            if (context.mounted) {
                              GoRouter.of(context).pop(files);
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Выбрать файл'),
                          leading: const Icon(Icons.file_present_rounded),
                          onTap: () async {
                            final files = await openUploadFilePicker(false);
                            if (context.mounted) {
                              GoRouter.of(context).pop(files);
                            }
                          },
                        ),
                      ],
                    );
                  },
                );

                if (files == null || files.isEmpty) {
                  return;
                }
                final text = _textController.text;
                _textController.text = '';
                if (!await widget.model.sendFiles(
                  files,
                  text: text.isEmpty ? null : text,
                )) {
                  _textController.text = text;
                }
              },
              icon: const Icon(Icons.attach_file),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0).copyWith(top: 0),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  autocorrect: true,
                  enableSuggestions: true,
                  enabled: !widget.model.isBusy,
                  decoration:
                      const InputDecoration(hintText: 'Текст сообщения'),
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
        ),
      ],
    );
  }
}

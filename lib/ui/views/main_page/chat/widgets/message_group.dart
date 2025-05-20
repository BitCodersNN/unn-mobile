// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_inside_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat_inside.dart';
import 'package:unn_mobile/ui/views/main_page/chat/widgets/message.dart';

class MessageGroup extends StatelessWidget {
  final int? currentUserId;
  final Iterable<Message> messages;
  final ChatInsideViewModel chatModel;
  int? get authorId => messages.firstOrNull?.author?.bitrixId;
  String? get avatarUrl => messages.firstOrNull?.author?.photoSrc;
  String? get name => messages.firstOrNull?.author?.fullname;

  const MessageGroup({
    super.key,
    required this.currentUserId,
    required this.messages,
    required this.chatModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftAvatar = authorId != currentUserId || authorId == null;
    final scaledAvatarWidth = MediaQuery.of(context).textScaler.scale(50.0);
    if (messages.firstOrNull?.messageStatus == MessageState.system) {
      final msgText = messages.firstOrNull?.text
          .split(
            systemMessageSeparator,
          )
          .lastOrNull;
      return Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.7,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.hoverColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: BBCodeText(
                      data: '[CENTER]${msgText ?? ''}[/CENTER]',
                      stylesheet: getBBStyleSheet(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: Row(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: scaledAvatarWidth,
            child: leftAvatar
                ? Avatar(avatarUrl: avatarUrl, dialogTitle: name)
                : null,
          ),
          Expanded(
            child: Column(
              verticalDirection: VerticalDirection.up,
              crossAxisAlignment: leftAvatar
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                ...messages.take(messages.length - 1).map(
                      (message) => MessageWidget(
                        key: ValueKey(
                          (
                            message.messageId,
                            message.ratingList?.getTotalNumberOfReactions() ??
                                0,
                          ),
                        ),
                        message: message,
                        fromCurrentUser: !leftAvatar,
                        chatModel: chatModel,
                      ),
                    ),
                MessageWidget(
                  key: ValueKey(messages.last.messageId),
                  message: messages.last,
                  fromCurrentUser: !leftAvatar,
                  displayAuthor: leftAvatar,
                  chatModel: chatModel,
                ),
              ],
            ),
          ),
          SizedBox(
            width: scaledAvatarWidth,
            child: !leftAvatar
                ? Avatar(avatarUrl: avatarUrl, dialogTitle: name)
                : null,
          ),
        ],
      ),
    );
  }
}

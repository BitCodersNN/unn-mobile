// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/forward_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward_and_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/reply_info.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_inside_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/message_reaction_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/attached_file_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/chat/chat_inside.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/reaction_bubble.dart';

const _systemMessageSeparator =
    '------------------------------------------------------\n';

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
            _systemMessageSeparator,
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
          if (leftAvatar)
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
                for (final message in messages.take(messages.length - 1)) //
                  MessageWidget(
                    key: ValueKey(
                      (
                        message.messageId,
                        message.ratingList?.getTotalNumberOfReactions() ?? 0,
                      ),
                    ),
                    message: message,
                    fromCurrentUser: !leftAvatar,
                    chatModel: chatModel,
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
          if (!leftAvatar)
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

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool fromCurrentUser;
  final bool displayAuthor;
  final ChatInsideViewModel chatModel;
  const MessageWidget({
    super.key,
    required this.message,
    required this.fromCurrentUser,
    required this.chatModel,
    this.displayAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseView<MessageReactionViewModel>(
      model: MessageReactionViewModel.cached(message.messageId),
      builder: (context, model, _) {
        return PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final reaction in ReactionType.values)
                        GestureDetector(
                          onTap: () {
                            triggerHaptic(HapticIntensity.selection);
                            if (model.currentReaction != reaction) {
                              model.toggleReaction(reaction);
                            }
                            GoRouter.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: AssetImage(reaction.assetName),
                            ),
                          ),
                        ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'copy',
              child: Text('Скопировать текст'),
            ),
            const PopupMenuItem(
              value: 'reply',
              child: Text('Ответить'),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'copy':
                await Clipboard.setData(ClipboardData(text: message.text));
                break;
              case 'reply':
                chatModel.replyMessage = message;
                break;
            }
          },
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Align(
                        alignment: fromCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.75,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: fromCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: fromCurrentUser
                                      ? theme.colorScheme.surfaceDim //
                                      : theme.colorScheme.surfaceContainer,
                                ),
                                padding: const EdgeInsets.all(8.0)
                                    .copyWith(bottom: 0.0),
                                child: IntrinsicWidth(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (displayAuthor) //
                                        ...[
                                        _messageAuthorHeader(
                                          context,
                                          message.author?.fullname,
                                        ),
                                        const SizedBox(
                                          height: 4.0,
                                        ),
                                      ],
                                      buildContent(context, message),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          message.dateTime
                                              .toLocal()
                                              .format(DatePattern.hhmm),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 100,
                                ),
                                child: MessageReactionView(
                                  model: model,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(),
              ),
            ],
          ),
        );
      },
      onModelReady: (model) => model.init(
        message.messageId,
        message.ratingList,
      ),
    );
  }

  static Widget _messageAuthorHeader(BuildContext context, String? fullname) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        fullname ?? '??',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: theme.primaryColorDark,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildContent(BuildContext context, Message message) {
    return switch (message) {
      final MessageWithForward msg => buildMessageWithForward(context, msg),
      final MessageWithReply msg => buildMessageWithReply(context, msg),
      final MessageWithForwardAndReply msg =>
        buildMessageWithForwardAndReply(context, msg),
      final Message msg => buildMessage(context, msg),
    };
  }

  static Widget buildMessage(
    BuildContext context,
    Message msg, {
    bool isSystem = false,
  }) {
    final msgText = isSystem
        ? msg.text
            .split(
              _systemMessageSeparator,
            )
            .lastOrNull
        : msg.text;
    return Column(
      children: [
        if (msgText?.isNotEmpty ?? false) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: BBCodeText(
              data: msgText ?? '',
              stylesheet: getBBStyleSheet().copyWith(selectableText: false),
            ),
          ),
          const SizedBox(
            height: 4.0,
          ),
        ],
        for (final file in msg.files)
          AttachedFile(
            viewModel: AttachedFileViewModel.cached(file.id)
              ..initFromFileData(file),
          ),
      ],
    );
  }

  static Widget buildMessageWithReply(
    BuildContext context,
    MessageWithReply msg,
  ) {
    return Column(
      children: [
        buildReplyMessage(
          context,
          msg.replyMessage,
        ),
        buildMessage(context, msg),
      ],
    );
  }

  static Widget buildReplyMessage(
    BuildContext context,
    ReplyInfo replyMessage, {
    bool showFullText = false,
  }) {
    const maxLength = 40;
    final theme = Theme.of(context);
    var msgText = replyMessage.replyMessage.text;
    final isSystem = replyMessage.messageStatus == MessageState.system;
    if (isSystem) {
      msgText = msgText.split(_systemMessageSeparator).lastOrNull ?? '';
    } else if (msgText.length > maxLength && !showFullText) {
      msgText = '${msgText.substring(0, maxLength)}...';
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4.0,
        children: [
          Container(
            width: 4.0,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSystem)
                  _messageAuthorHeader(
                    context,
                    replyMessage.replyMessage.author?.fullname,
                  ),
                BBCodeText(
                  data: msgText,
                  stylesheet: getBBStyleSheet().copyWith(selectableText: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildMessageWithForward(
    BuildContext context,
    MessageWithForward msg,
  ) {
    if (msg.forwardInfo.forwardAuthor == null) {}
    final isSystem = msg.forwardInfo.forwardAuthor == null;
    return Column(
      children: [
        _forwardMessageHeader(
          context,
          msg.forwardInfo,
          isSystem,
        ),
        buildMessage(
          context,
          msg,
          isSystem: isSystem,
        ),
      ],
    );
  }

  static Widget _forwardMessageHeader(
    BuildContext context,
    ForwardInfo? forwardInfo,
    bool isSystem,
  ) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        isSystem
            ? 'Переслано системное сообщение'
            : 'Переслано от ${forwardInfo?.forwardAuthor?.fullname}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.primaryColorDark,
        ),
        softWrap: true,
      ),
    );
  }

  static Widget buildMessageWithForwardAndReply(
    BuildContext context,
    MessageWithForwardAndReply msg,
  ) {
    return Column(
      spacing: 2.0,
      children: [
        _forwardMessageHeader(context, msg.forwardInfo, false),
        buildReplyMessage(context, msg.replyMessage, showFullText: true),
        buildMessage(context, msg),
      ],
    );
  }
}

class MessageReactionView extends StatelessWidget {
  final MessageReactionViewModel model;
  const MessageReactionView({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final reaction in ReactionType.values)
            if (model.getReactionCount(reaction) > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ReactionBubble(
                  isSelected: model.currentReaction == reaction,
                  onPressed: () {
                    triggerHaptic(HapticIntensity.selection);
                    model.toggleReaction(reaction);
                  },
                  icon: Image.asset(reaction.assetName),
                  text: model.getReactionCount(reaction).toString(),
                ),
              ),
          // if (model.canAddReaction)
          //   IconButton.filledTonal(
          //     padding: const EdgeInsets.all(0),
          //     constraints: BoxConstraints.tightFor(
          //       height: scaledAddButtonSize,
          //       width: scaledAddButtonSize,
          //     ),
          //     onPressed: () {
          //       showReactionChoicePanel(context, model);
          //     },
          //     icon: Icon(
          //       Icons.add,
          //       size: MediaQuery.of(context)
          //           .textScaler
          //           .clamp(maxScaleFactor: 1.3)
          //           .scale(16),
          //     ),
          //   ),
          //
        ],
      ),
    );
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
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
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/reaction_bubble.dart';

const systemMessageSeparator =
    '------------------------------------------------------\n';

class MessageWidget extends StatefulWidget {
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
  State<MessageWidget> createState() => _MessageWidgetState();

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
      msgText = msgText.split(systemMessageSeparator).lastOrNull ?? '';
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

  static Widget _buildContent(BuildContext context, Message message) {
    return switch (message) {
      final MessageWithForward msg => _buildMessageWithForward(context, msg),
      final MessageWithReply msg => _buildMessageWithReply(context, msg),
      final MessageWithForwardAndReply msg =>
        _buildMessageWithForwardAndReply(context, msg),
      final Message msg => _buildMessage(context, msg),
    };
  }

  static Widget _buildMessage(
    BuildContext context,
    Message msg, {
    bool isSystem = false,
  }) {
    final msgText = isSystem
        ? msg.text
            .split(
              systemMessageSeparator,
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

  static Widget _buildMessageWithReply(
    BuildContext context,
    MessageWithReply msg,
  ) {
    return Column(
      children: [
        buildReplyMessage(
          context,
          msg.replyMessage,
        ),
        _buildMessage(context, msg),
      ],
    );
  }

  static Widget _buildMessageWithForward(
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
        _buildMessage(
          context,
          msg,
          isSystem: isSystem,
        ),
      ],
    );
  }

  static Widget _buildMessageWithForwardAndReply(
    BuildContext context,
    MessageWithForwardAndReply msg,
  ) {
    return Column(
      spacing: 2.0,
      children: [
        _forwardMessageHeader(context, msg.forwardInfo, false),
        buildReplyMessage(context, msg.replyMessage, showFullText: true),
        _buildMessage(context, msg),
      ],
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
}

class _MessageWidgetState extends State<MessageWidget> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseView<MessageReactionViewModel>(
      model: MessageReactionViewModel.cached(widget.message.messageId),
      builder: (context, model, _) {
        return GestureDetector(
          onLongPress: _showContextMenu,
          child: _buildMessageContent(context, model, theme),
        );
      },
      onModelReady: (model) => model.init(
        widget.message.messageId,
        widget.message.ratingList,
      ),
    );
  }

  void _showContextMenu() {
    setState(() => _isHighlighted = true);
    triggerHaptic(HapticIntensity.medium);

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 1,
      ),
      items: _buildMenuItems(),
    ).then((value) {
      setState(() => _isHighlighted = false);
      _handleMenuSelection(value);
    });
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    return [
      PopupMenuItem(
        enabled: false,
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ReactionType.values
                  .map(
                    (reaction) => GestureDetector(
                      onTap: () => _handleReactionTap(reaction),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(reaction.assetName),
                        ),
                      ),
                    ),
                  )
                  .toList(),
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
    ];
  }

  void _handleReactionTap(ReactionType reaction) {
    final model = MessageReactionViewModel.cached(widget.message.messageId);
    triggerHaptic(HapticIntensity.selection);
    if (model.currentReaction != reaction) {
      model.toggleReaction(reaction);
    }
    Navigator.pop(context);
  }

  void _handleMenuSelection(String? value) async {
    if (value == null) return;

    switch (value) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: widget.message.text));
        break;
      case 'reply':
        widget.chatModel.replyMessage = widget.message;
        break;
    }
  }

  Widget _buildMessageContent(
    BuildContext context,
    MessageReactionViewModel model,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Align(
                  alignment: widget.fromCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.9,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: widget.fromCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: Duration(
                            milliseconds: _isHighlighted ? 300 : 600,
                          ),
                          curve: Curves.decelerate,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: _isHighlighted
                                ? theme.colorScheme.secondaryFixed
                                : widget.fromCurrentUser
                                    ? theme.colorScheme.surfaceDim
                                    : theme.colorScheme.surfaceContainer,
                          ),
                          padding:
                              const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.displayAuthor) ...[
                                  MessageWidget._messageAuthorHeader(
                                    context,
                                    widget.message.author?.fullname,
                                  ),
                                  const SizedBox(height: 4.0),
                                ],
                                MessageWidget._buildContent(
                                  context,
                                  widget.message,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    widget.message.dateTime
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
                          constraints: const BoxConstraints(maxHeight: 100),
                          child: MessageReactionView(model: model),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Expanded(flex: 0, child: SizedBox()),
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
        ],
      ),
    );
  }
}

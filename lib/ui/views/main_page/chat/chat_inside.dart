import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/models/dialog/message/enum/message_state.dart';
import 'package:unn_mobile/core/models/dialog/message/forward_info.dart';
import 'package:unn_mobile/core/models/dialog/message/message.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_forward_and_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/message_with_reply.dart';
import 'package:unn_mobile/core/models/dialog/message/reply_info.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_inside_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/attached_file_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';

const _systemMessageSeparator =
    '------------------------------------------------------\n';

class ChatInside extends StatelessWidget {
  const ChatInside({super.key, required this.chatId});

  final int chatId;

  @override
  Widget build(BuildContext context) {
    return BaseView<ChatInsideViewModel>(
      builder: (context, model, child) {
        final avatarUrl = model.dialog?.avatarUrl;
        final dialogTitle = model.dialog?.title;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Avatar(
                    avatarUrl: avatarUrl,
                    dialogTitle: dialogTitle,
                  ),
                ),
                Expanded(
                  child: Text(
                    model.dialog?.title ?? 'Не удалось получить информацию',
                  ),
                ),
              ],
            ),
          ),
          body: Builder(
            builder: (context) {
              if (model.isBusy && model.messages.isEmpty) {
                return const Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return NotificationListener<ScrollEndNotification>(
                onNotification: (notification) {
                  final metrics = notification.metrics;
                  if (metrics.maxScrollExtent - metrics.pixels < 100) {
                    model.loadMoreMessages();
                  }
                  return true;
                },
                child: ListView(
                  reverse: true,
                  children: [
                    for (final messageDateGroup in model.messages) ...[
                      for (final messageGroup in messageDateGroup)
                        MessageGroup(
                          currentUserId: model.currentUserId,
                          messages: messageGroup,
                        ),
                      Align(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            messageDateGroup.firstOrNull?.firstOrNull?.dateTime
                                    .format(DatePattern.dMMMM) ??
                                'Нет даты (?)',
                          ),
                        ),
                      ),
                    ],
                    if (model.isBusy)
                      const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
      onModelReady: (model) => model.init(chatId),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.avatarUrl,
    required this.dialogTitle,
  });

  final String? avatarUrl;
  final String? dialogTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      foregroundImage: avatarUrl?.isNotEmpty ?? false
          ? CachedNetworkImageProvider(avatarUrl!)
          : null,
      child: avatarUrl?.isEmpty ?? true
          ? Text(
              generateInitials(
                dialogTitle?.split(' ') ?? [],
              ),
              style: theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            )
          : null,
    );
  }
}

class MessageGroup extends StatelessWidget {
  final int? currentUserId;
  final Iterable<Message> messages;
  int? get authorId => messages.firstOrNull?.author?.bitrixId;
  String? get avatarUrl => messages.firstOrNull?.author?.photoSrc;
  String? get name => messages.firstOrNull?.author?.fullname;

  const MessageGroup({
    super.key,
    required this.currentUserId,
    required this.messages,
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
                    message: message,
                    fromCurrentUser: !leftAvatar,
                  ),
                MessageWidget(
                  message: messages.last,
                  fromCurrentUser: !leftAvatar,
                  displayAuthor: leftAvatar,
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

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool fromCurrentUser;
  final bool displayAuthor;
  const MessageWidget({
    super.key,
    required this.message,
    required this.fromCurrentUser,
    this.displayAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Align(
            alignment:
                fromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: fromCurrentUser
                      ? theme.colorScheme.surfaceDim //
                      : theme.colorScheme.surfaceContainer,
                ),
                padding: const EdgeInsets.all(8.0).copyWith(bottom: 0.0),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (displayAuthor) //
                        ...[
                        _messageAuthorHeader(context, message.author?.fullname),
                        const SizedBox(
                          height: 4.0,
                        ),
                      ],
                      buildContent(context, message),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          message.dateTime.toLocal().format(DatePattern.hhmm),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Align _messageAuthorHeader(BuildContext context, String? fullname) {
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

  Widget buildMessage(
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
              stylesheet: getBBStyleSheet(),
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

  Widget buildMessageWithReply(BuildContext context, MessageWithReply msg) {
    return Column(
      children: [
        buildReplyMessage(context, msg.replyMessage),
        buildMessage(context, msg),
      ],
    );
  }

  Widget buildReplyMessage(
    BuildContext context,
    ReplyInfo replyMessage, {
    bool showFullText = false,
  }) {
    const maxLength = 40;
    final theme = Theme.of(context);
    var msgText = replyMessage.replyMessage.text;
    final isSystem = replyMessage.replyMessage.author == null;
    if (isSystem) {
      msgText = msgText.split(_systemMessageSeparator).lastOrNull ?? '';
    }
    if (msgText.length > maxLength && !showFullText) {
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
              children: [
                if (!isSystem)
                  _messageAuthorHeader(
                    context,
                    replyMessage.replyMessage.author?.fullname,
                  ),
                BBCodeText(
                  data: msgText,
                  stylesheet: getBBStyleSheet(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageWithForward(BuildContext context, MessageWithForward msg) {
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

  Widget _forwardMessageHeader(
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

  Widget buildMessageWithForwardAndReply(
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

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/message_reaction_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/chat/widgets/message.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:url_launcher/url_launcher.dart';

List<ContextMenuAction> createMessageActions({
  required BuildContext context,
  required MessageReactionViewModel model,
  required MessageWidget widget,
}) =>
    _createActions(
      context: context,
      reactionViewModel: model,
      textToCopy: widget.message.text,
      onReply: () => widget.chatModel.replyMessage = widget.message,
    );

List<ContextMenuAction> createPostActions({
  required BuildContext context,
  required FeedPostViewModel model,
  required Function(FeedPostViewModel) onShare,
}) =>
    _createActions(
      context: context,
      reactionViewModel: model.reactionViewModel,
      textToCopy: model.postText,
      onTogglePin: model.togglePin,
      isPinned: model.isPinned,
      onShare: () => onShare(model),
    );

List<ContextMenuAction> createCommentActions({
  required BuildContext context,
  required FeedCommentViewModel model,
}) =>
    _createActions(
      context: context,
      reactionViewModel: model.reactionViewModel,
      textToCopy: model.message,
    );

List<ContextMenuAction> createLinkActions({
  required BuildContext context,
  required String url,
  VoidCallback? onOpen,
  VoidCallback? onShare,
}) =>
    _createActions(
      context: context,
      linkToCopy: url,
      onOpenLink: onOpen,
      onShare: onShare,
    );

List<ContextMenuAction> _createActions({
  required BuildContext context,
  ReactionViewModelBase? reactionViewModel,
  String? textToCopy,
  String? linkToCopy,
  VoidCallback? onReply,
  VoidCallback? onTogglePin,
  bool? isPinned,
  VoidCallback? onShare,
  VoidCallback? onOpenLink,
}) {
  final actions = <ContextMenuAction>[];

  if (reactionViewModel != null) {
    actions.add(
      ContextMenuAction.reaction(
        context: context,
        reactionViewModel: reactionViewModel,
      ),
    );
  }

  if (textToCopy != null) {
    actions.add(
      ContextMenuAction.text(
        label: 'Скопировать текст',
        onTap: () => Clipboard.setData(ClipboardData(text: textToCopy)),
        leadingIcon: const Icon(Icons.content_copy, size: 18),
      ),
    );
  }

  if (linkToCopy != null) {
    actions
      ..add(
        ContextMenuAction.text(
          label: 'Открыть',
          onTap: onOpenLink ??
              () {
                launchUrl(Uri.parse(linkToCopy));
              },
          leadingIcon: const Icon(Icons.open_in_new, size: 18),
        ),
      )
      ..add(
        ContextMenuAction.text(
          label: 'Скопировать ссылку',
          onTap: () {
            Clipboard.setData(ClipboardData(text: linkToCopy));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ссылка скопирована')),
              );
            }
          },
          leadingIcon: const Icon(Icons.link, size: 18),
        ),
      );
  }

  if (onReply != null) {
    actions.add(
      ContextMenuAction.text(
        label: 'Ответить',
        onTap: onReply,
        leadingIcon: const Icon(Icons.reply, size: 18),
      ),
    );
  }

  if (onTogglePin != null && isPinned != null) {
    actions.add(
      ContextMenuAction.text(
        label: isPinned ? 'Открепить' : 'Закрепить',
        onTap: onTogglePin,
        leadingIcon: Icon(
          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          size: 18,
        ),
      ),
    );
  }

  if (onShare != null) {
    actions.add(
      ContextMenuAction.text(
        label: 'Поделиться',
        onTap: onShare,
        leadingIcon: const Icon(Icons.share, size: 18),
      ),
    );
  }

  return actions;
}

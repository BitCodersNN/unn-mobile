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

List<ContextMenuAction> _createActions({
  required BuildContext context,
  ReactionViewModelBase? reactionViewModel,
  String? textToCopy,
  VoidCallback? onReply,
  VoidCallback? onTogglePin,
  bool? isPinned,
  VoidCallback? onShare,
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
      ),
    );
  }

  if (onReply != null) {
    actions.add(
      ContextMenuAction.text(
        label: 'Ответить',
        onTap: onReply,
      ),
    );
  }

  if (onTogglePin != null && isPinned != null) {
    actions.add(
      ContextMenuAction.text(
        label: isPinned ? 'Открепить' : 'Закрепить',
        onTap: onTogglePin,
      ),
    );
  }

  if (onShare != null) {
    actions.add(
      ContextMenuAction.text(
        label: 'Поделиться',
        onTap: onShare,
      ),
    );
  }

  return actions;
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/misc/html_utils/html_to_plain_text.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_post_view_model.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';

List<ContextMenuAction> createMessageActions({
  required BuildContext context,
  required ReactionViewModelBase model,
  required String? text,
  required VoidCallback onReply,
}) =>
    [
      _reactionAction(context, model),
      if (text != null) _copyTextAction(text),
      ContextMenuAction.text(
        label: 'Ответить',
        onTap: onReply,
        leadingIcon: const Icon(Icons.reply, size: 18),
      ),
    ];

List<ContextMenuAction> createPostActions({
  required BuildContext context,
  required FeedPostViewModel model,
  required ValueChanged<FeedPostViewModel> onShare,
  bool includeReactions = true,
}) =>
    [
      if (includeReactions && model.reactionViewModel != null)
        _reactionAction(context, model.reactionViewModel!),
      _copyTextAction(htmlToPlainText(model.postText)),
      ContextMenuAction.text(
        label: model.isPinned ? 'Открепить' : 'Закрепить',
        onTap: model.togglePin,
        leadingIcon: Icon(
          model.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          size: 18,
        ),
      ),
      ContextMenuAction.text(
        label: 'Поделиться',
        onTap: () => onShare(model),
        leadingIcon: const Icon(Icons.share, size: 18),
      ),
    ];

List<ContextMenuAction> createCommentActions({
  required BuildContext context,
  required FeedCommentViewModel model,
  bool includeReactions = true,
}) =>
    [
      if (includeReactions && model.reactionViewModel != null)
        _reactionAction(context, model.reactionViewModel!),
      _copyTextAction(htmlToPlainText(model.message)),
    ];

ContextMenuAction _copyTextAction(String text) => ContextMenuAction.text(
      label: 'Скопировать текст',
      onTap: () => Clipboard.setData(ClipboardData(text: text)),
      leadingIcon: const Icon(Icons.content_copy, size: 18),
    );

ContextMenuAction _reactionAction(
  BuildContext context,
  ReactionViewModelBase model,
) =>
    ContextMenuAction.custom(
      child: SizedBox(
        width: 280,
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 4),
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
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(reaction.assetName),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

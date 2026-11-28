// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';
import 'package:unn_mobile/ui/actions/reaction_actions.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_reaction_picker.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_action.dart';
import 'package:unn_mobile/ui/widgets/context_menu/preview_context_menu.dart';

class FeedItemContextMenu extends StatelessWidget {
  final List<ContextMenuAction> Function(BuildContext) actionsBuilder;
  final ReactionViewModelBase? reactions;
  final BorderRadius borderRadius;
  final GlobalKey? previewKey;
  final Widget child;

  const FeedItemContextMenu({
    required this.actionsBuilder,
    required this.child,
    this.reactions,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.previewKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentReactions = reactions;
    return PreviewContextMenu(
      actionsBuilder: actionsBuilder,
      borderRadius: borderRadius,
      previewKey: previewKey,
      topAccessoryBuilder: currentReactions == null
          ? null
          : (menuContext, dismiss) => FeedReactionPicker(
              key: const ValueKey('feed-menu-reactions'),
              selected: currentReactions.currentReaction,
              onSelected: (reaction) {
                if (ModalRoute.of(menuContext)?.isCurrent != true) {
                  return;
                }
                triggerHaptic(HapticIntensity.selection);
                final actions = ReactionActions.of(
                  menuContext,
                  currentReactions,
                );
                dismiss(() {
                  if (currentReactions.currentReaction != reaction) {
                    actions.toggleReaction(reaction);
                  }
                });
              },
            ),
      child: child,
    );
  }
}

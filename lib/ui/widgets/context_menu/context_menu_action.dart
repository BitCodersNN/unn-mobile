// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';

class ContextMenuAction {
  final PopupMenuEntry<void> entry;
  final VoidCallback? onTap;

  const ContextMenuAction({
    required this.entry,
    this.onTap,
  });

  factory ContextMenuAction.text({
    required String label,
    VoidCallback? onTap,
  }) =>
      ContextMenuAction(
        entry: PopupMenuItem<void>(
          child: Text(label),
        ),
        onTap: onTap,
      );

  factory ContextMenuAction.reaction({
    required BuildContext context,
    required ReactionViewModelBase reactionViewModel,
  }) =>
      ContextMenuAction(
        entry: PopupMenuItem<void>(
          enabled: false,
          child: SizedBox(
            width: 280,
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final reaction in ReactionType.values)
                      GestureDetector(
                        onTap: () {
                          triggerHaptic(HapticIntensity.selection);
                          if (reactionViewModel.currentReaction != reaction) {
                            reactionViewModel.toggleReaction(reaction);
                          }
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
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
        ),
      );

  factory ContextMenuAction.custom({
    required Widget child,
    VoidCallback? onTap,
  }) =>
      ContextMenuAction(
        entry: PopupMenuItem<void>(
          enabled: false,
          child: child,
        ),
        onTap: onTap,
      );
}

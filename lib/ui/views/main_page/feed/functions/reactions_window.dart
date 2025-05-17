// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';

void showReactionChoicePanel(
  BuildContext context,
  ReactionViewModelBase model,
) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выбор реакции',
              style: theme.textTheme.headlineSmall,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Divider(
                indent: 8,
                endIndent: 8,
                thickness: 0.5,
                color: Color(0xE5A2A2A2),
              ),
            ),
            const SizedBox(height: 10),
            Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final reaction in ReactionType.values)
                      _circleAvatarWithCaption(
                        reaction,
                        context,
                        model,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Widget _circleAvatarWithCaption(
  ReactionType reaction,
  BuildContext context,
  ReactionViewModelBase model,
) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: GestureDetector(
      onTap: () {
        if (AppSettings.vibrationEnabled) {
          HapticFeedback.selectionClick();
        }
        model.toggleReaction(reaction);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage(reaction.assetName),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              reaction.caption,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}

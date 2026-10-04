import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_reaction_picker.dart';
import 'package:unn_mobile/ui/widgets/anchored_popup.dart';

Future<void> showAnchoredReactionChoice(
  BuildContext context,
  ReactionViewModelBase model,
) async {
  final reaction = await showAnchoredPopup<ReactionType>(
    context,
    width: 376,
    builder: (context) => FeedReactionPicker(
      key: const ValueKey('reaction-choice-panel'),
      selected: model.currentReaction,
      elevation: 8,
      onSelected: (reaction) {
        dismissAnchoredPopup(
          context,
          reaction,
          hapticIntensity: HapticIntensity.selection,
        );
      },
    ),
  );
  if (context.mounted && reaction != null) {
    model.toggleReaction(reaction);
  }
}

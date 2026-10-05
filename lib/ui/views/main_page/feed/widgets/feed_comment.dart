// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/haptic_utils.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/profile_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/reaction_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/anchored_reactions_window.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_action_style.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_author_header.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_item_context_menu.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/packed_post_images.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/reaction_bubble.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/text_html_widget.dart';
import 'package:unn_mobile/ui/widgets/context_menu/context_menu_factory.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';

class FeedCommentView extends StatelessWidget {
  final FeedCommentViewModel viewModel;
  const FeedCommentView({
    required this.viewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) => BaseView<FeedCommentViewModel>(
        model: viewModel,
        builder: (context, model, child) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: FeedItemContextMenu(
            borderRadius: BorderRadius.circular(18),
            reactions: model.reactionViewModel,
            actionsBuilder: (context) => createCommentActions(
              context: context,
              model: model,
              includeReactions: false,
            ),
            child: Shimmer(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeedAuthorHeader(
                      dateTime: model.comment?.dateTime ?? '',
                      viewModel:
                          model.profileViewModel ?? ProfileViewModel.empty(),
                      isLoading: model.isBusy,
                      compact: true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 0,
                        bottom: model.attachedImages.isEmpty &&
                                model.attachedFileViewModels.isNotEmpty
                            ? 0
                            : 10,
                        right: 0,
                        top: 8,
                      ),
                      child: model.renderMessage
                          ? TextHtmlWidget(
                              text: model.message,
                              headers: model.authHeaders,
                            )
                          : const SizedBox(),
                    ),
                    if (model.attachedImages.isNotEmpty)
                      PackedPostImages(
                        attachedImages: model.attachedImages,
                        authorizationHeaders: model.authHeaders,
                      ),
                    AttachedFiles(
                      files: model.attachedFileViewModels,
                      useCardStyle: true,
                    ),
                    _ReactionView(
                      topPadding: model.attachedFileViewModels.isEmpty ? 10 : 0,
                      model:
                          model.reactionViewModel ?? ReactionViewModel.empty(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _ReactionView extends StatelessWidget {
  const _ReactionView({
    required this.model,
    this.topPadding = 10,
  });

  final ReactionViewModel model;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final scaledAddButtonSize = MediaQuery.of(context).textScaler.scale(20) + 8;
    final colors = Theme.of(context).colorScheme;
    return BaseView<ReactionViewModel>(
      model: model,
      builder: (context, model, _) => Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final reaction in ReactionType.values)
              if (model.getReactionCount(reaction) > 0)
                ReactionBubble(
                  borderRadius: feedActionBorderRadius,
                  backgroundColor: feedReactionBackgroundColor(
                    colors,
                    isSelected: model.currentReaction == reaction,
                  ),
                  foregroundColor: colors.onSurfaceVariant,
                  borderSide: BorderSide.none,
                  isSelected: model.currentReaction == reaction,
                  onPressed: () {
                    triggerHaptic(HapticIntensity.selection);
                    model.toggleReaction(reaction);
                  },
                  icon: Image.asset(reaction.assetName),
                  text: model.getReactionCount(reaction).toString(),
                ),
            if (!model.isLoading && model.canAddReaction)
              Builder(
                builder: (buttonContext) => IconButton.filledTonal(
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const RoundedRectangleBorder(
                      borderRadius: feedActionBorderRadius,
                    ),
                  ),
                  constraints: BoxConstraints.tightFor(
                    height: scaledAddButtonSize,
                    width: scaledAddButtonSize,
                  ),
                  onPressed: () {
                    showAnchoredReactionChoice(buttonContext, model);
                  },
                  icon: Icon(
                    Icons.add,
                    size: MediaQuery.of(context)
                        .textScaler
                        .clamp(maxScaleFactor: 1.3)
                        .scale(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

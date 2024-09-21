import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/factories/profile_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/profile_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/functions/reactions_window.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/reaction_bubble.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class FeedCommentView extends StatelessWidget {
  const FeedCommentView({
    super.key,
    required this.comment,
  });

  final BlogPostComment comment;

  @override
  Widget build(BuildContext context) {
    final scaledAddButtonSize = MediaQuery.of(context).textScaler.scale(20) + 8;
    return BaseView<FeedCommentViewModel>(
      builder: (context, model, child) {
        return Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentHeader(
                dateTime: model.comment.dateTime,
                authorId: model.comment.bitrixID,
                hide: model.isBusy,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  bottom: 10,
                  right: 10,
                  top: 8,
                ),
                child: model.renderMessage
                    ? BBCodeText(
                        data: model.message,
                        stylesheet: getBBStyleSheet(),
                      )
                    : const SizedBox(),
              ),
              for (final file in model.files)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: AttachedFile(
                    fileId: file,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final reaction in ReactionType.values)
                      if (model.getReactionCount(reaction) > 0)
                        ReactionBubble(
                          isSelected: model.currentReaction == reaction,
                          onPressed: () {
                            model.toggleReaction(reaction);
                          },
                          icon: Image.asset(reaction.assetName),
                          text: model.getReactionCount(reaction).toString(),
                        ),
                    if (!model.isBusy && model.canAddReaction)
                      IconButton.filledTonal(
                        padding: const EdgeInsets.all(0),
                        constraints: BoxConstraints.tightFor(
                          height: scaledAddButtonSize,
                          width: scaledAddButtonSize,
                        ),
                        onPressed: () {
                          showReactionChoicePanel(context, model);
                        },
                        icon: Icon(
                          Icons.add,
                          size: MediaQuery.of(context)
                              .textScaler
                              .clamp(maxScaleFactor: 1.3)
                              .scale(16),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      onModelReady: (model) => model.init(comment),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  final String dateTime;
  final int authorId;
  final bool hide;

  const _CommentHeader({
    required this.dateTime,
    required this.authorId,
    this.hide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseView<ProfileViewModel>(
      model: Injector.appInstance
          .get<ProfileViewModelFactory>()
          .getViewModel(authorId),
      builder: (context, model, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ShimmerLoading(
                isLoading: model.isLoading || hide,
                child: CircleAvatar(
                  backgroundImage: model.hasAvatar
                      ? CachedNetworkImageProvider(model.avatarUrl!)
                      : null,
                  radius: MediaQuery.of(context).textScaler.scale(20),
                  child: model.hasAvatar
                      ? null
                      : Text(
                          style: theme.textTheme.headlineSmall!.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize:
                                MediaQuery.of(context).textScaler.scale(20),
                          ),
                          model.initials,
                        ),
                  //
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ShimmerLoading(
                isLoading: model.isLoading || hide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!model.isLoading && !hide)
                      Text(
                        model.fullname,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context)
                              .textScaler
                              .clamp(maxScaleFactor: 1.5)
                              .scale(16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    if (!model.isLoading && !hide)
                      Text(
                        dateTime,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      onModelReady: (p0) => p0.init(loadFromPost: true, userId: authorId),
    );
  }
}

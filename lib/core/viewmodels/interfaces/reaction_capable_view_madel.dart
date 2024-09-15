import 'package:unn_mobile/core/models/rating_list.dart';

abstract interface class ReactionCapableViewMadel {
  ReactionType? get currentReaction;
  void toggleReaction(ReactionType reactionType);
}

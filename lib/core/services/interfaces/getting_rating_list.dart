import 'package:unn_mobile/core/models/rating_list.dart';

abstract interface class GettingRatingList {
  Future<RatingList?> getUsersListByReaction({
    required String voteKeySigned,
    required ReactionType reactionType,
    int pageNumber = 0,
  });

  Future<Map<ReactionType, int>?> getNumbersOfReactions({
    required String voteKeySigned,
  });

  Future<RatingList?> getRatingList({
    required String voteKeySigned,
  });
}

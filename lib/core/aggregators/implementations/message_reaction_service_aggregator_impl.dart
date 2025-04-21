import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/reaction/message_reaction_fetcher_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/reaction/message_reaction_mutator_service.dart';
import 'package:unn_mobile/core/aggregators/intefaces/message_reaction_service_aggregator.dart';

class MessageReactionServiceAggregatorImpl
    implements MessageReactionServiceAggregator {
  final MessageReactionFetcherService _reactionFetcherService;
  final MessageReactionMutatorService _reactionMutatorService;

  MessageReactionServiceAggregatorImpl(
    this._reactionFetcherService,
    this._reactionMutatorService,
  );

  @override
  Future<RatingList?> fetch(int messageId) =>
      _reactionFetcherService.fetch(messageId);

  @override
  Future<bool> addReaction(
    int messageId,
    ReactionType reactionType,
  ) =>
      _reactionMutatorService.addReaction(messageId, reactionType);

  @override
  Future<bool> removeReaction(
    int messageId,
    ReactionType reactionType,
  ) =>
      _reactionMutatorService.removeReaction(messageId, reactionType);
}

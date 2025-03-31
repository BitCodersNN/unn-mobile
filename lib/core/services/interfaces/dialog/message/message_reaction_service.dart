import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_service.dart';

abstract interface class MessageReactionService implements ReactionService {
  Future<RatingList?> fetch(int messageId);
}

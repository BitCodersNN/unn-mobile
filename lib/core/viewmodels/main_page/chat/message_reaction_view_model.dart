// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/aggregators/interfaces/message_reaction_service_aggregator.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/factories/message_reaction_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';

class MessageReactionViewModel extends ReactionViewModelBase {
  MessageReactionViewModel(
    this._reactionServiceAggregator,
    super._currentUserSyncStorage,
    super._loggerService,
  );
  factory MessageReactionViewModel.cached(MessageReactionCacheKey key) =>
      Injector.appInstance.get<MessageReactionViewModelFactory>().getViewModel(
        key,
      );

  final MessageReactionServiceAggregator _reactionServiceAggregator;

  int? _messageId;

  Future<void> init(int messageId, RatingList? ratingList) async {
    if (isChangingReaction) {
      return;
    }
    this.ratingList = ratingList;
    _messageId = messageId;
    await _fetchReactions();
  }

  @override
  bool get hasReactionTarget => _messageId != null;

  @override
  Future<bool> addReaction(ReactionType reaction) =>
      _reactionServiceAggregator.addReaction(_messageId!, reaction);

  @override
  Future<bool> removeReaction(ReactionType reaction) =>
      _reactionServiceAggregator.removeReaction(_messageId!, reaction);

  @override
  Future<void> afterReactionSaved() async {
    await _fetchReactions();
  }

  Future<bool> _fetchReactions() async {
    if (_messageId == null) {
      return false;
    }
    final revision = reactionRevision;
    final list = await _reactionServiceAggregator.fetch(_messageId!);
    if (list == null || revision != reactionRevision) {
      return false;
    }
    ratingList = list;
    notifyListeners();
    return true;
  }
}

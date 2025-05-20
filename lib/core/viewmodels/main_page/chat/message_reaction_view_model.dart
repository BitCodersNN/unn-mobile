// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/aggregators/intefaces/message_reaction_service_aggregator.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/viewmodels/factories/message_reaction_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';

class MessageReactionViewModel extends ReactionViewModelBase {
  factory MessageReactionViewModel.cached(MessageReactionCacheKey key) {
    return Injector.appInstance
        .get<MessageReactionViewModelFactory>()
        .getViewModel(key);
  }

  final MessageReactionServiceAggregator _reactionServiceAggregator;

  int? _messageId;

  MessageReactionViewModel(
    this._reactionServiceAggregator,
    super._currentUserSyncStorage,
  );

  FutureOr<void> init(int messageId, RatingList? ratingList) async {
    this.ratingList = ratingList;
    _messageId = messageId;
    await _fetchReactions();
  }

  @override
  FutureOr<void> setReaction(ReactionType? reaction) async {
    if (profileId == ReactionViewModelBase.noId) {
      return;
    }
    if (_messageId == null) {
      return;
    }
    if (reaction == null) {
      final currentReactionInfo = ratingList?.getReactionInfoByUser(profileId);
      final currentReactionType = ratingList?.getReactionByUser(profileId);
      if (currentReactionInfo == null || currentReactionType == null) {
        return;
      }
      // Временно удаляем реакцию, чтобы показать действие
      ratingList!.removeReaction(profileId);
      notifyListeners();
      final reactionRemoved = await _reactionServiceAggregator.removeReaction(
        _messageId!,
        currentReactionType,
      );
      final reactionsFetched = await _fetchReactions();

      if (!reactionRemoved || !reactionsFetched) {
        // не закончили процедуру полностью - возвращаем как было
        ratingList!.addReactions(
          currentReactionType,
          [currentReactionInfo],
        );
        notifyListeners();
      }
    } else {
      // Добавляем временно, чтобы сразу показать действие
      ratingList?.addReactions(
        reaction,
        [UserShortInfo(profileId, '', '')],
      );
      notifyListeners();
      await _reactionServiceAggregator.addReaction(
        _messageId!,
        reaction,
      );
      if (!await _fetchReactions()) {
        // Удаляем временную реакцию.
        // Если _fetchReactions отработал, то её и так не будет
        ratingList?.removeReaction(profileId);
      }
      notifyListeners();
    }
  }

  Future<bool> _fetchReactions() async {
    if (_messageId == null) {
      return false;
    }
    final list = await _reactionServiceAggregator.fetch(_messageId!);
    if (list == null) {
      return false;
    }
    ratingList = list;
    notifyListeners();
    return true;
  }
}

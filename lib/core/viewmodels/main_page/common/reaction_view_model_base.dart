// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

abstract class ReactionViewModelBase extends BaseViewModel {
  static const noId = -1;

  final CurrentUserSyncStorage _currentUserSyncStorage;

  @protected
  RatingList? ratingList;

  bool _isChangingReaction = false;

  ReactionViewModelBase(
    this._currentUserSyncStorage,
  );

  bool get canAddReaction =>
      ReactionType.values
          .map((e) => getReactionCount(e))
          .where((e) => e > 0)
          .length <
      ReactionType.values.length;

  ReactionType? get currentReaction {
    return ratingList?.getReactionByUser(
      _currentUserSyncStorage.currentUserData?.bitrixId ?? noId,
    );
  }

  int get profileId =>
      _currentUserSyncStorage.currentUserData?.bitrixId ?? noId;

  bool get isChangingReaction => _isChangingReaction;

  int get reactionCount => ratingList?.getTotalNumberOfReactions() ?? 0;

  Iterable<ReactionType> get reactionList =>
      ratingList?.ratingList.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((e) => e.key) ??
      [];

  int getReactionCount(ReactionType reaction) {
    return ratingList?.getNumberOfReactions(reaction) ?? 0;
  }

  void toggleLike() {
    if (currentReaction != null) {
      _setReactionWrapper(null);
    } else {
      _setReactionWrapper(ReactionType.like);
    }
    notifyListeners();
  }

  void toggleReaction(ReactionType reaction) async {
    if (_isChangingReaction) {
      return;
    }
    final currentReaction = this.currentReaction;

    // Убираем реакцию и ставим новую, если она не та же, что была
    await _setReactionWrapper(null);
    if (currentReaction != reaction) {
      await _setReactionWrapper(reaction);
    }
  }

  Future<void> _setReactionWrapper(ReactionType? reaction) async {
    if (_isChangingReaction) {
      return;
    }
    try {
      _isChangingReaction = true;
      setReaction(reaction);
    } finally {
      _isChangingReaction = false;
      notifyListeners();
    }
  }

  @protected
  FutureOr<void> setReaction(ReactionType? reaction);
}

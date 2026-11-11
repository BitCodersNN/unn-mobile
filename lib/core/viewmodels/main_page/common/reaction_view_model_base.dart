// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:unn_mobile/core/misc/demo_mode_status.dart';
import 'package:unn_mobile/core/misc/optimistic_action.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/common/action_result.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

abstract class ReactionViewModelBase extends BaseViewModel {
  static const noId = -1;

  final CurrentUserSyncStorage _currentUserSyncStorage;
  final LoggerService _loggerService;
  final OptimisticAction _changeReaction = OptimisticAction();
  int _reactionRevision = 0;

  @protected
  RatingList? ratingList;

  ReactionViewModelBase(this._currentUserSyncStorage, this._loggerService);

  bool get canAddReaction =>
      ReactionType.values.map(getReactionCount).where((e) => e > 0).length <
      ReactionType.values.length;

  ReactionType? get currentReaction => ratingList?.getReactionByUser(profileId);

  int get profileId =>
      _currentUserSyncStorage.currentUserData?.bitrixId ?? noId;

  bool get isChangingReaction => _changeReaction.isRunning;

  @protected
  int get reactionRevision => _reactionRevision;

  int get reactionCount => ratingList?.getTotalNumberOfReactions() ?? 0;

  Iterable<ReactionType> get reactionList =>
      ratingList?.ratingList.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((e) => e.key) ??
      [];

  int getReactionCount(ReactionType reaction) =>
      ratingList?.getNumberOfReactions(reaction) ?? 0;

  Future<ActionResult> toggleLike() =>
      _setReaction(currentReaction == null ? ReactionType.like : null);

  Future<ActionResult> toggleReaction(ReactionType reaction) =>
      _setReaction(currentReaction == reaction ? null : reaction);

  Future<ActionResult> _setReaction(ReactionType? reaction) {
    final currentList = ratingList;
    if (DemoModeStatus.demoModeEnabled ||
        profileId == noId ||
        !hasReactionTarget ||
        currentList == null ||
        isChangingReaction) {
      return Future.value(ActionResult.skipped);
    }
    final snapshot = RatingList.copy(currentList);
    final previous = currentReaction;
    final user =
        snapshot.getReactionInfoByUser(profileId) ??
        _currentUserSyncStorage.currentUserData ??
        UserShortInfo(bitrixId: profileId);
    bool removedPrevious = false;
    return _changeReaction.run(
      apply: () {
        _reactionRevision++;
        ratingList = RatingList.copy(snapshot)..removeReaction(profileId);
        if (reaction != null) {
          ratingList!.addReactions(reaction, {user});
        }
      },
      save: () async {
        if (previous != null) {
          removedPrevious = await removeReaction(previous);
          if (!removedPrevious) {
            return false;
          }
        }
        return reaction == null || await addReaction(reaction);
      },
      rollback: () async {
        ratingList = snapshot;
        notifyListeners();
        if (removedPrevious && previous != null) {
          await addReaction(previous);
        }
      },
      commit: afterReactionSaved,
      onChanged: notifyListeners,
      onError: _loggerService.logError,
    );
  }

  /// Указывает, загружены ли данные для изменения реакции.
  @protected
  bool get hasReactionTarget;

  /// Добавляет реакцию на сервере и возвращает результат сохранения.
  @protected
  Future<bool> addReaction(ReactionType reaction);

  /// Удаляет предыдущую реакцию на сервере.
  @protected
  Future<bool> removeReaction(ReactionType reaction);

  /// Обновляет данные после успешного сохранения реакции.
  @protected
  FutureOr<void> afterReactionSaved() {}
}

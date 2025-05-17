// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_vote_key_signed.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/reaction_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';

class ReactionViewModel extends ReactionViewModelBase {
  final GettingVoteKeySigned _gettingVoteKeySigned;
  final GettingRatingList _gettingRatingList;
  final ReactionService _reactionManager;

  String? _voteKeySigned;

  bool _isLoading = true;

  ReactionViewModel(
    this._gettingVoteKeySigned,
    this._gettingRatingList,
    this._reactionManager,
    super._currentUserSyncStorage,
  );

  factory ReactionViewModel.cached(ReactionCacheKey key) {
    return Injector.appInstance
        .get<ReactionViewModelFactory>()
        .getViewModel(key);
  }

  bool get isLoading => _isLoading;

  void init({String? voteKeySigned, int? postId, int? authorId}) {
    _isLoading = true;
    notifyListeners();
    _loadData(voteKeySigned: voteKeySigned, postId: postId, authorId: authorId)
        .whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  void initFull(String voteKeySigned, RatingList ratingList) {
    this.ratingList = ratingList;
    _voteKeySigned = voteKeySigned;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadData({
    String? voteKeySigned,
    int? postId,
    int? authorId,
  }) async {
    assert((voteKeySigned == null) != (postId == null && authorId == null));
    _voteKeySigned = voteKeySigned;
    _voteKeySigned ??= await _gettingVoteKeySigned.getVoteKeySigned(
      authorId: authorId!,
      postId: postId!,
    );

    if (_voteKeySigned == null) {
      return;
    }
    ratingList = await _gettingRatingList.getRatingList(
      voteKeySigned: _voteKeySigned!,
    );
  }

  @override
  Future<void> setReaction(ReactionType? reaction) async {
    if (profileId == ReactionViewModelBase.noId) {
      return;
    }
    if (_voteKeySigned == null) {
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
      if (!await _reactionManager.removeReaction(_voteKeySigned!)) {
        // Если реакция не удалилась - восстанавливаем её
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
      final reactionUserInfo = await _reactionManager.addReaction(
        reaction,
        _voteKeySigned!,
      );
      // Удаляем временную реакцию
      ratingList?.removeReaction(profileId);
      if (reactionUserInfo != null) {
        // Если реакция реально добавилась - фиксируем это
        ratingList?.addReactions(
          reaction,
          [reactionUserInfo],
        );
      }
      notifyListeners();
    }
  }
}

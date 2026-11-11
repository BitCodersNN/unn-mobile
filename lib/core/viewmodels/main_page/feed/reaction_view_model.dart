// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_action_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_rating_list_service.dart';
import 'package:unn_mobile/core/viewmodels/factories/reaction_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/common/reaction_view_model_base.dart';

class ReactionViewModel extends ReactionViewModelBase {
  final ReactionRatingListService _gettingRatingList;
  final ReactionActionService _reactionManager;

  String? _voteKeySigned;

  bool _isLoading = true;

  ReactionViewModel(
    this._gettingRatingList,
    this._reactionManager,
    super._currentUserSyncStorage,
    super._loggerService,
  );

  factory ReactionViewModel.cached(ReactionCacheKey key) =>
      Injector.appInstance.get<ReactionViewModelFactory>().getViewModel(key);
  factory ReactionViewModel.empty() =>
      Injector.appInstance.get<ReactionViewModelFactory>().getEmptyViewModel();

  bool get isLoading => _isLoading;

  void init({String? voteKeySigned, int? postId, int? authorId}) {
    if (isChangingReaction) {
      return;
    }
    _isLoading = true;
    if (postId == null && authorId == null && voteKeySigned == null) {
      return;
    }

    notifyListeners();
    _loadData(
      voteKeySigned: voteKeySigned,
      postId: postId,
      authorId: authorId,
    ).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  void initFull(String voteKeySigned, RatingList ratingList) {
    if (isChangingReaction) {
      return;
    }
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

    if (_voteKeySigned == null) {
      return;
    }
    final revision = reactionRevision;
    final loaded = await _gettingRatingList.getRatingList(
      voteKeySigned: _voteKeySigned!,
    );
    if (revision == reactionRevision) {
      ratingList = loaded;
    }
  }

  @override
  bool get hasReactionTarget => _voteKeySigned != null && !_isLoading;

  @override
  Future<bool> addReaction(ReactionType reaction) async {
    final user = await _reactionManager.addReaction(reaction, _voteKeySigned!);
    if (user == null) {
      return false;
    }
    ratingList?.removeReaction(profileId);
    ratingList?.addReactions(reaction, {user});
    return true;
  }

  @override
  Future<bool> removeReaction(ReactionType reaction) =>
      _reactionManager.removeReaction(_voteKeySigned!);
}

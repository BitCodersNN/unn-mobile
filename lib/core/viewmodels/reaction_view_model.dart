import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/reaction_view_model_factory.dart';

class ReactionViewModel extends BaseViewModel {
  final GettingVoteKeySigned _gettingVoteKeySigned;
  final GettingRatingList _gettingRatingList;
  final ReactionManager _reactionManager;
  final CurrentUserSyncStorage _currentUserSyncStorage;

  factory ReactionViewModel.cached(ReactionCacheKey key) {
    return Injector.appInstance
        .get<ReactionViewModelFactory>()
        .getViewModel(key);
  }
  RatingList? _ratingList;

  String? _voteKeySigned;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isChangingReaction = false;
  bool get isChangingReaction => _isChangingReaction;

  ReactionViewModel(
    this._gettingVoteKeySigned,
    this._gettingRatingList,
    this._reactionManager,
    this._currentUserSyncStorage,
  );

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
    _ratingList = await _gettingRatingList.getRatingList(
      voteKeySigned: _voteKeySigned!,
    );
  }

  ReactionType? get currentReaction => _ratingList?.getReactionByUser(
        _currentUserSyncStorage.currentUserData?.bitrixId ?? -1,
      );

  int getReactionCount(ReactionType reaction) {
    return _ratingList?.getNumberOfReactions(reaction) ?? 0;
  }

  Future<void> _setReaction(ReactionType? reaction) async {
    if (_isChangingReaction) {
      return;
    }
    try {
      _isChangingReaction = true;
      final profileId = _currentUserSyncStorage.currentUserData?.bitrixId;
      if (profileId == null) {
        return;
      }
      if (_voteKeySigned == null) {
        return;
      }
      if (reaction == null) {
        final currentReactionInfo =
            _ratingList?.getReactionInfoByUser(profileId);
        final currentReactionType = _ratingList?.getReactionByUser(profileId);
        if (currentReactionInfo == null || currentReactionType == null) {
          return;
        }
        // Временно удаляем реакцию, чтобы показать действие
        _ratingList!.removeReaction(profileId);
        notifyListeners();
        if (!await _reactionManager.removeReaction(_voteKeySigned!)) {
          // Если реакция не удалилась - восстанавливаем её
          _ratingList!.addReactions(
            currentReactionType,
            [currentReactionInfo],
          );
          notifyListeners();
        }
      } else {
        // Добавляем временно, чтобы сразу показать действие
        _ratingList?.addReactions(
          reaction,
          [ReactionUserInfo(profileId, '', '')],
        );
        notifyListeners();
        final reactionUserInfo = await _reactionManager.addReaction(
          reaction,
          _voteKeySigned!,
        );
        // Удаляем временную реакцию
        _ratingList?.removeReaction(profileId);
        if (reactionUserInfo != null) {
          // Если реакция реально добавилась - фиксируем это
          _ratingList?.addReactions(
            reaction,
            [reactionUserInfo],
          );
        }
        notifyListeners();
      }
    } finally {
      _isChangingReaction = false;
      notifyListeners();
    }
  }

  void toggleReaction(ReactionType reaction) async {
    if (_isChangingReaction) {
      return;
    }
    final currentReaction = this.currentReaction;

    // Убираем реакцию и ставим новую, если она не та же, что была
    await _setReaction(null);
    if (currentReaction != reaction) {
      await _setReaction(reaction);
    }
  }

  void toggleLike() {
    if (currentReaction != null) {
      _setReaction(null);
    } else {
      _setReaction(ReactionType.like);
    }
    notifyListeners();
  }

  int get reactionCount => _ratingList?.getTotalNumberOfReactions() ?? 0;

  bool get canAddReaction =>
      ReactionType.values
          .map((e) => getReactionCount(e))
          .where((e) => e > 0)
          .length <
      ReactionType.values.length;

  Iterable<ReactionType> get reactionList =>
      _ratingList?.ratingList.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((e) => e.key) ??
      [];

  void init({String? voteKeySigned, int? postId, int? authorId}) {
    _isLoading = true;
    notifyListeners();
    _loadData(voteKeySigned: voteKeySigned, postId: postId, authorId: authorId)
        .whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }
}

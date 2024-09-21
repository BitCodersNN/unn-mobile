import 'package:html_unescape/html_unescape.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/blog_comment_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/interfaces/reaction_capable_view_madel.dart';

class FeedCommentViewModel extends BaseViewModel
    implements ReactionCapableViewMadel {
  final _bbTagRegex = RegExp(r'\[[^\[\]]+\]');
  final BlogCommentDataLoader _loader;
  final LoggerService _loggerService;
  final CurrentUserSyncStorage _currentUserSyncStorage;
  final ReactionManager _reactionManager;

  final HtmlUnescape _unescaper = HtmlUnescape();
  late BlogPostComment comment;

  List<int> get files => comment.attachedFiles;

  String get message => _unescaper.convert(comment.message);
  bool _renderMessage = false;
  bool get renderMessage => _renderMessage && !isBusy;

  bool _isChangingReaction = false;

  FeedCommentViewModel(
    this._loader,
    this._loggerService,
    this._currentUserSyncStorage,
    this._reactionManager,
  );

  LoadedBlogPostComment? _loadedComment;

  @override
  ReactionType? get currentReaction =>
      _loadedComment?.ratingList?.getReactionByUser(
        _currentUserSyncStorage.currentUserData?.bitrixId ?? -1,
      );

  int getReactionCount(ReactionType reaction) {
    return _loadedComment?.ratingList?.getNumberOfReactions(reaction) ?? 0;
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
      if (reaction == null) {
        final currentReactionInfo =
            _loadedComment?.ratingList?.getReactionInfoByUser(profileId);
        final currentReactionType =
            _loadedComment?.ratingList?.getReactionByUser(profileId);
        if (currentReactionInfo == null || currentReactionType == null) {
          return;
        }
        // Временно удаляем реакцию, чтобы показать действие
        _loadedComment!.ratingList!.removeReaction(profileId);
        notifyListeners();
        if (!await _reactionManager.removeReaction(comment.keySigned)) {
          // Если реакция не удалилась - восстанавливаем её
          _loadedComment!.ratingList!.addReactions(
            currentReactionType,
            [currentReactionInfo],
          );
          notifyListeners();
        }
      } else {
        // Добавляем временно, чтобы сразу показать действие
        _loadedComment?.ratingList?.addReactions(
          reaction,
          [ReactionUserInfo(profileId, '', '')],
        );
        notifyListeners();
        final reactionUserInfo = await _reactionManager.addReaction(
          reaction,
          comment.keySigned,
        );
        // Удаляем временную реакцию
        _loadedComment?.ratingList?.removeReaction(profileId);
        if (reactionUserInfo != null) {
          // Если реакция реально добавилась - фиксируем это
          _loadedComment?.ratingList?.addReactions(
            reaction,
            [reactionUserInfo],
          );
        }
        notifyListeners();
      }
    } finally {
      _isChangingReaction = false;
    }
  }

  @override
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

  bool get canAddReaction =>
      ReactionType.values
          .map((e) => getReactionCount(e))
          .where((e) => e > 0)
          .length <
      ReactionType.values.length;

  void init(BlogPostComment comment) {
    this.comment = comment;
    _renderMessage = comment.message.replaceAll(_bbTagRegex, '').isNotEmpty;
    setState(ViewState.busy);
    _loader.load(comment).then(
      (value) {
        if (!disposed) {
          _loadedComment = value;
        }
        setState(ViewState.idle);
      },
    ).onError(
      (error, stackTrace) {
        _loggerService.logError(error, stackTrace);
        setState(ViewState.idle);
      },
    );
  }
}

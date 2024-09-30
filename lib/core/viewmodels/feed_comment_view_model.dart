import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/loaded_blog_post_comment.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_short_info.dart';
import 'package:unn_mobile/core/services/interfaces/blog_comment_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class FeedCommentViewModel extends BaseViewModel {
  final _bbTagRegex = RegExp(r'\[[^\[\]]+\]');
  final BlogCommentDataLoader _loader;
  final LoggerService _loggerService;
  final CurrentUserSyncStorage _currentUserSyncStorage;
  final ReactionManager _reactionManager;

  final HtmlUnescape unescaper = HtmlUnescape();
  late BlogPostComment comment;

  List<FileData> get files => _loadedComment?.files ?? [];

  String get message => unescaper.convert(comment.message);
  String get authorName =>
      _loadedComment?.author?.fullname.toString() ?? //
      'Неизвестный пользователь';
  String get authorInitials => getUserInitials(_loadedComment?.author);
  bool _renderMessage = false;
  bool get renderMessage => _renderMessage && !isBusy;

  bool get hasAvatar => _loadedComment?.author?.fullUrlPhoto != null;

  bool _isChangingReaction = false;

  ImageProvider? get authorAvatar => hasAvatar
      ? CachedNetworkImageProvider(
          _loadedComment!.author!.fullUrlPhoto!,
        )
      : null;

  FeedCommentViewModel(
    this._loader,
    this._loggerService,
    this._currentUserSyncStorage,
    this._reactionManager,
  );

  LoadedBlogPostComment? _loadedComment;

  ReactionType? get selectedReaction =>
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
        final currentReaction =
            _loadedComment?.ratingList?.getReactionByUser(profileId);
        if (currentReactionInfo == null || currentReaction == null) {
          return;
        }
        // Временно удаляем реакцию, чтобы показать действие
        _loadedComment!.ratingList!.removeReaction(profileId);
        notifyListeners();
        if (!await _reactionManager.removeReaction(comment.keySigned)) {
          // Если реакция не удалилась - восстанавливаем её
          _loadedComment!.ratingList!.addReactions(
            currentReaction,
            [currentReactionInfo],
          );
          notifyListeners();
        }
      } else {
        // Добавляем временно, чтобы сразу показать действие
        _loadedComment?.ratingList?.addReactions(
          reaction,
          [UserShortInfo(profileId, '', '')],
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

  void toggleReaction(ReactionType reaction) async {
    if (_isChangingReaction) {
      return;
    }
    final currentReaction = selectedReaction;
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

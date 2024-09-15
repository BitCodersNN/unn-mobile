import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/feed_post_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/interfaces/reaction_capable_view_madel.dart';

class FeedPostViewModel extends BaseViewModel
    implements ReactionCapableViewMadel {
  final CurrentUserSyncStorage _currentUserSyncStorage;
  final FeedPostDataLoader _postLoader;
  final ReactionManager _reactionManager;
  final HtmlUnescape _unescaper = HtmlUnescape();

  late final BlogData blogData;

  bool _isChangingReaction = false;

  PostWithLoadedInfo? _loadedPost;

  PostWithLoadedInfo? get loadedPost => _loadedPost;

  String get postText => _unescaper.convert(blogData.detailText.trim());

  String get authorName =>
      author?.fullname.toString() ?? 'Неизвестный пользователь';

  bool get hasAvatar => _loadedPost?.author?.fullUrlPhoto != null;

  int get filesCount => blogData.files?.length ?? 0;

  ImageProvider? get authorAvatar => hasAvatar
      ? CachedNetworkImageProvider(
          _loadedPost!.author!.fullUrlPhoto!,
        )
      : null;

  @override
  bool get isBusy => state == ViewState.busy;

  FeedPostViewModel(
    this._currentUserSyncStorage,
    this._postLoader,
    this._reactionManager,
  );

  List<FileData> get files => loadedPost?.files ?? [];

  DateTime get postTime => blogData.datePublish;

  UserData? get author => loadedPost?.author;

  @override
  ReactionType? get currentReaction => _getReaction();

  int get reactionCount =>
      loadedPost?.ratingList.getTotalNumberOfReactions() ?? 0;

  int get commentsCount => blogData.numberOfComments;

  void init(BlogData blogData) {
    this.blogData = blogData;
    setState(ViewState.busy);
    _postLoader.load(blogData).then(
      (value) {
        if (!disposed) {
          _loadedPost = value;
        }
        setState(ViewState.idle);
      },
    );
  }

  ReactionType? _getReaction() {
    final profileId = _currentUserSyncStorage.currentUserData?.bitrixId;
    return profileId != null
        ? loadedPost?.ratingList.getReactionByUser(profileId)
        : null;
  }

  void _setReaction(ReactionType? reaction) async {
    if (_isChangingReaction || state == ViewState.busy) {
      return;
    }
    if (blogData.keySigned == null) {
      return;
    }
    if (loadedPost == null) {
      return;
    }
    final profileId = _currentUserSyncStorage.currentUserData?.bitrixId;
    if (profileId == null) {
      return;
    }
    _isChangingReaction = true;
    try {
      if (reaction == null) {
        // Сохраняем то, что сейчас есть в списке
        final currentReactionInfo =
            loadedPost?.ratingList.getReactionInfoByUser(profileId);
        final currentReaction =
            loadedPost?.ratingList.getReactionByUser(profileId);
        if (currentReactionInfo == null || currentReaction == null) {
          return;
        }
        // Временно удаляем реакцию, чтобы показать действие
        loadedPost?.ratingList.removeReaction(profileId);
        notifyListeners();
        if (!await _reactionManager.removeReaction(blogData.keySigned!)) {
          // Если реакция не удалилась - восстанавливаем её
          loadedPost?.ratingList
              .addReactions(currentReaction, [currentReactionInfo]);
          notifyListeners();
        }
      } else {
        // Добавляем временно, чтобы сразу показать действие
        loadedPost?.ratingList.addReactions(
          reaction,
          [ReactionUserInfo(profileId, '', '')],
        );
        notifyListeners();
        final reactionUserInfo = await _reactionManager.addReaction(
          reaction,
          blogData.keySigned!,
        );
        // Удаляем временную реакцию
        loadedPost?.ratingList.removeReaction(profileId);
        if (reactionUserInfo != null) {
          // Если реакция реально добавилась - фиксируем это
          loadedPost?.ratingList.addReactions(reaction, [reactionUserInfo]);
        }
        notifyListeners();
      }
    } finally {
      _isChangingReaction = false;
    }
  }

  void toggleLike() {
    if (_getReaction() != null) {
      _setReaction(null);
    } else {
      _setReaction(ReactionType.like);
    }
    notifyListeners();
  }

  @override
  void toggleReaction(ReactionType reaction) async {
    if (state == ViewState.busy) {
      return;
    }
    _setReaction(null);
    if (_getReaction() != reaction) {
      _setReaction(reaction);
    }
    notifyListeners();
  }
}

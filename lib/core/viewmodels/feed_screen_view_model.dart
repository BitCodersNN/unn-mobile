import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class FeedScreenViewModel extends BaseViewModel {
  final FeedUpdaterService feedStreamUpdater;
  final CurrentUserSyncStorage currentUserSyncStorage;
  final ReactionManager reactionManager;

  FeedScreenViewModel(
    this.feedStreamUpdater,
    this.currentUserSyncStorage,
    this.reactionManager,
  );

  DateTime? _lastViewedPostDateTime;
  List<PostWithLoadedInfo> get posts => feedStreamUpdater.feedPosts;
  bool get isLoadingPosts => feedStreamUpdater.isBusy;

  final pendingReactionChanges = <int>{};

  void init() {
    feedStreamUpdater.addListener(() {
      super.notifyListeners();
    });
  }

  Future<void> updateFeed() async {
    await feedStreamUpdater.updateFeed();
  }

  bool isNewPost(DateTime dateTimePublish) {
    _lastViewedPostDateTime ??= feedStreamUpdater.lastViewedPostDateTime;
    return _lastViewedPostDateTime!.isBefore(dateTimePublish);
  }

  void loadNextPage() {
    feedStreamUpdater.loadNextPage();
  }

  ReactionType? getReactionToPost(PostWithLoadedInfo post) {
    final profileId = currentUserSyncStorage.currentUserData?.bitrixId;
    return profileId != null
        ? post.ratingList.getReactionByUser(profileId)
        : null;
  }

  void _setReactionToPost(
    PostWithLoadedInfo post,
    ReactionType? reaction,
  ) async {
    if (post.post.keySigned == null) {
      return;
    }
    final profileId = currentUserSyncStorage.currentUserData?.bitrixId;
    if (profileId == null) {
      return;
    }
    if (reaction == null) {
      // Сохраняем то, что сейчас есть в списке
      final currentReactionInfo =
          post.ratingList.getReactionInfoByUser(profileId);
      final currentReaction = post.ratingList.getReactionByUser(profileId);
      if (currentReactionInfo == null || currentReaction == null) {
        return;
      }
      pendingReactionChanges.add(post.post.id);
      // Временно удаляем реакцию, чтобы показать действие
      post.ratingList.removeReaction(profileId);
      super.notifyListeners();
      if (!await reactionManager.removeReaction(post.post.keySigned!)) {
        // Если реакция не удалилась - восстанавливаем её
        post.ratingList.addReactions(currentReaction, [currentReactionInfo]);
        super.notifyListeners();
      }
      pendingReactionChanges.remove(post.post.id);
    } else {
      pendingReactionChanges.add(post.post.id);
      // Добавляем временно, чтобы сразу показать действие
      post.ratingList
          .addReactions(reaction, [ReactionUserInfo(profileId, '', '')]);
      super.notifyListeners();
      final reactionUserInfo =
          await reactionManager.addReaction(reaction, post.post.keySigned!);
      // Удаляем временную реакцию
      post.ratingList.removeReaction(profileId);
      if (reactionUserInfo != null) {
        // Если реакция реально добавилась - фиксируем это
        post.ratingList.addReactions(reaction, [reactionUserInfo]);
      }
      pendingReactionChanges.remove(post.post.id);
      super.notifyListeners();
    }
  }

  void toggleLike(PostWithLoadedInfo post) {
    if (pendingReactionChanges.contains(post.post.id)) {
      return;
    }
    if (getReactionToPost(post) != null) {
      _setReactionToPost(post, null);
    } else {
      _setReactionToPost(post, ReactionType.like);
    }
    super.notifyListeners();
  }

  void toggleReaction(PostWithLoadedInfo post, ReactionType reaction) async {
    if (pendingReactionChanges.contains(post.post.id)) {
      return;
    }
    _setReactionToPost(post, null);
    if (getReactionToPost(post) != reaction) {
      _setReactionToPost(post, reaction);
    }
    super.notifyListeners();
  }
}

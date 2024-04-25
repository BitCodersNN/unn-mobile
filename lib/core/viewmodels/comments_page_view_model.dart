import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/blog_post_comment_with_loaded_info.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class CommentsPageViewModel extends BaseViewModel {
  final _gettingBlogPostCommentsService =
      Injector.appInstance.get<GettingBlogPostComments>();
  final _gettingProfileService = Injector.appInstance.get<GettingProfile>();
  final _gettingFileDataService = Injector.appInstance.get<GettingFileData>();
  final _lruCacheBlogPostCommentWithLoadedInfo =
      Injector.appInstance.get<LRUCacheBlogPostCommentWithLoadedInfo>();
  final _lruCacheProfile = Injector.appInstance.get<LRUCacheUserData>();

  BlogData? post;
  List<Future<List<BlogPostCommentWithLoadedInfo?>>> commentLoaders = [];

  int lastPage = 1;
  int totalPages = 1;

  Future<BlogPostCommentWithLoadedInfo?> loadCommentInfo(
    BlogPostComment comment,
  ) async {
    final futures = <Future>[];

    BlogPostCommentWithLoadedInfo? blogPostCommentWithLoadedInfo =
        _lruCacheBlogPostCommentWithLoadedInfo.get(comment.id);

    if (blogPostCommentWithLoadedInfo != null) {
      return blogPostCommentWithLoadedInfo;
    }

    UserData? profile = _lruCacheProfile.get(comment.authorId);

    if (profile == null) {
      futures.add(_gettingProfileService.getProfileByAuthorIdFromPost(
        authorId: comment.authorId,
      ));
    }

    for (final fileId in comment.attachedFiles) {
      futures.add(_gettingFileDataService.getFileData(id: fileId));
    }

    final data = await Future.wait(futures);

    final startPosFilesInData = profile == null ? 1 : 0;
    profile ??= data.first;

    blogPostCommentWithLoadedInfo = BlogPostCommentWithLoadedInfo(
      comment: comment,
      author: profile!,
      files:
          List<FileData>.from(data.getRange(startPosFilesInData, data.length)),
    );

    _lruCacheProfile.save(
      comment.authorId,
      profile,
    );

    _lruCacheBlogPostCommentWithLoadedInfo.save(
      comment.id,
      blogPostCommentWithLoadedInfo,
    );

    return blogPostCommentWithLoadedInfo;
  }

  Future<List<BlogPostCommentWithLoadedInfo?>> loadComments(int page) async {
    if (post == null) {
      return [];
    }
    if (page == 1) {
      final comNumbers =
          (await Injector.appInstance.get<GettingBlogPosts>().getBlogPosts(
                    postId: post!.id,
                  ))?[0]
              .numberOfComments;
      if (comNumbers != null) {
        const commentsPerPage = 20;
        totalPages = comNumbers ~/ commentsPerPage +
            ((comNumbers % commentsPerPage == 0) ? 0 : 1);
      }
    }
    final comments = await _gettingBlogPostCommentsService.getBlogPostComments(
      postId: post!.id,
      pageNumber: page,
    );
    if (comments == null) {
      return [];
    }
    return await Future.wait(comments.map(
      (e) => loadCommentInfo(e),
    ));
  }

  void loadMoreComments() {
    if (lastPage == totalPages) {
      return;
    }
    lastPage++;
    commentLoaders.add(loadComments(lastPage));
    notifyListeners();
  }

  void refresh() {
    commentLoaders.clear();
    lastPage = 1;
    commentLoaders.add(loadComments(1));
    notifyListeners();
  }

  bool get commentsAvailable => lastPage < totalPages;
  void init(BlogData post) {
    this.post = post;
    commentLoaders.add(loadComments(1));
    notifyListeners();
  }
}

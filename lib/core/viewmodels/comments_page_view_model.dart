import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/blog_post_comment_with_loaded_info.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class CommentsPageViewModel extends BaseViewModel {
  final GettingBlogPostComments gettingBlogPostCommentsService;
  final GettingProfile gettingProfileService;
  final GettingFileData gettingFileDataService;
  final LRUCacheBlogPostCommentWithLoadedInfo
      lruCacheBlogPostCommentWithLoadedInfo;
  final LRUCacheUserData lruCacheProfile;
  final GettingRatingList gettingRatingList;
  final GettingBlogPosts gettingBlogPosts;

  BlogData? post;
  List<Future<List<BlogPostCommentWithLoadedInfo?>>> commentLoaders = [];

  int lastPage = 1;
  int totalPages = 1;

  CommentsPageViewModel(
    this.gettingBlogPostCommentsService,
    this.gettingProfileService,
    this.gettingFileDataService,
    this.lruCacheBlogPostCommentWithLoadedInfo,
    this.lruCacheProfile,
    this.gettingRatingList,
    this.gettingBlogPosts,
  );

  Future<BlogPostCommentWithLoadedInfo?> loadCommentInfo(
    BlogPostComment comment,
  ) async {
    final futures = <Future>[];

    BlogPostCommentWithLoadedInfo? blogPostCommentWithLoadedInfo =
        lruCacheBlogPostCommentWithLoadedInfo.get(comment.id);

    if (blogPostCommentWithLoadedInfo != null) {
      return blogPostCommentWithLoadedInfo;
    }

    UserData? profile = lruCacheProfile.get(comment.bitrixID);

    if (profile == null) {
      futures.add(
        gettingProfileService.getProfileByAuthorIdFromPost(
          authorId: comment.bitrixID,
        ),
      );
    }

    for (final fileId in comment.attachedFiles) {
      futures.add(gettingFileDataService.getFileData(id: fileId));
    }

    futures.add(
      gettingRatingList.getRatingList(
        voteKeySigned: comment.keySigned,
      ),
    );

    final data = await Future.wait(futures);

    final startPosFilesInData = profile == null ? 1 : 0;
    final posRatingListInData =
        startPosFilesInData + (comment.attachedFiles).length;

    profile ??= data.first;

    final List<FileData?> files = List<FileData?>.from(
      data.getRange(
        startPosFilesInData,
        posRatingListInData,
      ),
    );
    final List<FileData> filteredFiles = files //
        .where((element) => element != null)
        .map((e) => e!)
        .toList();

    blogPostCommentWithLoadedInfo = BlogPostCommentWithLoadedInfo(
      comment: comment,
      author: profile!,
      files: filteredFiles,
      ratingList: data[posRatingListInData] ?? RatingList(),
    );

    lruCacheProfile.save(
      comment.bitrixID,
      profile,
    );

    lruCacheBlogPostCommentWithLoadedInfo.save(
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
      final comNumbers = (await gettingBlogPosts.getBlogPosts(
        postId: post!.id,
      ))?[0]
          .numberOfComments;
      if (comNumbers != null) {
        const commentsPerPage = 20;
        totalPages = comNumbers ~/ commentsPerPage +
            ((comNumbers % commentsPerPage == 0) ? 0 : 1);
      }
    }
    final comments = await gettingBlogPostCommentsService.getBlogPostComments(
      postId: post!.id,
      pageNumber: page,
    );
    if (comments == null) {
      return [];
    }
    return await Future.wait(
      comments.map(
        (e) => loadCommentInfo(e),
      ),
    );
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

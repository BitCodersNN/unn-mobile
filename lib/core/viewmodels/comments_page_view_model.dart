import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/models/blog_post_comment_with_loaded_info.dart';
import 'package:unn_mobile/core/models/file_data.dart';
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
  BlogData? post;
  List<Future<List<BlogPostCommentWithLoadedInfo?>>> commentLoaders = [];

  int lastPage = 1;
  int totalPages = 1;

  Future<BlogPostCommentWithLoadedInfo?> loadCommentInfo(
    BlogPostComment comment,
  ) async {
    List<FileData> files = [];
    final authorFuture = _gettingProfileService.getProfileByAuthorIdFromPost(
      authorId: comment.authorId,
    );
    for (final fileId in comment.attachedFiles) {
      final fileData = await _gettingFileDataService.getFileData(id: fileId);
      if (fileData != null) {
        files.add(fileData);
      }
    }
    final author = await authorFuture;
    if (author == null) {
      return null;
    }
    return BlogPostCommentWithLoadedInfo(
        comment: comment, author: author, files: files);
  }

  Future<List<BlogPostCommentWithLoadedInfo?>> loadComments(int page) async {
    if (post == null) {
      return [];
    }
    if (page == 1) {
      final comNumbers = (await Injector.appInstance
              .get<GettingBlogPosts>()
              .getBlogPosts(postId: post!.id))?[0]
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

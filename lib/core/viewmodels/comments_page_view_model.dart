import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class CommentsPageViewModel extends BaseViewModel {
  static const commentsPerPage = 20;
  final GettingBlogPostComments _gettingBlogPostCommentsService;
  final GettingBlogPosts _gettingBlogPosts;

  BlogData? post;

  int loadedPage = 1;
  int totalPages = 1;

  CommentsPageViewModel(
    this._gettingBlogPostCommentsService,
    this._gettingBlogPosts,
  );

  final List<BlogPostComment> comments = [];
  bool get isLoadingComments => state == ViewState.busy;

  Future _loadComments(int page) async {
    if (isLoadingComments) {
      return;
    }
    try {
      setState(ViewState.busy);
      if (post == null) {
        return;
      }
      final comments =
          await _gettingBlogPostCommentsService.getBlogPostComments(
        postId: post!.id,
        pageNumber: page,
      );
      if (comments == null) {
        return;
      }
      this.comments.addAll(comments);
    } finally {
      // Не важно, как мы вышли - флаги убрать всё равно надо
      setState(ViewState.idle);
    }
  }

  Future loadMoreComments() async {
    if (isLoadingComments || loadedPage == 1) {
      return;
    }
    loadedPage--;
    await _loadComments(loadedPage);
  }

  Future refresh() async {
    final posts = await _gettingBlogPosts.getBlogPosts(
      postId: post!.id,
    );
    totalPages = 1;
    final commentNumbers = (posts)?[0].numberOfComments;
    if (commentNumbers != null) {
      totalPages = commentNumbers ~/ commentsPerPage +
          ((commentNumbers % commentsPerPage == 0) ? 0 : 1);
    }
    loadedPage = totalPages;
    comments.clear();

    await _loadComments(loadedPage);
    // Загружаем до конца, либо первые 3 страницы, если их больше
    while (loadedPage > 1 && loadedPage > totalPages - 2) {
      await loadMoreComments();
    }
  }

  bool get commentsAvailable => loadedPage < totalPages;
  void init(BlogData post) {
    this.post = post;
    refresh();
  }
}

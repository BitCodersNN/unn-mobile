import 'package:unn_mobile/core/models/blog_post.dart';

abstract interface class BlogPostsService {
  Future<List<BlogPost>?> getBlogPosts({int? pageNumber, int perpage = 50});
}

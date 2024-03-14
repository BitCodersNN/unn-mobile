import 'package:unn_mobile/core/models/blog_data.dart';

abstract interface class GettingBlogPosts {
  Future<List<BlogData>?> getBlogPost({int pageNumber = 0});
}

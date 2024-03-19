import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';




class FeedScreenViewModel extends BaseViewModel {
  final GettingBlogPosts _gettingBlogPosts = Injector.appInstance.get<GettingBlogPosts>();
  Future<List<BlogData>?>? blogPosts;


  void init() {
    blogPosts = _gettingBlogPosts.getBlogPosts();
  }
}

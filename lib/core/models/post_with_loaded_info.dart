import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/user_data.dart';

class PostWithLoadedInfo {
  final UserData _author;
  final BlogData _post;

  PostWithLoadedInfo({required UserData author, required BlogData post})
      : _author = author,
        _post = post;

  UserData get author => _author;
  BlogData get post => _post;
}

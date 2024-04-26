import 'package:unn_mobile/core/models/blog_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/rating_list.dart';
import 'package:unn_mobile/core/models/user_data.dart';

class KeysForPostWithLoadedInfoJsonConverter {
  static const String author = 'author';
  static const String post = 'post';
  static const String files = 'files';
  static const String ratingList = 'ratingList';
}

class PostWithLoadedInfo {
  final UserData _author;
  final BlogData _post;
  final List<FileData> _files;
  final RatingList _ratingList;

  PostWithLoadedInfo({
    required UserData author,
    required BlogData post,
    required List<FileData> files,
    required RatingList ratingList,
  })  : _author = author,
        _post = post,
        _files = files,
        _ratingList = ratingList;

  UserData get author => _author;
  BlogData get post => _post;
  List<FileData> get files => _files;
  RatingList get ratingList => _ratingList;

  factory PostWithLoadedInfo.fromJson(Map<String, Object?> jsonMap) {
    return PostWithLoadedInfo(
      author: UserData.fromJson(
          jsonMap[KeysForPostWithLoadedInfoJsonConverter.author]
              as Map<String, Object?>),
      post: BlogData.fromJson(
          jsonMap[KeysForPostWithLoadedInfoJsonConverter.post]
              as Map<String, Object?>),
      files: (jsonMap[KeysForPostWithLoadedInfoJsonConverter.files]
              as List<dynamic>)
          .map((element) => FileData.fromJson(element))
          .toList(),
      ratingList: RatingList.fromJson(
          jsonMap[KeysForPostWithLoadedInfoJsonConverter.ratingList]
              as Map<String, Object?>),
    );
  }

  Map<String, dynamic> toJson() => {
        KeysForPostWithLoadedInfoJsonConverter.author: _author.toJson(),
        KeysForPostWithLoadedInfoJsonConverter.post: _post.toJson(),
        KeysForPostWithLoadedInfoJsonConverter.files:
            files.map((file) => file.toJson()).toList(),
        KeysForPostWithLoadedInfoJsonConverter.ratingList: _ratingList.toJson(),
      };
}

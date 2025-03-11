import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';

class _BlogPostDataJsonBitrixKeys {
  static const String id = 'ID';
  static const String blogId = 'BLOG_ID';
  static const String authorId = 'AUTHOR_ID';
  static const String title = 'TITLE';
  static const String detailText = 'DETAIL_TEXT';
  static const String datePublish = 'DATE_PUBLISH';
  static const String numComments = 'NUM_COMMENTS';
  static const String files = 'FILES';
}

class _BlogPostDataJsonKeys {
  static const String id = 'id';
  static const String author = 'author';
  static const String title = 'title';
  static const String fulltext = 'fulltext';
  static const String time = 'time';
  static const String commentsNum = 'commentsnum';
  static const String attach = 'attach';
  static const String pinnedId = 'pinnedid';
  static const String keySigned = 'keysigned';
}

class BlogPostData {
  final int id;
  final int? blogId;
  final int authorBitrixId;
  final String title;
  final String detailText;
  final DateTime datePublish;
  final int numberOfComments;
  final List<int>? files;
  final int? pinnedId;
  final String? keySigned;

  BlogPostData._({
    required this.id,
    this.blogId,
    required this.authorBitrixId,
    required this.title,
    required this.detailText,
    required this.datePublish,
    required this.numberOfComments,
    this.files,
    this.pinnedId,
    this.keySigned,
  });

  factory BlogPostData.fromJson(Map<String, Object?> jsonMap) {
    return BlogPostData._(
      id: int.parse(
        jsonMap[_BlogPostDataJsonKeys.id] as String,
      ),
      blogId: null,
      authorBitrixId: int.parse(
        (jsonMap[_BlogPostDataJsonKeys.author]
            as Map<String, Object?>)[_BlogPostDataJsonKeys.id] as String,
      ),
      title: jsonMap[_BlogPostDataJsonKeys.title] as String,
      detailText: jsonMap[_BlogPostDataJsonKeys.fulltext] as String,
      datePublish: DateTimeParser.parse(
        jsonMap[_BlogPostDataJsonKeys.time] as String,
        DatePattern.ddmmyyyyhhmmss,
      ),
      numberOfComments: int.parse(
        jsonMap[_BlogPostDataJsonKeys.commentsNum] as String,
      ),
      files: (jsonMap[_BlogPostDataJsonKeys.attach] as List<dynamic>?)
          ?.map((element) => element.toString().hashCode)
          .toList(),
      pinnedId: jsonMap[_BlogPostDataJsonKeys.pinnedId] as int?,
      keySigned: jsonMap[_BlogPostDataJsonKeys.keySigned] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _BlogPostDataJsonKeys.id: id.toString(),
        _BlogPostDataJsonKeys.author: {
          _BlogPostDataJsonKeys.id: authorBitrixId.toString(),
        },
        _BlogPostDataJsonKeys.title: title,
        _BlogPostDataJsonKeys.fulltext: detailText,
        _BlogPostDataJsonKeys.time:
            datePublish.format(DatePattern.ddmmyyyyhhmmss),
        _BlogPostDataJsonKeys.commentsNum: numberOfComments.toString(),
        _BlogPostDataJsonKeys.attach:
            files?.map((hash) => hash.toString()).toList(),
        _BlogPostDataJsonKeys.pinnedId: pinnedId,
        _BlogPostDataJsonKeys.keySigned: keySigned,
      };

  factory BlogPostData.fromJsonLegacy(Map<String, Object?> jsonMap) {
    return BlogPostData._(
      id: int.parse(
        jsonMap[_BlogPostDataJsonBitrixKeys.id] as String,
      ),
      blogId: int.tryParse(
        jsonMap[_BlogPostDataJsonBitrixKeys.blogId] as String,
      ),
      authorBitrixId: int.parse(
        jsonMap[_BlogPostDataJsonBitrixKeys.authorId] as String,
      ),
      title: jsonMap[_BlogPostDataJsonBitrixKeys.title] as String,
      detailText: jsonMap[_BlogPostDataJsonBitrixKeys.detailText] as String,
      datePublish: DateTime.parse(
        jsonMap[_BlogPostDataJsonBitrixKeys.datePublish] as String,
      ),
      numberOfComments: int.parse(
        jsonMap[_BlogPostDataJsonBitrixKeys.numComments] as String,
      ),
      files: (jsonMap[_BlogPostDataJsonBitrixKeys.files] as List<dynamic>?)
          ?.map((element) => element as int)
          .toList(),
    );
  }
}

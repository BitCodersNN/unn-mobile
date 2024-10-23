import 'package:intl/intl.dart';

class _KeysForBlogPostDataJsonConverter {
  static const String id = 'ID';
  static const String blogId = 'BLOG_ID';
  static const String authorID = 'AUTHOR_ID';
  static const String title = 'TITLE';
  static const String detailText = 'DETAIL_TEXT';
  static const String datePublish = 'DATE_PUBLISH';
  static const String numComments = 'NUM_COMMENTS';
  static const String files = 'FILES';
}

class _KeysForBlogPostDataJsonConverterPortal2 {
  static const String id = 'id';
  static const String author = 'author';
  static const String title = 'title';
  static const String fulltext = 'fulltext';
  static const String time = 'time';
  static const String commentsnum = 'commentsnum';
  static const String attach = 'attach';
  static const String pinnedId = 'pinnedid';
  static const String keySigned = 'keysigned';
}

class BlogPostData {
  final int id;
  final int? blogId;
  final int bitrixID;
  final String title;
  final String detailText;
  final DateTime datePublish;
  final int numberOfComments;
  final List<int>? files;
  final int? pinnedid;
  final String? keySigned;

  BlogPostData._({
    required this.id,
    this.blogId,
    required this.bitrixID,
    required this.title,
    required this.detailText,
    required this.datePublish,
    required this.numberOfComments,
    this.files,
    this.pinnedid,
    this.keySigned,
  });

  factory BlogPostData.fromJson(Map<String, Object?> jsonMap) {
    return BlogPostData._(
      id: int.parse(jsonMap[_KeysForBlogPostDataJsonConverter.id] as String),
      blogId: int.tryParse(
          jsonMap[_KeysForBlogPostDataJsonConverter.blogId] as String),
      bitrixID: int.parse(
          jsonMap[_KeysForBlogPostDataJsonConverter.authorID] as String),
      title: jsonMap[_KeysForBlogPostDataJsonConverter.title] as String,
      detailText:
          jsonMap[_KeysForBlogPostDataJsonConverter.detailText] as String,
      datePublish: DateTime.parse(
        jsonMap[_KeysForBlogPostDataJsonConverter.datePublish] as String,
      ),
      numberOfComments: int.parse(
        jsonMap[_KeysForBlogPostDataJsonConverter.numComments] as String,
      ),
      files:
          (jsonMap[_KeysForBlogPostDataJsonConverter.files] as List<dynamic>?)
              ?.map((element) => element as int)
              .toList(),
    );
  }

  factory BlogPostData.fromJsonPortal2(Map<String, Object?> jsonMap) {
    return BlogPostData._(
      id: int.parse(
          jsonMap[_KeysForBlogPostDataJsonConverterPortal2.id] as String),
      blogId: null,
      bitrixID: int.parse(
        (jsonMap[_KeysForBlogPostDataJsonConverterPortal2.author] as Map<String,
            Object?>)[_KeysForBlogPostDataJsonConverterPortal2.id] as String,
      ),
      title: jsonMap[_KeysForBlogPostDataJsonConverterPortal2.title] as String,
      detailText:
          jsonMap[_KeysForBlogPostDataJsonConverterPortal2.fulltext] as String,
      datePublish: _parseCustomDateTime(
        jsonMap[_KeysForBlogPostDataJsonConverterPortal2.time] as String,
      ),
      numberOfComments: int.parse(
        jsonMap[_KeysForBlogPostDataJsonConverterPortal2.commentsnum] as String,
      ),
      files: (jsonMap[_KeysForBlogPostDataJsonConverterPortal2.attach]
              as List<dynamic>?)
          ?.map((element) => element.toString().hashCode)
          .toList(),
      pinnedid:
          jsonMap[_KeysForBlogPostDataJsonConverterPortal2.pinnedId] as int?,
      keySigned: jsonMap[_KeysForBlogPostDataJsonConverterPortal2.keySigned]
          as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForBlogPostDataJsonConverter.id: id,
        _KeysForBlogPostDataJsonConverter.blogId: blogId,
        _KeysForBlogPostDataJsonConverter.authorID: bitrixID,
        _KeysForBlogPostDataJsonConverter.title: title,
        _KeysForBlogPostDataJsonConverter.detailText: detailText,
        _KeysForBlogPostDataJsonConverter.datePublish: datePublish.toString(),
        _KeysForBlogPostDataJsonConverter.numComments: numberOfComments,
        _KeysForBlogPostDataJsonConverter.files: files,
      };

  static DateTime _parseCustomDateTime(String input) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm:ss');
    return formatter.parse(input);
  }
}

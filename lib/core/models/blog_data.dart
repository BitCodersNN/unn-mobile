import 'package:intl/intl.dart';

class _KeysForBlogDataJsonConverter {
  static const String id = 'ID';
  static const String blogId = 'BLOG_ID';
  static const String authorID = 'AUTHOR_ID';
  static const String title = 'TITLE';
  static const String detailText = 'DETAIL_TEXT';
  static const String datePublish = 'DATE_PUBLISH';
  static const String numComments = 'NUM_COMMENTS';
  static const String files = 'FILES';
}

class _KeysForBlogDataJsonConverterPortal2 {
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

class BlogData {
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

  BlogData._({
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

  factory BlogData.fromJson(Map<String, Object?> jsonMap) {
    return BlogData._(
      id: int.parse(jsonMap[_KeysForBlogDataJsonConverter.id] as String),
      blogId:
          int.tryParse(jsonMap[_KeysForBlogDataJsonConverter.blogId] as String),
      bitrixID:
          int.parse(jsonMap[_KeysForBlogDataJsonConverter.authorID] as String),
      title: jsonMap[_KeysForBlogDataJsonConverter.title] as String,
      detailText: jsonMap[_KeysForBlogDataJsonConverter.detailText] as String,
      datePublish: DateTime.parse(
        jsonMap[_KeysForBlogDataJsonConverter.datePublish] as String,
      ),
      numberOfComments: int.parse(
        jsonMap[_KeysForBlogDataJsonConverter.numComments] as String,
      ),
      files: (jsonMap[_KeysForBlogDataJsonConverter.files] as List<dynamic>?)
          ?.map((element) => element as int)
          .toList(),
    );
  }

  factory BlogData.fromJsonPortal2(Map<String, Object?> jsonMap) {
    return BlogData._(
      id: int.parse(jsonMap[_KeysForBlogDataJsonConverterPortal2.id] as String),
      blogId: null,
      bitrixID: int.parse(
        (jsonMap[_KeysForBlogDataJsonConverterPortal2.author] as Map<String,
            Object?>)[_KeysForBlogDataJsonConverterPortal2.id] as String,
      ),
      title: jsonMap[_KeysForBlogDataJsonConverterPortal2.title] as String,
      detailText:
          jsonMap[_KeysForBlogDataJsonConverterPortal2.fulltext] as String,
      datePublish: _parseCustomDateTime(
        jsonMap[_KeysForBlogDataJsonConverterPortal2.time] as String,
      ),
      numberOfComments: int.parse(
        jsonMap[_KeysForBlogDataJsonConverterPortal2.commentsnum] as String,
      ),
      files: (jsonMap[_KeysForBlogDataJsonConverterPortal2.attach]
              as List<dynamic>?)
          ?.map((element) => element.toString().hashCode)
          .toList(),
      pinnedid: jsonMap[_KeysForBlogDataJsonConverterPortal2.pinnedId] as int?,
      keySigned:
          jsonMap[_KeysForBlogDataJsonConverterPortal2.keySigned] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForBlogDataJsonConverter.id: id,
        _KeysForBlogDataJsonConverter.blogId: blogId,
        _KeysForBlogDataJsonConverter.authorID: bitrixID,
        _KeysForBlogDataJsonConverter.title: title,
        _KeysForBlogDataJsonConverter.detailText: detailText,
        _KeysForBlogDataJsonConverter.datePublish: datePublish.toString(),
        _KeysForBlogDataJsonConverter.numComments: numberOfComments,
        _KeysForBlogDataJsonConverter.files: files,
      };

  static DateTime _parseCustomDateTime(String input) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm:ss');
    return formatter.parse(input);
  }
}

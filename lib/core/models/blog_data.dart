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

class BlogData {
  String? keySigned;

  final int _id;
  final int _blogId;
  final int _bitrixID;
  final String _title;
  final String _detailText;
  final DateTime _datePublish;
  final int _numberOfComments;
  final List<String>? _files;
  final int? _pinnedid;
  BlogData(
    this._id,
    this._blogId,
    this._bitrixID,
    this._title,
    this._detailText,
    this._datePublish,
    this._numberOfComments,
    this._files, [
    this._pinnedid,
    this.keySigned,
  ]);

  int get id => _id;
  int get blogId => _blogId;
  int get bitrixID => _bitrixID;
  String get title => _title;
  String get detailText => _detailText;
  DateTime get datePublish => _datePublish;
  int get numberOfComments => _numberOfComments;
  List<String>? get files => _files;
  int? get pinnedid => _pinnedid;

  factory BlogData.fromJson(Map<String, Object?> jsonMap) => BlogData(
        int.parse(jsonMap[_KeysForBlogDataJsonConverter.id] as String),
        int.parse(jsonMap[_KeysForBlogDataJsonConverter.blogId] as String),
        int.parse(jsonMap[_KeysForBlogDataJsonConverter.authorID] as String),
        jsonMap[_KeysForBlogDataJsonConverter.title] as String,
        jsonMap[_KeysForBlogDataJsonConverter.detailText] as String,
        DateTime.parse(
          jsonMap[_KeysForBlogDataJsonConverter.datePublish] as String,
        ),
        int.parse(jsonMap[_KeysForBlogDataJsonConverter.numComments] as String),
        (jsonMap[_KeysForBlogDataJsonConverter.files] as List<dynamic>?)
            ?.map((element) => element.toString())
            .toList(),
      );

  factory BlogData.fromJsonAlt(Map<String, Object?> jsonMap) => BlogData(
        int.parse(
          jsonMap[_KeysForBlogDataJsonConverter.id.toLowerCase()] as String,
        ),
        int.parse(jsonMap['id'] as String),
        int.parse((jsonMap['author'] as Map<String, Object?>)['id'] as String),
        jsonMap[_KeysForBlogDataJsonConverter.title.toLowerCase()] as String,
        jsonMap['fulltext'] as String,
        _parseCustomDateTime(
          jsonMap['time'] as String,
        ),
        int.parse(jsonMap['commentsnum'] as String),
        (jsonMap['attach'] as List<dynamic>?)
            ?.map((element) => element.toString())
            .toList(),
        jsonMap['pinnedid'] as int,
        jsonMap['keysigned'] as String,
      );

  Map<String, dynamic> toJson() => {
        _KeysForBlogDataJsonConverter.id: _id,
        _KeysForBlogDataJsonConverter.blogId: _blogId,
        _KeysForBlogDataJsonConverter.authorID: bitrixID,
        _KeysForBlogDataJsonConverter.title: _title,
        _KeysForBlogDataJsonConverter.detailText: detailText,
        _KeysForBlogDataJsonConverter.datePublish: _datePublish.toString(),
        _KeysForBlogDataJsonConverter.numComments: _numberOfComments,
        _KeysForBlogDataJsonConverter.files: files,
      };

  static DateTime _parseCustomDateTime(String input) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm:ss');
    return formatter.parse(input);
  }
}

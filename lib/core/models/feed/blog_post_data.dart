import 'package:intl/intl.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';

class _KeysForBlogPostDataJsonConverterLegacy {
  static const String id = 'ID';
  static const String blogId = 'BLOG_ID';
  static const String authorId = 'AUTHOR_ID';
  static const String title = 'TITLE';
  static const String detailText = 'DETAIL_TEXT';
  static const String datePublish = 'DATE_PUBLISH';
  static const String numComments = 'NUM_COMMENTS';
  static const String files = 'FILES';
}

class _KeysForBlogPostDataJsonConverter {
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
        jsonMap[_KeysForBlogPostDataJsonConverter.id] as String,
      ),
      blogId: null,
      authorBitrixId: int.parse(
        (jsonMap[_KeysForBlogPostDataJsonConverter.author]
                as Map<String, Object?>)[_KeysForBlogPostDataJsonConverter.id]
            as String,
      ),
      title: jsonMap[_KeysForBlogPostDataJsonConverter.title] as String,
      detailText: jsonMap[_KeysForBlogPostDataJsonConverter.fulltext] as String,
      datePublish: _parseCustomDateTime(
        jsonMap[_KeysForBlogPostDataJsonConverter.time] as String,
      ),
      numberOfComments: int.parse(
        jsonMap[_KeysForBlogPostDataJsonConverter.commentsNum] as String,
      ),
      files:
          (jsonMap[_KeysForBlogPostDataJsonConverter.attach] as List<dynamic>?)
              ?.map((element) => element.toString().hashCode)
              .toList(),
      pinnedId: jsonMap[_KeysForBlogPostDataJsonConverter.pinnedId] as int?,
      keySigned:
          jsonMap[_KeysForBlogPostDataJsonConverter.keySigned] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForBlogPostDataJsonConverter.id: id.toString(),
        _KeysForBlogPostDataJsonConverter.author: {
          _KeysForBlogPostDataJsonConverter.id: authorBitrixId.toString(),
        },
        _KeysForBlogPostDataJsonConverter.title: title,
        _KeysForBlogPostDataJsonConverter.fulltext: detailText,
        _KeysForBlogPostDataJsonConverter.time:
            datePublish.formatDateTime(DatePattern.ddmmyyyyhhmmss),
        _KeysForBlogPostDataJsonConverter.commentsNum:
            numberOfComments.toString(),
        _KeysForBlogPostDataJsonConverter.attach:
            files?.map((hash) => hash.toString()).toList(),
        _KeysForBlogPostDataJsonConverter.pinnedId: pinnedId,
        _KeysForBlogPostDataJsonConverter.keySigned: keySigned,
      };

  factory BlogPostData.fromJsonLegacy(Map<String, Object?> jsonMap) {
    return BlogPostData._(
      id: int.parse(
        jsonMap[_KeysForBlogPostDataJsonConverterLegacy.id] as String,
      ),
      blogId: int.tryParse(
        jsonMap[_KeysForBlogPostDataJsonConverterLegacy.blogId] as String,
      ),
      authorBitrixId: int.parse(
        jsonMap[_KeysForBlogPostDataJsonConverterLegacy.authorId] as String,
      ),
      title: jsonMap[_KeysForBlogPostDataJsonConverterLegacy.title] as String,
      detailText:
          jsonMap[_KeysForBlogPostDataJsonConverterLegacy.detailText] as String,
      datePublish: DateTime.parse(
        jsonMap[_KeysForBlogPostDataJsonConverterLegacy.datePublish] as String,
      ),
      numberOfComments: int.parse(
        jsonMap[_KeysForBlogPostDataJsonConverterLegacy.numComments] as String,
      ),
      files: (jsonMap[_KeysForBlogPostDataJsonConverterLegacy.files]
              as List<dynamic>?)
          ?.map((element) => element as int)
          .toList(),
    );
  }

  static DateTime _parseCustomDateTime(String input) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm:ss');
    return formatter.parse(input);
  }
}

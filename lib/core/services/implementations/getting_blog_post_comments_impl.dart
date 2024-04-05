import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/blog_post_comment.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_post_comments.dart';

class _JsonKeys {
  static const _messageListKey = 'messageList';
}

class _RegularExpSource {
  static const commentIdAndMessage = r"top\.text\d+ = text(\d+) = '([^']*)'";
  static const author =
      r'<span class="feed-com-name.*?feed-author-name-(\d+)">([^<]+)<\/span>';
  static const dateTime =
      r'<a.*?class=\s*"[^"]*feed-com-time[^"]*"[^>]*>([^<]+)<\/a>';
  static const files =
      r"top\.arComDFiles(\d+) = BX\.util\.array_merge\(\(top\.arComDFiles\d+ \|\| \[\]\), \[(.*?)\]";
}

class GettingBlogPostCommentsImpl implements GettingBlogPostComments {
  @override
  Future<List<BlogPostComment>?> getBlogPostComments({
    required int postId,
    int pageNumber = 1,
  }) async {
    final authService = Injector.appInstance.get<AuthorisationService>();

    final sessionId = authService.sessionId;
    final csrf = authService.csrf;

    if (sessionId == null || csrf == null) {
      FirebaseCrashlytics.instance
          .log("GettingBlogPostCommentsService: Error, user not authorized");
      return null;
    }

    final bodyAsString = await getRawBodyOfBlogComments(
      postId: postId,
      pageNumber: pageNumber,
      csrf: csrf,
      sessionId: sessionId,
    );

    if (bodyAsString == null) {
      return null;
    }

    return parseComments(bodyAsString);
  }

  Future<String?> getRawBodyOfBlogComments({
    required int postId,
    int pageNumber = 0,
    required String csrf,
    required String sessionId,
  }) async {
    final requestSender = HttpRequestSender(
      path: "/bitrix/services/main/ajax.php",
      queryParams: {
        "mode": "class",
        "action": "navigateComment",
        "c": "bitrix:socialnetwork.blog.post.comment",
      },
      headers: {"X-Bitrix-Csrf-Token": csrf},
      cookies: {"PHPSESSID": sessionId},
    );

    final HttpClientResponse response;
    try {
      response = await requestSender.postForm(
        {
          "ENTITY_XML_ID": "BLOG_$postId",
          "AJAX_POST": "Y",
          "MODE": "LIST",
          "comment_post_id": postId.toString(),
          "PAGEN_1": pageNumber.toString()
        },
        timeoutSeconds: 30,
      );
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance
          .log("Exception: $error\nStackTrace: $stackTrace");
      return null;
    }

    if (response.statusCode != 200) {
      await FirebaseCrashlytics.instance.log(
          '${runtimeType.toString()}: statusCode = ${response.statusCode}');
      return null;
    }

    return await HttpRequestSender.responseToStringBody(response);
  }

  List<BlogPostComment>? parseComments(String jsonStr) {
    const unknownString = 'unknown';

    final Map<String, dynamic> parsedJson = json.decode(jsonStr);

    if (!parsedJson.containsKey(_JsonKeys._messageListKey)) {
      FirebaseCrashlytics.instance.log(
          '${runtimeType.toString()}: json doesn\'t contain the messageList key');
      return null;
    }

    final htmlBody = parsedJson[_JsonKeys._messageListKey] as String;

    final comments = <BlogPostComment>[];

    final commentsAttachedFilesId = parseCommentsFilesId(htmlBody);

    final commentIdAndMessageRegExp = RegExp(
      _RegularExpSource.commentIdAndMessage,
    );

    final authorRegExp = RegExp(
      _RegularExpSource.author,
    );

    final dateTimeRegExp = RegExp(
      _RegularExpSource.dateTime,
    );

    final authorMatches = authorRegExp.allMatches(htmlBody).iterator;
    final dateTimeMatches = dateTimeRegExp.allMatches(htmlBody).iterator;

    for (final messageMatch in commentIdAndMessageRegExp.allMatches(htmlBody)) {
      if (!authorMatches.moveNext()) {
        FirebaseCrashlytics.instance
            .log("GettingBlogPostCommentsService-parser: no author matches");
        break;
      }

      final authorMatch = authorMatches.current;

      if (!dateTimeMatches.moveNext()) {
        FirebaseCrashlytics.instance
            .log("GettingBlogPostCommentsService-parser: no dateTime matches");
        break;
      }

      final dateTimeMatch = dateTimeMatches.current;

      final id = messageMatch.group(1).toInt();
      final message = messageMatch.group(2);
      final authorId = authorMatch.group(1).toInt();
      final authorName = authorMatch.group(2);
      final dateTime = dateTimeMatch.group(1);

      if (id != null && authorId != null) {
        comments.add(BlogPostComment(
          id: id,
          authorId: authorId,
          authorName: authorName ?? unknownString,
          dateTime: dateTime ?? unknownString,
          message: message ?? unknownString,
          attachedFiles: commentsAttachedFilesId[id] ?? [],
        ));
      }
    }

    return comments;
  }

  Map<int, List<int>> parseCommentsFilesId(String htmlBody) {
    final filesRegExp = RegExp(
      _RegularExpSource.files,
    );

    final commentIdToAttachFiles = <int, List<int>>{};

    filesRegExp.allMatches(htmlBody).forEach((match) {
      final commentId = match.group(1);
      final filesListAsString = match.group(2);

      if (commentId != null && filesListAsString != null) {
        final commentIdAsInt = commentId.toInt();
        if (commentIdAsInt != null) {
          commentIdToAttachFiles[commentIdAsInt] =
              filesListAsString.split(",").map((idAsString) {
            return idAsString.substring(1, idAsString.length - 1).toInt()!;
          }).toList();
        }
      }
    });

    return commentIdToAttachFiles;
  }
}

extension on String? {
  int? toInt() {
    if (this == null) {
      return null;
    }

    try {
      return int.parse(this!);
    } on FormatException {
      return null;
    }
  }
}

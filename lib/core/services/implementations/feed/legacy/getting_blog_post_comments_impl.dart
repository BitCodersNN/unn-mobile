import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/http_helper.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';

class _JsonKeys {
  static const _messageListKey = 'messageList';
}

class GettingBlogPostCommentsImpl implements GettingBlogPostComments {
  final AuthorizationService _authService;
  final LoggerService _loggerService;

  GettingBlogPostCommentsImpl(
    this._authService,
    this._loggerService,
  );
  @override
  Future<List<BlogPostCommentData>?> getBlogPostComments({
    required int postId,
    int pageNumber = 1,
  }) async {
    final sessionId = _authService.sessionId;
    final csrf = _authService.csrf;

    if (sessionId == null || csrf == null) {
      _loggerService.log('Error, user not authorized');
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
      path: ApiPaths.ajax,
      queryParams: {
        'mode': 'class',
        AjaxActionStrings.actionKey: AjaxActionStrings.navigateComment,
        'c': AjaxActionStrings.comment,
      },
      headers: {SessionIdentifierStrings.csrfToken: csrf},
      cookies: {SessionIdentifierStrings.sessionIdCookieKey: sessionId},
    );

    final HttpClientResponse response;
    try {
      response = await requestSender.postForm(
        {
          'ENTITY_XML_ID': 'BLOG_$postId',
          'AJAX_POST': 'Y',
          'MODE': 'LIST',
          'comment_post_id': postId.toString(),
          'PAGEN_1': pageNumber.toString(),
        },
        timeoutSeconds: 30,
      );
    } catch (error, stackTrace) {
      _loggerService.log('Exception: $error\nStackTrace: $stackTrace');
      return null;
    }

    if (response.statusCode != 200) {
      _loggerService.log(
        '${runtimeType.toString()}: statusCode = ${response.statusCode}',
      );
      return null;
    }

    return await HttpRequestSender.responseToStringBody(response);
  }

  List<BlogPostCommentData>? parseComments(String jsonStr) {
    const unknownString = 'unknown';

    final Map<String, dynamic> parsedJson = json.decode(jsonStr);

    if (!parsedJson.containsKey(_JsonKeys._messageListKey)) {
      _loggerService.log(
        'json doesn\'t contain the messageList key',
      );
      return null;
    }

    final htmlBody = parsedJson[_JsonKeys._messageListKey] as String;

    final comments = <BlogPostCommentData>[];

    final commentsAttachedFilesId = parseCommentsFilesId(htmlBody);

    final authorMatches =
        RegularExpressions.authorRegExp.allMatches(htmlBody).iterator;
    final dateTimeMatches =
        RegularExpressions.dateTimeRegExp.allMatches(htmlBody).iterator;
    final keySignedMatches =
        RegularExpressions.keySignedRegExp.allMatches(htmlBody).iterator;

    for (final messageMatch
        in RegularExpressions.commentIdAndMessageRegExp.allMatches(htmlBody)) {
      if (!authorMatches.moveNext()) {
        _loggerService.log('no author matches');
        break;
      }

      final authorMatch = authorMatches.current;

      if (!dateTimeMatches.moveNext()) {
        _loggerService.log('no dateTime matches');
        break;
      }

      if (!keySignedMatches.moveNext()) {
        _loggerService.log('no keySigned matches');
        break;
      }

      final dateTimeMatch = dateTimeMatches.current;
      final keySignedMatche = keySignedMatches.current;

      final id = messageMatch.group(1).toInt();
      final message = messageMatch.group(2)?.replaceAll('\\n', '\n');
      final authorId = authorMatch.group(1).toInt();
      final dateTime = dateTimeMatch.group(1);
      final keySigned =
          keySignedMatche.group(0)?.split(' \'')[1].split('\'')[0];

      if (id != null && authorId != null) {
        comments.add(
          BlogPostCommentData(
            id: id,
            bitrixId: authorId,
            dateTime: dateTime ?? unknownString,
            message: message ?? unknownString,
            keySigned: keySigned ?? unknownString,
            attachedFiles: commentsAttachedFilesId[id] ?? [],
          ),
        );
      }
    }

    return comments;
  }

  Map<int, List<int>> parseCommentsFilesId(String htmlBody) {
    final commentIdToAttachFiles = <int, List<int>>{};

    RegularExpressions.filesRegExp.allMatches(htmlBody).forEach((match) {
      final commentId = match.group(1);
      final filesListAsString = match.group(2);

      if (commentId != null && filesListAsString != null) {
        final commentIdAsInt = commentId.toInt();
        if (commentIdAsInt != null) {
          commentIdToAttachFiles[commentIdAsInt] =
              filesListAsString.split(',').map((idAsString) {
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

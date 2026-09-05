// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/string_keys/feed_html_parser_strings.dart';
import 'package:unn_mobile/core/misc/html_utils/bitrix_html_parser.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment.dart';
import 'package:unn_mobile/core/models/feed/blog_post_comment_data.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class BlogPostCommentHtmlParser {
  static List<BlogPostComment>? parse(
    String? htmlText,
    UserShortInfo currentUserData,
  ) {
    final document = parser.parse(htmlText);
    final commentElements =
        document.querySelectorAll(FeedHtmlParserStrings.feedComBlockCover);

    return commentElements
        .map((element) => _parseComment(element, currentUserData))
        .toList();
  }

  static BlogPostComment _parseComment(
    Element commentElement,
    UserShortInfo currentUserData,
  ) {
    final attachFiles = BitrixHtmlParserUtils.extractAttachedFiles(
      commentElement,
      FeedHtmlParserStrings.attachedFilesSelectorGeneral,
      skipIfInCommentsBlock: false,
    );

    final authorInfo = BitrixHtmlParserUtils.parseAuthorInfo(
      commentElement,
      FeedHtmlParserStrings.selAuthorLink, // Обновлено: был authorLinkSelector
      FeedHtmlParserStrings
          .attrBxTooltipUserId, // Обновлено: был bxTooltipUserIdAttr
      FeedHtmlParserStrings.unknownAuthor,
    );

    return BlogPostComment(
      data: _parseCommentData(commentElement, attachFiles, authorInfo),
      ratingList: BitrixHtmlParserUtils.parseRatingList(
        commentElement,
        currentUserData,
        FeedHtmlParserStrings.feedPostEmojiContainerSimple,
        null,
      ),
      userShortInfo: authorInfo,
      attachFiles: attachFiles,
    );
  }

  static BlogPostCommentData _parseCommentData(
    Element commentElement,
    List<FileData> attachFiles,
    UserShortInfo authorInfo,
  ) {
    final commentId =
        _extractCommentId(commentElement) ?? FeedHtmlParserStrings.unknownId;

    return BlogPostCommentData(
      authorBitrixId: authorInfo.bitrixId ?? FeedHtmlParserStrings.unknownId,
      id: commentId,
      dateTime: commentElement
              .querySelector(FeedHtmlParserStrings.feedComTime)
              ?.text
              .trim() ??
          FeedHtmlParserStrings.unknownValue,
      message: commentElement
              .querySelector(FeedHtmlParserStrings.feedComTextInnerInner)
              ?.innerHtml
              .trim() ??
          FeedHtmlParserStrings.unknownValue,
      keySigned: BitrixHtmlParserUtils.extractKeySigned(
        commentElement,
        FeedHtmlParserStrings.blogCommentPrefix,
        commentId.toString(),
      ),
      imageUrls: _extractImageUrls(commentElement),
      attachedFiles: attachFiles.map((f) => f.id).toList(),
    );
  }

  static int? _extractCommentId(Element element) {
    // Обновлено: bxMplEntityIdAttr -> attrBxMplEntityId
    final entityId =
        element.attributes[FeedHtmlParserStrings.attrBxMplEntityId];
    if (entityId != null) {
      return int.tryParse(entityId);
    }

    // Обновлено: idAttr -> attrId
    final recordId = element.attributes[FeedHtmlParserStrings.attrId];
    if (recordId == null) {
      return null;
    }

    final match = RegularExpressions.recordBlogRegExp.firstMatch(recordId);
    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1) ?? '');
  }

  static List<String> _extractImageUrls(Element element) {
    final urls = <String>{};
    BitrixHtmlParserUtils.extractImagesToSet(
      element,
      FeedHtmlParserStrings.imageSelector,
      FeedHtmlParserStrings.imageSrcAttributesFull,
      urls,
    );
    return urls.toList();
  }
}

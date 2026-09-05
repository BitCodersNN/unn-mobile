// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/string_keys/feed_html_parser_strings.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_parser.dart';
import 'package:unn_mobile/core/misc/html_utils/bitrix_html_parser.dart';
import 'package:unn_mobile/core/misc/html_utils/html_image_utils.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/models/feed/important_blog_post.dart';
import 'package:unn_mobile/core/models/feed/post_destination.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class BlogPostHtmlParser {
  static BlogPost? parsePost(
    String? htmlText,
    UserShortInfo currentUserData,
  ) {
    final document = parser.parse(
      htmlText,
    );
    final postElement = document.querySelector('.feed-item-wrap');

    if (postElement == null) {
      return null;
    }

    final postType = _getPostType(postElement);

    return _parsePost(postElement, currentUserData, postType);
  }

  static Map<BlogPostType, List<BlogPost>>? parsePosts(
    String? htmlText,
    UserShortInfo currentUserData,
  ) {
    final document = parser.parse(htmlText);
    final postElements =
        document.querySelectorAll(FeedHtmlParserStrings.feedItemWrap);
    final blogPosts = <BlogPostType, List<BlogPost>>{};

    for (final post in postElements) {
      final postType = _getPostType(post);
      final blogPost = _parsePost(post, currentUserData, postType);

      final targetKey = switch (postType) {
        ExtendedBlogPostType.pinned ||
        ExtendedBlogPostType.importantPinned =>
          BlogPostType.pinned,
        _ => BlogPostType.regular,
      };

      blogPosts.putIfAbsent(targetKey, () => []).add(blogPost);
    }
    return blogPosts;
  }

  static BlogPost _parsePost(
    Element postElement,
    UserShortInfo currentUserData,
    ExtendedBlogPostType blogPostType,
  ) {
    final (postData, attachFiles) = _parsePostData(postElement);
    final authorInfo = BitrixHtmlParserUtils.parseAuthorInfo(
      postElement,
      FeedHtmlParserStrings.feedPostUserName,
      FeedHtmlParserStrings
          .attrBxPostAuthorId, // Обновлено: был bxPostAuthorIdAttr
      FeedHtmlParserStrings.unknownAuthor,
    );
    final ratingList = BitrixHtmlParserUtils.parseRatingList(
      postElement,
      currentUserData,
      FeedHtmlParserStrings.feedPostEmojiTopPanelOuter,
      postElement.attributes[FeedHtmlParserStrings
          .attrDataLivefeedId], // Обновлено: был dataLivefeedIdAttr
    );
    final commentCount = _extractCommentCount(postElement);

    return switch (blogPostType) {
      ExtendedBlogPostType.important ||
      ExtendedBlogPostType.importantPinned =>
        ImportantBlogPost(
          data: postData,
          ratingList: ratingList,
          userShortInfo: authorInfo,
          attachFiles: attachFiles,
          comments: const [],
          commentCount: commentCount,
          isRead: _isImportantPostRead(postElement),
          readCount: _getImportantPostReadCount(postElement),
        ),
      _ => BlogPost(
          data: postData,
          ratingList: ratingList,
          userShortInfo: authorInfo,
          attachFiles: attachFiles,
          comments: const [],
          commentCount: commentCount,
        ),
    };
  }

  static (BlogPostData, List<FileData>) _parsePostData(Element postElement) {
    final contentView = postElement.attributes[FeedHtmlParserStrings
            .attrBxContentViewKeySigned] ?? // Обновлено: был bxContentViewKeySignedAttr
        FeedHtmlParserStrings.emptyString;
    final postIdMatch =
        RegularExpressions.blogPostIdRegExp.firstMatch(contentView);
    final postId = int.tryParse(postIdMatch?.group(1) ?? '') ?? 0;

    final keySigned = BitrixHtmlParserUtils.extractKeySigned(
      postElement,
      FeedHtmlParserStrings.blogPostPrefix,
      postId.toString(),
    );

    final authorBitrixId = int.tryParse(
          postElement
                      .querySelector(FeedHtmlParserStrings.feedPostUserName)
                      ?.attributes[
                  FeedHtmlParserStrings
                      .attrBxPostAuthorId] ?? // Обновлено: был bxPostAuthorIdAttr
              FeedHtmlParserStrings.zeroString,
        ) ??
        0;

    final title = postElement
            .querySelector(FeedHtmlParserStrings.feedPostPinnedTitle)
            ?.text
            .trim() ??
        FeedHtmlParserStrings.emptyString;

    final textElement =
        postElement.querySelector(FeedHtmlParserStrings.feedPostText);
    final parsedTextResult = extractImagesAndCleanHtmlText(
      textElement?.innerHtml ?? FeedHtmlParserStrings.emptyString,
    );

    final extractedUrls =
        (parsedTextResult[FeedHtmlParserStrings.imageUrlsKey] as List?)
                ?.cast<String>() ??
            <String>[];
    final cleanedText =
        parsedTextResult[FeedHtmlParserStrings.cleanedTextKey] as String?;

    final uniqueUrls = extractedUrls.toSet();

    BitrixHtmlParserUtils.extractImagesToSet(
      postElement,
      FeedHtmlParserStrings.diskUiFileThumbnailsWebGridImgItem,
      FeedHtmlParserStrings.imageSrcAttributesShort,
      uniqueUrls,
    );
    BitrixHtmlParserUtils.extractImagesToSet(
      postElement,
      FeedHtmlParserStrings.diskUiFileThumbnailsWebGridImg,
      FeedHtmlParserStrings.imageSrcAttributesFull,
      uniqueUrls,
    );
    BitrixHtmlParserUtils.extractImagesToSet(
      postElement,
      FeedHtmlParserStrings.feedComFilesPhotoImg,
      FeedHtmlParserStrings.imageSrcAttributesWithSrc,
      uniqueUrls,
    );

    final datePublish = _parseDateTime(
      postElement
              .querySelector(FeedHtmlParserStrings.feedPostTimeWrapFeedTime)
              ?.text
              .trim() ??
          FeedHtmlParserStrings.emptyString,
    );

    final numberOfComments = int.tryParse(
          postElement
                  .querySelector(
                    FeedHtmlParserStrings.feedInformCommentsPinnedAll,
                  )
                  ?.text
                  .trim() ??
              FeedHtmlParserStrings.zeroString,
        ) ??
        0;

    final numberOfViews = int.tryParse(
          postElement
                  .querySelector(FeedHtmlParserStrings.feedContentViewCnt)
                  ?.text
                  .trim() ??
              FeedHtmlParserStrings.zeroString,
        ) ??
        0;

    final livefeedId = postElement.attributes[FeedHtmlParserStrings
        .attrDataLivefeedId]; // Обновлено: был dataLivefeedIdAttr
    final pinnedId =
        int.tryParse(livefeedId ?? FeedHtmlParserStrings.emptyString);

    final destinations = _extractDestinations(postElement);
    final files = BitrixHtmlParserUtils.extractAttachedFiles(
      postElement,
      FeedHtmlParserStrings.attachedFilesSelectorPost,
      skipIfInCommentsBlock: true,
    );

    final blogPostData = BlogPostData(
      id: postId,
      blogId: null,
      authorBitrixId: authorBitrixId,
      title: title,
      detailText: cleanedText ?? '',
      imageUrls: uniqueUrls.toList(),
      datePublish: datePublish ?? DateTime.now(),
      numberOfComments: numberOfComments,
      numberOfViews: numberOfViews,
      fileIds: files.map((file) => file.id).toList(),
      pinnedId: pinnedId,
      keySigned: keySigned,
      destinations: destinations,
    );

    return (blogPostData, files);
  }

  static bool _isImportantPostRead(Element postElement) {
    final footer =
        postElement.querySelector(FeedHtmlParserStrings.feedImpPostFooter);
    if (footer == null) {
      return false;
    }
    return footer.querySelector(FeedHtmlParserStrings.haveReadTextBlock) !=
        null;
  }

  static int _getImportantPostReadCount(Element postElement) {
    final footer =
        postElement.querySelector(FeedHtmlParserStrings.feedImpPostFooter);
    if (footer == null) {
      return 0;
    }

    final countElement =
        footer.querySelector(FeedHtmlParserStrings.blogPostReadersCountPrefix);
    if (countElement == null) {
      return 0;
    }

    final match = RegularExpressions.digitsRegExp.firstMatch(countElement.text);
    return int.tryParse(match?.group(1) ?? FeedHtmlParserStrings.emptyString) ??
        0;
  }

  static List<PostDestination>? _extractDestinations(Element postElement) {
    final destinations = <PostDestination>[];
    final destinationElements = postElement
        .querySelectorAll(FeedHtmlParserStrings.feedAddPostDestinationNew);

    for (final dest in destinationElements) {
      final entityType = dest.attributes[FeedHtmlParserStrings
          .attrDataBxEntityType]; // Обновлено: был dataBxEntityTypeAttr
      final entityId = dest.attributes[FeedHtmlParserStrings
          .attrDataBxEntityId]; // Обновлено: был dataBxEntityIdAttr
      final name = dest.text.trim();

      if (entityType == null || entityId == null || name.isEmpty) {
        continue;
      }

      final parsedId = int.tryParse(entityId);
      if (parsedId != null) {
        destinations.add(
          PostDestination(type: entityType, id: parsedId, name: name),
        );
      }
    }
    return destinations.isEmpty ? null : destinations;
  }

  static ExtendedBlogPostType _getPostType(Element postElement) {
    final postBlock =
        postElement.querySelector(FeedHtmlParserStrings.feedPostBlock);
    if (postBlock == null) {
      return ExtendedBlogPostType.regular;
    }

    final classes = postBlock.className;
    final isPinned = postBlock.attributes[FeedHtmlParserStrings
                .attrDataLivefeedPostPinned] == // Обновлено: был dataLivefeedPostPinnedAttr
            FeedHtmlParserStrings.yesValue ||
        classes.contains(FeedHtmlParserStrings.feedPostBlockPinnedClass);
    final isImportant =
        classes.contains(FeedHtmlParserStrings.feedImpPostClass) ||
            classes.contains(FeedHtmlParserStrings.feedPostBlockImportantClass);

    if (isImportant && isPinned) {
      return ExtendedBlogPostType.importantPinned;
    }
    if (isImportant) {
      return ExtendedBlogPostType.important;
    }
    if (isPinned) {
      return ExtendedBlogPostType.pinned;
    }

    return ExtendedBlogPostType.regular;
  }

  static int _extractCommentCount(Element postElement) {
    final commentsBlock = postElement
        .querySelector(FeedHtmlParserStrings.feedInformCommentsPinned);
    if (commentsBlock == null) {
      return 0;
    }
    final countElement = commentsBlock
        .querySelector(FeedHtmlParserStrings.feedInformCommentsPinnedAll);
    if (countElement == null || countElement.text.isEmpty) {
      return 0;
    }
    return int.tryParse(countElement.text.trim()) ?? 0;
  }

  static DateTime? _parseDateTime(String dateStr) {
    if (dateStr.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (dateStr.contains(FeedHtmlParserStrings.todayWord)) {
      final timePart = _extractTime(dateStr);
      return timePart != null ? _combineDateAndTime(today, timePart) : today;
    }

    if (dateStr.contains(FeedHtmlParserStrings.yesterdayWord)) {
      final yesterday = today.subtract(const Duration(days: 1));
      final timePart = _extractTime(dateStr);
      return timePart != null
          ? _combineDateAndTime(yesterday, timePart)
          : yesterday;
    }

    if (_hasYear(dateStr)) {
      return DateTimeParser.parse(dateStr, DatePattern.dmmmmyyyyhhmm);
    }

    final parsed = DateTimeParser.parse(
      '$dateStr ${now.year}',
      DatePattern.dmmmmhhmmyyyy,
    );
    return parsed.isAfter(now)
        ? parsed.subtract(const Duration(days: 365))
        : parsed;
  }

  static bool _hasYear(String dateStr) =>
      RegularExpressions.fourDigitYearRegExp.hasMatch(dateStr);

  static String? _extractTime(String dateStr) {
    final timeMatch = RegularExpressions.timeRexExp.firstMatch(dateStr);
    return timeMatch?.group(1);
  }

  static DateTime _combineDateAndTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) {
      return date;
    }
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, hours, minutes);
  }
}

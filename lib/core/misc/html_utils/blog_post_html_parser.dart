// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:unn_mobile/core/constants/date_pattern.dart';
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
  static Map<BlogPostType, List<BlogPost>>? parse(
    String? htmlText,
    UserShortInfo currentUserData,
  ) {
    final document = parser.parse(htmlText);
    final postElements = document.querySelectorAll('.feed-item-wrap');
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
      '.feed-post-user-name',
      'bx-post-author-id',
      'Неизвестный автор',
    );
    final ratingList = BitrixHtmlParserUtils.parseRatingList(
      postElement,
      currentUserData,
      '.feed-post-emoji-top-panel-outer',
      postElement.attributes['data-livefeed-id'],
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
    final contentView =
        postElement.attributes['bx-content-view-key-signed'] ?? '';
    final postIdMatch = RegExp(r'BLOG_POST-(\d+)').firstMatch(contentView);
    final postId = postIdMatch != null ? int.parse(postIdMatch.group(1)!) : 0;

    final keySigned = BitrixHtmlParserUtils.extractKeySigned(
      postElement,
      'BLOG_POST_',
      postId.toString(),
    );

    final authorBitrixId = int.tryParse(
          postElement
                  .querySelector('.feed-post-user-name')
                  ?.attributes['bx-post-author-id'] ??
              '0',
        ) ??
        0;

    final title =
        postElement.querySelector('.feed-post-pinned-title')?.text.trim() ?? '';
    final textElement = postElement.querySelector('.feed-post-text');
    final textAndImages =
        extractImagesAndCleanHtmlText(textElement?.innerHtml ?? '');

    final imageUrls =
        (textAndImages['imageUrls'] ??= <String>[]) as List<String>;
    final uniqueUrls = imageUrls.toSet();

    BitrixHtmlParserUtils.extractImagesToSet(
      postElement,
      '.disk-ui-file-thumbnails-web-grid-img-item',
      ['data-src', 'src'],
      uniqueUrls,
    );
    BitrixHtmlParserUtils.extractImagesToSet(
      postElement,
      '.disk-ui-file-thumbnails-web-grid-img',
      ['data-src', 'data-thumb-src', 'data-bx-src'],
      uniqueUrls,
    );
    BitrixHtmlParserUtils.extractImagesToSet(
      postElement,
      '.feed-com-files-photo img',
      ['data-src', 'data-thumb-src', 'src'],
      uniqueUrls,
    );

    imageUrls
      ..clear()
      ..addAll(uniqueUrls);

    final datePublish = _parseDateTime(
      postElement
              .querySelector('.feed-post-time-wrap .feed-time')
              ?.text
              .trim() ??
          '',
    );

    final numberOfComments = int.tryParse(
          postElement
                  .querySelector('.feed-inform-comments-pinned-all')
                  ?.text
                  .trim() ??
              '0',
        ) ??
        0;

    final numberOfViews = int.tryParse(
          postElement.querySelector('.feed-content-view-cnt')?.text.trim() ??
              '0',
        ) ??
        0;

    final livefeedId = postElement.attributes['data-livefeed-id'];
    final pinnedId = livefeedId != null ? int.tryParse(livefeedId) : null;

    final destinations = _extractDestinations(postElement);
    final files = BitrixHtmlParserUtils.extractAttachedFiles(
      postElement,
      '.feed-post-cont-wrap .feed-com-files .feed-com-file-wrap, .feed-post-cont-wrap #disk-attach-block .feed-com-file-wrap',
      skipIfInCommentsBlock: true,
    );

    final blogPostData = BlogPostData(
      id: postId,
      blogId: null,
      authorBitrixId: authorBitrixId,
      title: title,
      detailText: textAndImages['cleanedText'],
      imageUrls: imageUrls,
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
    final footer = postElement.querySelector('.feed-imp-post-footer');
    if (footer == null) {
      return false;
    }
    return footer.querySelector('.have-read-text-block') != null;
  }

  static int _getImportantPostReadCount(Element postElement) {
    final footer = postElement.querySelector('.feed-imp-post-footer');
    if (footer == null) {
      return 0;
    }

    final countElement =
        footer.querySelector('[id^="blog-post-readers-count-"]');
    if (countElement == null) {
      return 0;
    }

    final match = RegExp(r'(\d+)').firstMatch(countElement.text);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  static List<PostDestination>? _extractDestinations(Element postElement) {
    final destinations = <PostDestination>[];
    final destinationElements =
        postElement.querySelectorAll('.feed-add-post-destination-new');

    for (final dest in destinationElements) {
      final entityType = dest.attributes['data-bx-entity-type'];
      final entityId = dest.attributes['data-bx-entity-id'];
      final name = dest.text.trim();

      if (entityType != null && entityId != null && name.isNotEmpty) {
        final parsedId = int.tryParse(entityId);
        if (parsedId != null) {
          destinations
              .add(PostDestination(type: entityType, id: parsedId, name: name));
        }
      }
    }
    return destinations.isEmpty ? null : destinations;
  }

  static ExtendedBlogPostType _getPostType(Element postElement) {
    final postBlock = postElement.querySelector('.feed-post-block');
    if (postBlock == null) {
      return ExtendedBlogPostType.regular;
    }

    final classes = postBlock.className;
    final isPinned = postBlock.attributes['data-livefeed-post-pinned'] == 'Y' ||
        classes.contains('feed-post-block-pinned');
    final isImportant = classes.contains('feed-imp-post') ||
        classes.contains('feed-post-block-important');

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
    final commentsBlock =
        postElement.querySelector('.feed-inform-comments-pinned');
    if (commentsBlock != null) {
      final countElement =
          commentsBlock.querySelector('.feed-inform-comments-pinned-all');
      if (countElement != null && countElement.text.isNotEmpty) {
        return int.tryParse(countElement.text.trim()) ?? 0;
      }
    }
    return 0;
  }

  static DateTime? _parseDateTime(String dateStr) {
    if (dateStr.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (dateStr.contains('сегодня')) {
      final timePart = _extractTime(dateStr);
      return timePart != null ? _combineDateAndTime(today, timePart) : today;
    }

    if (dateStr.contains('вчера')) {
      final yesterday = today.subtract(const Duration(days: 1));
      final timePart = _extractTime(dateStr);
      return timePart != null
          ? _combineDateAndTime(yesterday, timePart)
          : yesterday;
    }

    if (_hasYear(dateStr)) {
      return DateTimeParser.parse(dateStr, DatePattern.dmmmmyyyyhhmm);
    }

    final parsed =
        DateTimeParser.parse('$dateStr ${now.year}', DatePattern.dmmmmhhmmyyyy);
    return parsed.isAfter(now)
        ? parsed.subtract(const Duration(days: 365))
        : parsed;
  }

  static bool _hasYear(String dateStr) =>
      RegExp(r'\b\d{4}\b').hasMatch(dateStr);

  static String? _extractTime(String dateStr) {
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(dateStr);
    return timeMatch?.group(1);
  }

  static DateTime _combineDateAndTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }
    return date;
  }
}

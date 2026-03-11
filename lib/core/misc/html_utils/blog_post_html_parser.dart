// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/misc/file_helpers/size_converter.dart';
import 'package:unn_mobile/core/misc/html_utils/html_image_utils.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/models/feed/blog_post_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/models/feed/post_destination.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class BlogPostHtmlParser {
  static Map<BlogPostType, List<BlogPost>>? parse(
    String? htmlText,
    UserShortInfo currentUserData,
  ) {
    final document = parser.parse(
      htmlText,
    );
    final postElements = document.querySelectorAll('.feed-item-wrap');

    final blogPosts = <BlogPostType, List<BlogPost>>{};

    for (final post in postElements) {
      final postType = _getPostType(post);
      final blogPost = _parsePost(post, currentUserData);

      switch (postType) {
        case ExtendedBlogPostType.regular:
          blogPosts.putIfAbsent(BlogPostType.regular, () => []).add(blogPost);
        case ExtendedBlogPostType.pinned:
          blogPosts.putIfAbsent(BlogPostType.pinned, () => []).add(blogPost);
        case ExtendedBlogPostType.important:
          blogPosts.putIfAbsent(BlogPostType.regular, () => []).add(blogPost);
          blogPosts.putIfAbsent(BlogPostType.important, () => []).add(blogPost);
        case ExtendedBlogPostType.importantPinned:
          blogPosts.putIfAbsent(BlogPostType.pinned, () => []).add(blogPost);
          blogPosts.putIfAbsent(BlogPostType.important, () => []).add(blogPost);
      }
    }
    return blogPosts;
  }

  static BlogPost _parsePost(
    Element postElement,
    UserShortInfo currentUserData,
  ) {
    final (postData, attachFiles) = _parsePostData(postElement);
    final authorInfo = _parseAuthorInfo(postElement);
    final ratingList = _parseRatingList(postElement, currentUserData);

    final commentCount = _extractCommentCount(postElement);

    return BlogPost(
      data: postData,
      ratingList: ratingList,
      userShortInfo: authorInfo,
      attachFiles: attachFiles,
      comments: [],
      commentCount: commentCount,
    );
  }

  static (BlogPostData, List<FileData>) _parsePostData(Element postElement) {
    final contentView =
        postElement.attributes['bx-content-view-key-signed'] ?? '';

    final postIdMatch = RegExp(r'BLOG_POST-(\d+)').firstMatch(contentView);
    final postId = postIdMatch != null ? int.parse(postIdMatch.group(1)!) : 0;

    final keySigned =
        _extractKeySignedFromScript(postElement, postId.toString());

    final authorElement = postElement.querySelector('.feed-post-user-name');
    final authorBitrixId = int.tryParse(
          authorElement?.attributes['bx-post-author-id'] ?? '0',
        ) ??
        0;

    final titleElement = postElement.querySelector('.feed-post-pinned-title');
    final title = titleElement?.text.trim() ?? '';

    final textElement = postElement.querySelector('.feed-post-text');

    final textAndImages = extractImagesAndCleanHtmlText(
      textElement?.innerHtml ?? '',
    );

    final imageUrls =
        (textAndImages['imageUrls'] ??= <String>[]) as List<String>;
    final uniqueUrls = imageUrls.toSet();

    _extractImagesToSet(
      postElement,
      '.disk-ui-file-thumbnails-web-grid-img-item',
      ['data-src', 'src'],
      uniqueUrls,
    );
    _extractImagesToSet(
      postElement,
      '.disk-ui-file-thumbnails-web-grid-img',
      ['data-src', 'data-thumb-src', 'data-bx-src'],
      uniqueUrls,
    );
    _extractImagesToSet(
      postElement,
      '.feed-com-files-photo img',
      ['data-src', 'data-thumb-src', 'src'],
      uniqueUrls,
    );

    imageUrls
      ..clear()
      ..addAll(uniqueUrls);

    final dateElement = postElement.querySelector('.feed-time');
    final datePublish = _parseDateTime(dateElement?.text.trim() ?? '');

    final commentsCountElement =
        postElement.querySelector('.feed-inform-comments-pinned-all');
    final numberOfComments =
        int.tryParse(commentsCountElement?.text.trim() ?? '0') ?? 0;

    final viewsElement = postElement.querySelector('.feed-content-view-cnt');
    final numberOfViews = int.tryParse(viewsElement?.text.trim() ?? '0') ?? 0;

    final livefeedId = postElement.attributes['data-livefeed-id'];
    final pinnedId = livefeedId != null ? int.tryParse(livefeedId) : null;

    final destinations = _extractDestinations(postElement);

    final files = _extractPostFiles(postElement);

    final blogPostData = BlogPostData(
      id: postId,
      blogId: null,
      authorBitrixId: authorBitrixId,
      title: title,
      detailText: textAndImages['cleanedText'],
      imageUrls: imageUrls,
      datePublish: datePublish,
      numberOfComments: numberOfComments,
      numberOfViews: numberOfViews,
      fileIds: files.map((file) => file.id).toList(),
      pinnedId: pinnedId,
      keySigned: keySigned,
      destinations: destinations,
    );

    return (blogPostData, files);
  }

  static UserShortInfo _parseAuthorInfo(Element postElement) {
    final authorElement = postElement.querySelector('.feed-post-user-name');
    final fullname = authorElement?.text.trim();
    final bitrixId = int.tryParse(
      authorElement?.attributes['bx-post-author-id'] ?? '',
    );

    final avatarElement = postElement.querySelector('.feed-user-avatar i');
    final photoSrc = _extractPhotoSrc(avatarElement);

    return UserShortInfo(
      bitrixId: bitrixId,
      fullname: fullname,
      photoSrc: photoSrc != null
          ? '${ProtocolType.https.name}://${Host.unn}$photoSrc'
          : null,
    );
  }

  static RatingList _parseRatingList(
    Element postElement,
    UserShortInfo currentUserData,
  ) {
    final emojiContainer = postElement.querySelector(
      '.feed-post-emoji-top-panel-outer',
    );

    if (emojiContainer == null) {
      return RatingList();
    }

    final emojiPanel = emojiContainer.querySelector(
      '.feed-post-emoji-container, .feed-post-emoji-top-panel-box',
    );

    if (emojiPanel == null) {
      return RatingList();
    }

    final iconContainer = emojiPanel.querySelector(
      '.feed-post-emoji-icon-container',
    );

    Map<ReactionType, int> reactions = {};
    ReactionType? myReaction;

    if (iconContainer != null) {
      final reactionsDataAttr = iconContainer.attributes['data-reactions-data'];

      if (reactionsDataAttr != null && reactionsDataAttr.isNotEmpty) {
        final decodedData = reactionsDataAttr
            .replaceAll('&quot;', '"')
            .replaceAll('&amp;', '&');

        final jsonData = jsonDecode(decodedData);

        if (jsonData is Map<String, dynamic>) {
          reactions = jsonData.map((key, value) {
            final reactionType = ReactionType.fromString(key);
            final count =
                value is int ? value : int.tryParse(value.toString()) ?? 0;

            if (reactionType != null && count > 0) {
              return MapEntry(reactionType, count);
            }
            return const MapEntry(ReactionType.like, 0);
          })
            ..removeWhere((key, value) => value == 0);
        }
      }
    }

    final myReactionElement = emojiPanel.querySelector(
      '[data-myreaction], #bx-ilike-user-reaction-${postElement.attributes['data-livefeed-id']}',
    );

    if (myReactionElement != null) {
      String? reactionValue = myReactionElement.attributes['data-myreaction'];

      if (reactionValue == null || reactionValue.isEmpty) {
        final userReactionSpan = emojiPanel.querySelector(
          'span[data-value]',
        );
        if (userReactionSpan != null) {
          reactionValue = userReactionSpan.attributes['data-value'];
        }
      }

      if (reactionValue != null && reactionValue.isNotEmpty) {
        myReaction = ReactionType.fromString(reactionValue);
      }
    }

    return RatingList.reactionCounts(
      reactionCounts: reactions,
      userReaction: myReaction != null
          ? (
              UserShortInfo(
                bitrixId: currentUserData.bitrixId,
                fullname: currentUserData.fullname,
                photoSrc: currentUserData.photoSrc,
              ),
              myReaction,
            )
          : null,
    );
  }

  static List<FileData> _extractPostFiles(Element postElements) {
    final fileDataList = <FileData>[];
    final postFileBlocks = postElements.querySelectorAll(
        '.feed-post-cont-wrap .feed-com-files .feed-com-file-wrap, '
        '.feed-post-cont-wrap #disk-attach-block .feed-com-file-wrap');

    for (final fileWrap in postFileBlocks) {
      if ((fileWrap.parent?.parent?.classes.contains('feed-comments-block') ??
              false) ||
          (fileWrap.parent?.parent?.parent?.classes
                  .contains('feed-comments-block') ??
              false)) {
        continue;
      }

      final linkElement = fileWrap.querySelector('a[data-attached-object-id]');
      if (linkElement == null) {
        continue;
      }

      final attachedId = linkElement.attributes['data-attached-object-id'];
      if (attachedId == null || attachedId.isEmpty) {
        continue;
      }
      final fileName = linkElement.attributes['title']?.trim();
      if (fileName == null || fileName.isEmpty) {
        continue;
      }

      final sizeElement = fileWrap.querySelector('.feed-com-file-size');
      final sizeText = sizeElement?.text.trim() ?? '0 Б';
      final sizeInBytes = SizeConverter.parseFileSize(sizeText);

      final downloadUrl = linkElement.attributes['href'] ?? '';

      fileDataList.add(
        FileData(
          id: int.tryParse(attachedId) ?? 0,
          name: fileName,
          sizeInBytes: sizeInBytes,
          downloadUrl: downloadUrl,
        ),
      );
    }

    return fileDataList;
  }

  static String? _extractPhotoSrc(Element? avatarElement) {
    if (avatarElement == null) {
      return null;
    }

    final style = avatarElement.attributes['style'];
    if (style != null) {
      final urlMatch =
          RegExp(r'''url\(['"]?([^'")]+)['"]?\)''').firstMatch(style);
      if (urlMatch != null) {
        return urlMatch.group(1);
      }
    }

    final imgElement = avatarElement.querySelector('img');
    return imgElement?.attributes['src'];
  }

  static DateTime _parseDateTime(String dateTimeString) {
    final now = DateTime.now();

    if (dateTimeString.contains('сегодня')) {
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(dateTimeString);
      if (timeMatch != null) {
        final hour = int.parse(timeMatch.group(1)!);
        final minute = int.parse(timeMatch.group(2)!);
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } else if (dateTimeString.contains('вчера')) {
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(dateTimeString);
      if (timeMatch != null) {
        final hour = int.parse(timeMatch.group(1)!);
        final minute = int.parse(timeMatch.group(2)!);
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          hour,
          minute,
        );
      }
    } else {
      // Пробуем распарсить стандартный формат
      final dateMatch =
          RegExp(r'(\d{1,2})\.(\d{1,2})\.(\d{4})\s+(\d{1,2}):(\d{2})')
              .firstMatch(dateTimeString);
      if (dateMatch != null) {
        final day = int.parse(dateMatch.group(1)!);
        final month = int.parse(dateMatch.group(2)!);
        final year = int.parse(dateMatch.group(3)!);
        final hour = int.parse(dateMatch.group(4)!);
        final minute = int.parse(dateMatch.group(5)!);
        return DateTime(year, month, day, hour, minute);
      }
    }

    return now;
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
          destinations.add(
            PostDestination(
              type: entityType,
              id: parsedId,
              name: name,
            ),
          );
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

    bool hasReadMessage = false;
    if (isImportant) {
      final importantFooter =
          postElement.querySelector('.feed-imp-post-footer');
      hasReadMessage =
          importantFooter?.text.contains('С сообщением ознакомлен') ?? false;
    }

    if (hasReadMessage) {
      if (isPinned) {
        return ExtendedBlogPostType.pinned;
      }
      return ExtendedBlogPostType.regular;
    }

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

  static String _extractKeySignedFromScript(
    Element postElement,
    String postId,
  ) {
    final scripts = postElement.getElementsByTagName('script');

    for (final script in scripts) {
      final content = script.text;

      if (content.contains("likeId: 'BLOG_POST_$postId-")) {
        final keySignedMatch = RegExp(
          r"keySigned:\s*'([^']+)'",
          multiLine: true,
        ).firstMatch(content);

        if (keySignedMatch != null) {
          return keySignedMatch.group(1) ?? '';
        }
      }
    }

    return '';
  }

  static void _extractImagesToSet(
    Element root,
    String selector,
    List<String> attrs,
    Set<String> result,
  ) {
    for (final element in root.querySelectorAll(selector)) {
      final src = attrs.map((attr) => element.attributes[attr]).firstWhere(
            (val) => val != null && val.isNotEmpty,
            orElse: () => null,
          );

      if (src != null) {
        result.add(src.replaceAll('action=download', 'action=show'));
      }
    }
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
}

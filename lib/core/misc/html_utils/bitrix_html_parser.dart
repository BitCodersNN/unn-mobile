import 'dart:convert';

import 'package:html/dom.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/misc/file_helpers/size_converter.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class BitrixHtmlParserUtils {
  static Map<ReactionType, int> parseReactionsData(Element? emojiContainer) {
    if (emojiContainer == null) {
      return {};
    }

    final iconContainer =
        emojiContainer.querySelector('.feed-post-emoji-icon-container');
    if (iconContainer == null) {
      return {};
    }

    final reactionsDataAttr = iconContainer.attributes['data-reactions-data'];
    if (reactionsDataAttr == null || reactionsDataAttr.isEmpty) {
      return {};
    }

    final decodedData =
        reactionsDataAttr.replaceAll('&quot;', '"').replaceAll('&amp;', '&');

    try {
      final jsonData = jsonDecode(decodedData);
      if (jsonData is Map<String, dynamic>) {
        final validReactions = <ReactionType, int>{};
        for (final entry in jsonData.entries) {
          final reactionType = ReactionType.fromString(entry.key);
          final count = entry.value is int
              ? entry.value as int
              : int.tryParse(entry.value.toString()) ?? 0;

          if (reactionType != null && count > 0) {
            validReactions[reactionType] = count;
          }
        }
        return validReactions;
      }
    } catch (e) {
      // Безопасное игнорирование ошибок парсинга JSON
    }
    return {};
  }

  static ReactionType? parseMyReaction(
    Element? emojiContainer,
    String? livefeedId,
  ) {
    if (emojiContainer == null) {
      return null;
    }

    final myReactionElement =
        emojiContainer.querySelector('[data-myreaction]') ??
            (livefeedId != null
                ? emojiContainer
                    .querySelector('#bx-ilike-user-reaction-$livefeedId')
                : null) ??
            emojiContainer.querySelector('[data-value]');

    if (myReactionElement != null) {
      final reactionValue = myReactionElement.attributes['data-myreaction'] ??
          myReactionElement.attributes['data-value'];

      if (reactionValue != null && reactionValue.isNotEmpty) {
        return ReactionType.fromString(reactionValue);
      }
    }
    return null;
  }

  static RatingList parseRatingList(
    Element rootElement,
    UserShortInfo currentUserData,
    String containerSelector,
    String? livefeedId,
  ) {
    final emojiContainer = rootElement.querySelector(containerSelector);
    if (emojiContainer == null) {
      return RatingList();
    }

    final targetContainer = emojiContainer.querySelector(
          '.feed-post-emoji-container, .feed-post-emoji-top-panel-box',
        ) ??
        emojiContainer;

    final reactions = parseReactionsData(targetContainer);
    final myReaction = parseMyReaction(targetContainer, livefeedId);

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

  static List<FileData> extractAttachedFiles(
    Element root,
    String selector, {
    bool skipIfInCommentsBlock = true,
  }) {
    final fileDataList = <FileData>[];
    final fileBlocks = root.querySelectorAll(selector);

    for (final fileWrap in fileBlocks) {
      if (skipIfInCommentsBlock) {
        final parent2 = fileWrap.parent?.parent;
        final parent3 = parent2?.parent;
        if ((parent2?.classes.contains('feed-comments-block') ?? false) ||
            (parent3?.classes.contains('feed-comments-block') ?? false)) {
          continue;
        }
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

  static String extractKeySigned(
    Element root,
    String entityType,
    String entityId,
  ) {
    final scripts = root.getElementsByTagName('script');
    final searchPattern = "likeId: '$entityType$entityId-";

    for (final script in scripts) {
      final content = script.text;
      if (content.contains(searchPattern)) {
        final match = RegExp(r"keySigned:\s*'([^']+)'").firstMatch(content);
        if (match != null) {
          return match.group(1) ?? '';
        }
      }
    }
    return '';
  }

  static void extractImagesToSet(
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

  static UserShortInfo parseAuthorInfo(
    Element root,
    String linkSelector,
    String idAttribute,
    String fallbackName,
  ) {
    final authorLink = root.querySelector(linkSelector);
    final bitrixId = int.tryParse(authorLink?.attributes[idAttribute] ?? '');
    final fullname = authorLink?.text.trim() ?? fallbackName;

    String? photoSrc;
    final avatarContainer =
        root.querySelector('.feed-com-avatar, .feed-user-avatar');

    if (avatarContainer != null) {
      final imgElement = avatarContainer.querySelector('img');
      final rawSrc =
          imgElement?.attributes['src'] ?? imgElement?.attributes['data-src'];

      if (rawSrc != null && rawSrc.isNotEmpty && rawSrc != '""') {
        photoSrc = '${ProtocolType.https.name}://${Host.unn}$rawSrc';
      } else {
        final iconElement = avatarContainer.querySelector('i');
        final style = iconElement?.attributes['style'];
        if (style != null) {
          final urlMatch =
              RegExp(r'''url\(['"]?([^'")]+)['"]?\)''').firstMatch(style);
          if (urlMatch != null) {
            photoSrc =
                '${ProtocolType.https.name}://${Host.unn}${urlMatch.group(1)}';
          }
        }
      }
    }

    return UserShortInfo(
      bitrixId: bitrixId,
      fullname: fullname,
      photoSrc: photoSrc,
    );
  }
}

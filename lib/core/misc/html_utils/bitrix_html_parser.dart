// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:convert';

import 'package:html/dom.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/string_keys/feed_html_parser_strings.dart';
import 'package:unn_mobile/core/misc/file_helpers/size_converter.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';
import 'package:unn_mobile/core/models/feed/rating_list.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';

class BitrixHtmlParserUtils {
  static Map<ReactionType, int> parseReactionsData(Element? emojiContainer) {
    if (emojiContainer == null) {
      return {};
    }

    final iconContainer = emojiContainer.querySelector(
      FeedHtmlParserStrings.feedPostEmojiIconContainer,
    );
    if (iconContainer == null) {
      return {};
    }

    final reactionsDataAttr =
        iconContainer.attributes[FeedHtmlParserStrings.attrDataReactionsData];

    if (reactionsDataAttr == null || reactionsDataAttr.isEmpty) {
      return {};
    }

    final decodedData = reactionsDataAttr
        .replaceAll(
          FeedHtmlParserStrings.htmlEntityQuote,
          FeedHtmlParserStrings.charQuote,
        )
        .replaceAll(
          FeedHtmlParserStrings.htmlEntityAmp,
          FeedHtmlParserStrings.charAmpersand,
        );

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
    } catch (_) {
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

    Element? myReactionElement = emojiContainer.querySelector(
      FeedHtmlParserStrings.selDataMyreaction,
    );

    if (myReactionElement == null && livefeedId != null) {
      myReactionElement = emojiContainer.querySelector(
        '${FeedHtmlParserStrings.bxIlikeUserReactionPrefixSelector}$livefeedId',
      );
    }

    myReactionElement ??= emojiContainer.querySelector(
      FeedHtmlParserStrings.selDataValue,
    );

    if (myReactionElement == null) {
      return null;
    }

    final reactionValue = myReactionElement
            .attributes[FeedHtmlParserStrings.attrDataMyreaction] ??
        myReactionElement.attributes[FeedHtmlParserStrings.attrDataValue];

    if (reactionValue != null && reactionValue.isNotEmpty) {
      return ReactionType.fromString(reactionValue);
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
          FeedHtmlParserStrings.feedPostEmojiContainer,
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
        final inComments = (parent2?.classes.contains(
                  FeedHtmlParserStrings.feedCommentsBlock,
                ) ??
                false) ||
            (parent3?.classes.contains(
                  FeedHtmlParserStrings.feedCommentsBlock,
                ) ??
                false);
        if (inComments) {
          continue;
        }
      }

      final linkElement = fileWrap.querySelector(
        FeedHtmlParserStrings.selAttachedFileLink,
      );
      if (linkElement == null) {
        continue;
      }

      final attachedId = linkElement
          .attributes[FeedHtmlParserStrings.attrDataAttachedObjectId];
      if (attachedId == null || attachedId.isEmpty) {
        continue;
      }

      final fileName =
          linkElement.attributes[FeedHtmlParserStrings.attrTitle]?.trim();
      if (fileName == null || fileName.isEmpty) {
        continue;
      }

      final sizeElement = fileWrap.querySelector(
        FeedHtmlParserStrings.feedComFileSize,
      );
      final sizeText =
          sizeElement?.text.trim() ?? FeedHtmlParserStrings.defaultSize;
      final sizeInBytes = SizeConverter.parseFileSize(sizeText);
      final downloadUrl =
          linkElement.attributes[FeedHtmlParserStrings.attrHref] ?? '';

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
    final scripts = root.getElementsByTagName(FeedHtmlParserStrings.scriptTag);
    final searchPattern =
        '${FeedHtmlParserStrings.likeIdPrefix}$entityType$entityId${FeedHtmlParserStrings.likeIdSuffix}';

    for (final script in scripts) {
      final content = script.text;
      if (content.contains(searchPattern)) {
        final match = RegularExpressions.keySignedRegExp.firstMatch(content);
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
        result.add(
          src.replaceAll(
            FeedHtmlParserStrings.actionDownload,
            FeedHtmlParserStrings.actionShow,
          ),
        );
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
    final avatarContainer = root.querySelector(
      FeedHtmlParserStrings.avatarContainer,
    );

    if (avatarContainer != null) {
      final imgElement = avatarContainer.querySelector(
        FeedHtmlParserStrings.imgTag,
      );
      final rawSrc = imgElement?.attributes[FeedHtmlParserStrings.attrSrc] ??
          imgElement?.attributes[FeedHtmlParserStrings.attrDataSrc];

      if (rawSrc != null &&
          rawSrc.isNotEmpty &&
          rawSrc != FeedHtmlParserStrings.emptyQuotes) {
        photoSrc = '${ProtocolType.https.name}://${Host.unn}$rawSrc';
      } else {
        final iconElement = avatarContainer.querySelector(
          FeedHtmlParserStrings.iconTag,
        );
        final style = iconElement?.attributes[FeedHtmlParserStrings.attrStyle];
        if (style != null) {
          final urlMatch = RegularExpressions.urlRegExp.firstMatch(style);
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

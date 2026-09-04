import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
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
    final commentElements = document.querySelectorAll('.feed-com-block-cover');

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
      '.feed-com-files .feed-com-file-wrap, #disk-attach-block .feed-com-file-wrap',
      skipIfInCommentsBlock: false,
    );

    return BlogPostComment(
      data: _parseCommentData(commentElement, attachFiles),
      ratingList: BitrixHtmlParserUtils.parseRatingList(
        commentElement,
        currentUserData,
        '.feed-post-emoji-container',
        null,
      ),
      userShortInfo: BitrixHtmlParserUtils.parseAuthorInfo(
        commentElement,
        'a[bx-tooltip-user-id]',
        'bx-tooltip-user-id',
        'Неизвестный автор',
      ),
      attachFiles: attachFiles,
    );
  }

  static BlogPostCommentData _parseCommentData(
    Element commentElement,
    List<FileData> attachFiles,
  ) {
    final commentId = _extractCommentId(commentElement) ?? -1;

    return BlogPostCommentData(
      authorBitrixId: BitrixHtmlParserUtils.parseAuthorInfo(
            commentElement,
            'a[bx-tooltip-user-id]',
            'bx-tooltip-user-id',
            'Неизвестный автор',
          ).bitrixId ??
          -1,
      id: commentId,
      dateTime: commentElement.querySelector('.feed-com-time')?.text.trim() ??
          'unknown',
      message: commentElement
              .querySelector('.feed-com-text-inner-inner')
              ?.innerHtml
              .trim() ??
          'unknown',
      keySigned: BitrixHtmlParserUtils.extractKeySigned(
        commentElement,
        'BLOG_COMMENT_',
        commentId.toString(),
      ),
      imageUrls: _extractImageUrls(commentElement),
      attachedFiles: attachFiles.map((f) => f.id).toList(),
    );
  }

  static int? _extractCommentId(Element element) {
    final entityId = element.attributes['bx-mpl-entity-id'];
    if (entityId != null) {
      return int.tryParse(entityId);
    }

    final recordId = element.attributes['id'];
    if (recordId != null) {
      final match = RegExp(r'record-BLOG_\d+-(\d+)-cover').firstMatch(recordId);
      return match != null ? int.tryParse(match.group(1)!) : null;
    }
    return null;
  }

  static List<String> _extractImageUrls(Element element) {
    final urls = <String>{};
    BitrixHtmlParserUtils.extractImagesToSet(
      element,
      '.feed-com-files img, .disk-ui-file-thumbnails-web-grid img, .feed-com-files-photo img',
      ['data-src', 'data-thumb-src', 'data-bx-src', 'src'],
      urls,
    );
    return urls.toList();
  }
}

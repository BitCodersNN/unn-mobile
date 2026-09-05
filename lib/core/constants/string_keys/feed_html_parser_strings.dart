// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

class FeedHtmlParserStrings {
  // ======== БАЗОВЫЕ АТРИБУТЫ (Источник истины) ========
  static const String attrSrc = 'src';
  static const String attrDataSrc = 'data-src';
  static const String attrDataThumbSrc = 'data-thumb-src';
  static const String attrDataBxSrc = 'data-bx-src';
  static const String attrDataMyreaction = 'data-myreaction';
  static const String attrDataValue = 'data-value';
  static const String attrDataAttachedObjectId = 'data-attached-object-id';
  static const String attrBxTooltipUserId = 'bx-tooltip-user-id';

  static const String attrDataLivefeedId = 'data-livefeed-id';
  static const String attrDataLivefeedPostPinned = 'data-livefeed-post-pinned';
  static const String attrBxContentViewKeySigned = 'bx-content-view-key-signed';
  static const String attrBxPostAuthorId = 'bx-post-author-id';
  static const String attrDataBxEntityType = 'data-bx-entity-type';
  static const String attrDataBxEntityId = 'data-bx-entity-id';
  static const String attrBxMplEntityId = 'bx-mpl-entity-id';
  static const String attrDataReactionsData = 'data-reactions-data';

  static const String attrId = 'id';
  static const String attrTitle = 'title';
  static const String attrHref = 'href';
  static const String attrStyle = 'style';

  // ======== СЕЛЕКТОРЫ АТРИБУТОВ (Автоматическая сборка) ========
  static const String selDataMyreaction = '[$attrDataMyreaction]';
  static const String selDataValue = '[$attrDataValue]';
  static const String selAttachedFileLink = 'a[$attrDataAttachedObjectId]';
  static const String selAuthorLink = 'a[$attrBxTooltipUserId]';

  // ======== БАЗОВЫЕ CSS СЕЛЕКТОРЫ (Для повторного использования) ========
  static const String selFeedComFiles = '.feed-com-files';
  static const String selFeedComFileWrap = '.feed-com-file-wrap';
  static const String selDiskAttachBlock = '#disk-attach-block';
  static const String selPostContWrap = '.feed-post-cont-wrap';

  static const String selFeedComFilesImg = '.feed-com-files img';
  static const String selDiskUiGridImg =
      '.disk-ui-file-thumbnails-web-grid img';
  static const String selFeedComFilesPhotoImg = '.feed-com-files-photo img';

  static const String selEmojiContainerSimple = '.feed-post-emoji-container';
  static const String selEmojiTopPanelBox = '.feed-post-emoji-top-panel-box';

  // ======== КОМПОЗИТНЫЕ СЕЛЕКТОРЫ (Сборка из базовых) ========
  static const String attachedFilesSelectorGeneral =
      '$selFeedComFiles $selFeedComFileWrap, $selDiskAttachBlock $selFeedComFileWrap';

  static const String attachedFilesSelectorPost =
      '$selPostContWrap $selFeedComFiles $selFeedComFileWrap, '
      '$selPostContWrap $selDiskAttachBlock $selFeedComFileWrap';

  static const String imageSelector =
      '$selFeedComFilesImg, $selDiskUiGridImg, $selFeedComFilesPhotoImg';

  static const String feedPostEmojiContainer =
      '$selEmojiContainerSimple, $selEmojiTopPanelBox';

  // ======== СПИСКИ АТРИБУТОВ (Ссылки на базовые константы) ========
  static const List<String> imageSrcAttributesShort = <String>[
    attrDataSrc,
    attrSrc,
  ];

  static const List<String> imageSrcAttributesWithSrc = <String>[
    ...imageSrcAttributesShort,
    attrDataThumbSrc,
  ];

  static const List<String> imageSrcAttributesFull = <String>[
    ...imageSrcAttributesWithSrc,
    attrDataBxSrc,
  ];

  // ======== ОСТАЛЬНЫЕ CSS СЕЛЕКТОРЫ (Посты и Лента) ========
  static const String feedItemWrap = '.feed-item-wrap';
  static const String feedPostUserName = '.feed-post-user-name';
  static const String feedPostEmojiTopPanelOuter =
      '.feed-post-emoji-top-panel-outer';
  static const String feedPostPinnedTitle = '.feed-post-pinned-title';
  static const String feedPostText = '.feed-post-text';
  static const String feedPostTimeWrapFeedTime =
      '.feed-post-time-wrap .feed-time';
  static const String feedContentViewCnt = '.feed-content-view-cnt';
  static const String feedAddPostDestinationNew =
      '.feed-add-post-destination-new';
  static const String feedPostBlock = '.feed-post-block';
  static const String blogPostReadersCountPrefix =
      '[id^="blog-post-readers-count-"]';
  static const String haveReadTextBlock = '.have-read-text-block';
  static const String feedImpPostFooter = '.feed-imp-post-footer';
  static const String feedPostEmojiIconContainer =
      '.feed-post-emoji-icon-container';
  static const String bxIlikeUserReactionPrefixSelector =
      '#bx-ilike-user-reaction-';
  static const String diskUiFileThumbnailsWebGridImgItem =
      '.disk-ui-file-thumbnails-web-grid-img-item';
  static const String diskUiFileThumbnailsWebGridImg =
      '.disk-ui-file-thumbnails-web-grid-img';
  static const String feedInformCommentsPinnedAll =
      '.feed-inform-comments-pinned-all';
  static const String feedInformCommentsPinned = '.feed-inform-comments-pinned';

  // ======== ОСТАЛЬНЫЕ CSS СЕЛЕКТОРЫ (Комментарии и Файлы) ========
  static const String feedComBlockCover = '.feed-com-block-cover';
  static const String feedComTime = '.feed-com-time';
  static const String feedComTextInnerInner = '.feed-com-text-inner-inner';
  static const String feedComFileSize = '.feed-com-file-size';
  static const String avatarContainer = '.feed-com-avatar, .feed-user-avatar';

  // Алиасы для обратной совместимости (если использовались в старом коде)
  static const String feedComFilesPhotoImg = selFeedComFilesPhotoImg;
  static const String feedPostEmojiContainerSimple = selEmojiContainerSimple;
  static const String dataMyreactionSelector = selDataMyreaction;
  static const String dataValueSelector = selDataValue;

  // ======== HTML ТЕГИ ========
  static const String scriptTag = 'script';
  static const String imgTag = 'img';
  static const String iconTag = 'i';

  // ======== CSS КЛАССЫ ========
  static const String feedPostBlockPinnedClass = 'feed-post-block-pinned';
  static const String feedImpPostClass = 'feed-imp-post';
  static const String feedPostBlockImportantClass = 'feed-post-block-important';
  static const String feedCommentsBlock = 'feed-comments-block';

  // ======== КЛЮЧИ ДЛЯ MAP ========
  static const String imageUrlsKey = 'imageUrls';
  static const String cleanedTextKey = 'cleanedText';

  // ======== ПРЕФИКСЫ И ИДЕНТИФИКАТОРЫ ========
  static const String blogPostPrefix = 'BLOG_POST_';
  static const String blogCommentPrefix = 'BLOG_COMMENT_';
  static const String likeIdPrefix = "likeId: '";
  static const String likeIdSuffix = '-';

  // ======== ЗНАЧЕНИЯ И ДЕЙСТВИЯ ========
  static const String yesValue = 'Y';
  static const String unknownValue = 'unknown';
  static const String actionDownload = 'action=download';
  static const String actionShow = 'action=show';

  // ======== ЛОКАЛИЗАЦИЯ ДАТ (ru) ========
  static const String todayWord = 'сегодня';
  static const String yesterdayWord = 'вчера';

  // ======== ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ / FALLBACK ========
  static const String unknownAuthor = 'Неизвестный автор';
  static const String emptyString = '';
  static const String zeroString = '0';
  static const int unknownId = -1;
  static const String defaultSize = '0 Б';

  // ======== СПЕЦСИМВОЛЫ И HTML СУЩНОСТИ (Сборка из базовых) ========
  static const String charQuote = '"';
  static const String charAmpersand = '&';
  static const String htmlEntityQuote = '&quot;';
  static const String htmlEntityAmp = '&amp;';
  static const String emptyQuotes = '$charQuote$charQuote';
}

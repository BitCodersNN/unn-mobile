// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/palette_codec_constants.dart';
import 'package:unn_mobile/core/misc/cache/lru_cache.dart';

class _RegularExpressionSource {
  static const keySigned = r"keySigned:\s*'([^']+)'";
  static const commentIdAndMessage = r"top\.text\d+ = text(\d+) = '([^']*)'";
  static const author =
      r'<span class="feed-com-name.*?feed-author-name-(\d+)">([^<]+)<\/span>';
  static const dateTime =
      r'<a.*?class=\s*"[^"]*feed-com-time[^"]*"[^>]*>([^<]+)<\/a>';
  static const files =
      r'top\.arComDFiles(\d+) = BX\.util\.array_merge\(\(top\.arComDFiles\d+ \|\| \[\]\), \[(.*?)\]';
  static const cookieCleanup = r'^;+|;+$';
  static const leadingSlashes = r'^/+';
  static const leadingDigits = r'^(\d+)';
  static const errorText = r'class="errortext"[^>]*>([^<]+)';
  static const phpsessid = r'PHPSESSID=([^;]+)';
  static const distanceCourseSemester =
      r'''href=["']#/\{\{base_path\}\}/(\d{4})/(\d)["']''';
  static const upperCaseLetters = r'[A-Z]';
  static const sonetLAssetsCheckSum = r"sonetLAssetsCheckSum:\s*'([^']+)'";
  static const signedParameters = r"signedParameters:\s*'([^']+)'";
  static const commentFormUID = r"commentFormUID:\s*'([^']+)'";
  static const blogCommentFormUID = r"blogCommentFormUID:\s*'([^']+)'";
  static const urlPattern = r'''url\(['"]?([^'")]+)['"]?\)''';
  static const recordBlogPattern = r'record-BLOG_\d+-(\d+)-cover';
  static const blogPostIdPattern = r'BLOG_POST-(\d+)';
  static const digitsPattern = r'(\d+)';
  static const nonDigitsPattern = r'\D';
  static const fourDigitYearPattern = r'\b\d{4}\b';
  static const timePattern = r'(\d{1,2}:\d{2})';
  static const streamContentPattern = r'\(([^()]*)\)';
  static const multiValueSeparatorPattern = r'[|;,]';
  static const isoDateOnlyPattern = r'^\d{4}-\d{2}-\d{2}$';
  static const semverPrefixPattern = r'^v?(\d+(?:\.\d+)*)';
  static const hexColor6Pattern = r'^#?([0-9a-fA-F]{6})$';
  static const allowedHexCharsPattern = r'[#0-9a-fA-F]';
  static final customPaletteCodePattern =
      '${RegExp.escape(PaletteCodecConstants.prefix)}([A-Za-z0-9_-]+=*)';
  static final paletteUrlPattern =
      '(?:${RegExp.escape(PaletteCodecConstants.deepLinkScheme)}://|'
      'https://${RegExp.escape(PaletteCodecConstants.shareHost)}'
      '${RegExp.escape(PaletteCodecConstants.sharePathPrefix)})\\S*';
  static const trailingPunctuationPattern = r'''[.,;:!?)\]}"']+$''';
}

class RegularExpressions {
  static final commentIdAndMessageRegExp = RegExp(
    _RegularExpressionSource.commentIdAndMessage,
  );

  static final authorRegExp = RegExp(_RegularExpressionSource.author);

  static final dateTimeRegExp = RegExp(_RegularExpressionSource.dateTime);

  static final keySignedRegExp = RegExp(_RegularExpressionSource.keySigned);

  static final filesRegExp = RegExp(_RegularExpressionSource.files);

  static final cookieCleanupRegExp = RegExp(
    _RegularExpressionSource.cookieCleanup,
  );

  static final leadingSlashesRegExp = RegExp(
    _RegularExpressionSource.leadingSlashes,
  );

  static final leadingDigitsRegExp = RegExp(
    _RegularExpressionSource.leadingDigits,
  );

  static final errorRegex = RegExp(_RegularExpressionSource.errorText);

  static final phpsessidRegExp = RegExp(_RegularExpressionSource.phpsessid);

  static final distanceCourseSemesterRegExp = RegExp(
    _RegularExpressionSource.distanceCourseSemester,
  );

  static final uppercaseLettersRegExp = RegExp(
    _RegularExpressionSource.upperCaseLetters,
  );

  static final sonetLAssetsCheckSumRegExp = RegExp(
    _RegularExpressionSource.sonetLAssetsCheckSum,
    multiLine: true,
    caseSensitive: false,
  );

  static final signedParametersRegExp = RegExp(
    _RegularExpressionSource.signedParameters,
    multiLine: true,
    caseSensitive: false,
  );

  static final commentFormUIDRegExp = RegExp(
    _RegularExpressionSource.commentFormUID,
    multiLine: true,
    caseSensitive: false,
  );

  static final blogCommentFormUIDRegExp = RegExp(
    _RegularExpressionSource.blogCommentFormUID,
    multiLine: true,
    caseSensitive: false,
  );

  static final urlRegExp = RegExp(_RegularExpressionSource.urlPattern);

  static final recordBlogRegExp = RegExp(
    _RegularExpressionSource.recordBlogPattern,
  );

  static final blogPostIdRegExp = RegExp(
    _RegularExpressionSource.blogPostIdPattern,
  );

  static final digitsRegExp = RegExp(_RegularExpressionSource.digitsPattern);

  static final nonDigitsRegExp = RegExp(
    _RegularExpressionSource.nonDigitsPattern,
  );

  static final fourDigitYearRegExp = RegExp(
    _RegularExpressionSource.fourDigitYearPattern,
  );

  static final timeRegExp = RegExp(_RegularExpressionSource.timePattern);

  static final _dimensionRegExpCache = LRUCache<String, RegExp>(100);
  static RegExp dimensionValueRegExp(String dimension) =>
      _dimensionRegExpCache.putIfAbsent(
        dimension,
        () => RegExp('$dimension\\s*:\\s*(\\d+)px', caseSensitive: false),
      );

  static final streamContentRegExp = RegExp(
    _RegularExpressionSource.streamContentPattern,
  );

  static final multiValueSeparatorRegExp = RegExp(
    _RegularExpressionSource.multiValueSeparatorPattern,
  );

  static final isoDateOnlyRegExp = RegExp(
    _RegularExpressionSource.isoDateOnlyPattern,
  );

  static final semverPrefixRegExp = RegExp(
    _RegularExpressionSource.semverPrefixPattern,
  );

  static final hexColor6RegExp = RegExp(
    _RegularExpressionSource.hexColor6Pattern,
  );

  static final allowedHexCharsRegExp = RegExp(
    _RegularExpressionSource.allowedHexCharsPattern,
  );

  static final customPaletteCodeRegExp = RegExp(
    _RegularExpressionSource.customPaletteCodePattern,
  );

  static final paletteUrlRegExp = RegExp(
    _RegularExpressionSource.paletteUrlPattern,
  );

  static final trailingPunctuationRegExp = RegExp(
    _RegularExpressionSource.trailingPunctuationPattern,
  );
}

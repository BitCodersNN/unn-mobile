// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class _RegularExpressionSource {
  static const keySigned = r"keySigned: '.*',";
  static const commentIdAndMessage = r"top\.text\d+ = text(\d+) = '([^']*)'";
  static const author =
      r'<span class="feed-com-name.*?feed-author-name-(\d+)">([^<]+)<\/span>';
  static const dateTime =
      r'<a.*?class=\s*"[^"]*feed-com-time[^"]*"[^>]*>([^<]+)<\/a>';
  static const files =
      r'top\.arComDFiles(\d+) = BX\.util\.array_merge\(\(top\.arComDFiles\d+ \|\| \[\]\), \[(.*?)\]';
  static const cookieCleanup = r'^;+|;+$';
  static const leadingSlashes = r'^/+';
  static const phpsessid = r'PHPSESSID=([^;]+)';
  static const distanceCourseSemester =
      r'selectedYear == (\d{4}) && selectedSemester == (\d)';
}

class RegularExpressions {
  static final commentIdAndMessageRegExp = RegExp(
    _RegularExpressionSource.commentIdAndMessage,
  );

  static final authorRegExp = RegExp(
    _RegularExpressionSource.author,
  );

  static final dateTimeRegExp = RegExp(
    _RegularExpressionSource.dateTime,
  );

  static final keySignedRegExp = RegExp(
    _RegularExpressionSource.keySigned,
  );

  static final filesRegExp = RegExp(
    _RegularExpressionSource.files,
  );

  static final cookieCleanupRegExp = RegExp(
    _RegularExpressionSource.cookieCleanup,
  );

  static final leadingSlashesRegExp = RegExp(
    _RegularExpressionSource.leadingSlashes,
  );

  static final phpsessidRegExp = RegExp(
    _RegularExpressionSource.phpsessid,
  );

  static final distanceCourseSemesterExp = RegExp(
    _RegularExpressionSource.distanceCourseSemester,
  );
}

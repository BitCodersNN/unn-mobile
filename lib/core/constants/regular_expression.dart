class _RegularExpressionSource {
  static const keySigned = r"keySigned: '.*',";
  static const commentIdAndMessage = r"top\.text\d+ = text(\d+) = '([^']*)'";
  static const author =
      r'<span class="feed-com-name.*?feed-author-name-(\d+)">([^<]+)<\/span>';
  static const dateTime =
      r'<a.*?class=\s*"[^"]*feed-com-time[^"]*"[^>]*>([^<]+)<\/a>';
  static const files =
      r'top\.arComDFiles(\d+) = BX\.util\.array_merge\(\(top\.arComDFiles\d+ \|\| \[\]\), \[(.*?)\]';
}

class RegularExpression {
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
}

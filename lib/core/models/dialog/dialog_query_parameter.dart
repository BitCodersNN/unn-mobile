class _DialogQueryParameterJsonKeys {
  static const String limit = 'LIMIT';
  static const String skipOpenlines = 'SKIP_OPENLINES';
  static const String getOriginalText = 'GET_ORIGINAL_TEXT';
  static const String parseText = 'PARSE_TEXT';
  static const String lastMessageDate = 'LAST_MESSAGE_DATE';
}

class _DialogQueryParameterJsonValue {
  static const String y = 'Y';
  static const String n = 'N';
}

class DialogQueryParameter {
  final int limit;
  final DateTime? lastMessageDate;
  final bool skipOpenlines;
  final bool getOriginalText;
  final bool parseText;

  const DialogQueryParameter({
    this.limit = 50,
    this.lastMessageDate,
    this.skipOpenlines = false,
    this.getOriginalText = false,
    this.parseText = false,
  });

  Map<String, Object?> toJson() => {
        _DialogQueryParameterJsonKeys.limit: limit,
        _DialogQueryParameterJsonKeys.lastMessageDate: lastMessageDate?.toIso8601String(),
        _DialogQueryParameterJsonKeys.skipOpenlines: skipOpenlines
            ? _DialogQueryParameterJsonValue.y
            : _DialogQueryParameterJsonValue.n,
        _DialogQueryParameterJsonKeys.getOriginalText: getOriginalText
            ? _DialogQueryParameterJsonValue.y
            : _DialogQueryParameterJsonValue.n,
        _DialogQueryParameterJsonKeys.parseText: parseText
            ? _DialogQueryParameterJsonValue.y
            : _DialogQueryParameterJsonValue.n,
      };
}

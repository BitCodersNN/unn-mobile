class _KeysForUserInfoJsonConverter {
  static const String id = 'USER_ID';
  static const String fullname = 'FULL_NAME';
  static const String photoSrc = 'PHOTO_SRC';
}

class _KeysForUserInfoJsonConverterPortal2 {
  static const String id = 'id';
  static const String fullname = 'fio';
  static const String photoSrc = 'avatar';
}

class UserShortInfo {
  final int? _bitrixId;
  final String _fullname;
  final String? _photoSrc;

  int? get bitrixId => _bitrixId;
  String get fullname => _fullname;
  String? get photoSrc => _photoSrc;

  UserShortInfo(
    this._bitrixId,
    this._fullname,
    this._photoSrc,
  );

  factory UserShortInfo.fromJson(Map<String, Object?> jsonMap) => UserShortInfo(
        int.parse(jsonMap[_KeysForUserInfoJsonConverter.id] as String),
        jsonMap[_KeysForUserInfoJsonConverter.fullname] as String,
        jsonMap[_KeysForUserInfoJsonConverter.photoSrc] as String?,
      );

  factory UserShortInfo.fromJsonPortal2(Map<String, Object?> jsonMap) {
    final id = jsonMap[_KeysForUserInfoJsonConverterPortal2.id];
    final userId = id is int ? id : (id is String ? int.tryParse(id) : null);
    return UserShortInfo(
      userId,
      jsonMap[_KeysForUserInfoJsonConverterPortal2.fullname] as String,
      jsonMap[_KeysForUserInfoJsonConverterPortal2.photoSrc] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForUserInfoJsonConverter.id: _bitrixId,
        _KeysForUserInfoJsonConverter.fullname: _fullname,
        _KeysForUserInfoJsonConverter.photoSrc: _photoSrc,
      };
}

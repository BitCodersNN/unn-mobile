import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

abstract class _UserInfoKeys {
  String get id;
  String get fullname;
  String get photoSrc;
}

class _DefaultUserInfoKeys implements _UserInfoKeys {
  const _DefaultUserInfoKeys();
  @override
  String get id => 'id';
  @override
  String get fullname => 'fio';
  @override
  String get photoSrc => 'avatar';
}

class _BitrixUserInfoKeys implements _UserInfoKeys {
  const _BitrixUserInfoKeys();
  @override
  String get id => 'USER_ID';
  @override
  String get fullname => 'FULL_NAME';
  @override
  String get photoSrc => 'PHOTO_SRC';
}

class _BlogPostUserInfoKeys implements _UserInfoKeys {
  const _BlogPostUserInfoKeys();
  @override
  String get id => 'ID';
  @override
  String get fullname => 'FULL_NAME';
  @override
  String get photoSrc => 'PHOTO_SRC';
}

class _MessageUserInfoKeys implements _UserInfoKeys {
  const _MessageUserInfoKeys();
  @override
  String get id => 'id';
  @override
  String get fullname => 'name';
  @override
  String get photoSrc => 'avatar';
}

class UserShortInfo {
  final int? bitrixId;
  final String fullname;
  final String? photoSrc;

  UserShortInfo(
    this.bitrixId,
    this.fullname,
    this.photoSrc,
  );

  factory UserShortInfo._fromJsonWithKeys(
    Map<String, dynamic> json,
    _UserInfoKeys keys, {
    String? photoBaseUrl,
  }) {
    final id = json[keys.id];
    final parsedId = id is int ? id : (id is String ? int.tryParse(id) : null);

    final fullname = json[keys.fullname] as String;

    String? photoSrc = json[keys.photoSrc] as String?;
    if (photoSrc != null && photoSrc.isNotEmpty && photoBaseUrl != null) {
      photoSrc = '$photoBaseUrl$photoSrc';
    }

    return UserShortInfo(parsedId, fullname, photoSrc);
  }

  Map<String, dynamic> toJson() {
    const jsonKeys = _DefaultUserInfoKeys();

    return {
      jsonKeys.id: bitrixId.toString(),
      jsonKeys.fullname: fullname,
      jsonKeys.photoSrc: photoSrc,
    };
  }

  factory UserShortInfo.fromJson(Map<String, dynamic> json) {
    return UserShortInfo._fromJsonWithKeys(
      json,
      const _DefaultUserInfoKeys(),
    );
  }

  factory UserShortInfo.fromBitrixJson(Map<String, dynamic> json) {
    return UserShortInfo._fromJsonWithKeys(
      json,
      const _BitrixUserInfoKeys(),
    );
  }

  factory UserShortInfo.fromJsonImportantBlogPost(Map<String, dynamic> json) {
    return UserShortInfo._fromJsonWithKeys(
      json,
      const _BlogPostUserInfoKeys(),
      photoBaseUrl: '${ProtocolType.https}://${Host.unn}',
    );
  }

  factory UserShortInfo.fromMessageJson(Map<String, dynamic> json) {
    return UserShortInfo._fromJsonWithKeys(
      json,
      const _MessageUserInfoKeys(),
    );
  }
}

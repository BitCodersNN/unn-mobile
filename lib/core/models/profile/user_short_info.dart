import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/misc/json/json_key.dart';
import 'package:unn_mobile/core/misc/json/json_key_format.dart';
import 'package:unn_mobile/core/misc/json/json_serializable.dart';

abstract class _UserInfoKeys extends JsonKeys {
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

class UserShortInfo
    with
        MultiFormatJsonSerializable,
        BitrixJsonSerializable,
        BlogPostJsonSerializable,
        MessageJsonSerializable {
  final int? bitrixId;
  final String? fullname;
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
    final parsedId = switch (id) {
      final int idValue => idValue,
      final String idString => int.tryParse(idString),
      _ => null,
    };
    final fullname = json[keys.fullname] as String?;

    String? photoSrc = json[keys.photoSrc] as String?;
    if (photoSrc != null && photoSrc.isNotEmpty && photoBaseUrl != null) {
      photoSrc = '$photoBaseUrl$photoSrc';
    }

    return UserShortInfo(parsedId, fullname, photoSrc);
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

  @protected
  @override
  Map<JsonKeyFormat, JsonKeys> get availableFormats => const {
        JsonKeyFormat.standard: _DefaultUserInfoKeys(),
        JsonKeyFormat.bitrix: _BitrixUserInfoKeys(),
        JsonKeyFormat.blogPost: _BlogPostUserInfoKeys(),
        JsonKeyFormat.message: _MessageUserInfoKeys(),
      };

  @protected
  @override
  Map<String, dynamic> buildJsonMap(JsonKeys jsonKeys) {
    jsonKeys as _UserInfoKeys;
    return {
      jsonKeys.id: bitrixId.toString(),
      jsonKeys.fullname: fullname,
      jsonKeys.photoSrc: photoSrc,
    };
  }
}

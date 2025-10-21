// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/misc/json/json_key.dart';
import 'package:unn_mobile/core/misc/json/json_key_format.dart';
import 'package:unn_mobile/core/misc/json/json_serializable.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';

abstract class _UserInfoKeys extends JsonKeys {
  String get id;
  String get fullname;
  String get photoSrc;
}

class DefaultUserInfoKeys implements _UserInfoKeys {
  const DefaultUserInfoKeys();
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

class _ProfileUserInfoKeys implements _UserInfoKeys {
  const _ProfileUserInfoKeys();
  @override
  String get fullname => 'fullname';
  @override
  String get id => 'bitrix_id';
  @override
  String get photoSrc => 'photo';
  String get orig => 'orig';
}

class UserShortInfo
    with
        MultiFormatJsonSerializable,
        BitrixJsonSerializable,
        BlogPostJsonSerializable,
        MessageJsonSerializable,
        ProfileJsonSerializable {
  final int? bitrixId;
  final String? fullname;
  final String? photoSrc;

  UserShortInfo({
    this.bitrixId,
    this.fullname,
    this.photoSrc,
  });

  factory UserShortInfo._fromJsonWithKeys(
    JsonMap json,
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

    if (photoSrc == '${ProtocolType.https.name}://${Host.unn}') {
      photoSrc = null;
    }

    if (photoSrc != null &&
        photoSrc.isNotEmpty &&
        !photoSrc.startsWith(ProtocolType.https.name) &&
        photoBaseUrl != null) {
      photoSrc = '$photoBaseUrl$photoSrc';
    }

    return UserShortInfo(
      bitrixId: parsedId,
      fullname: fullname,
      photoSrc: photoSrc,
    );
  }

  factory UserShortInfo.fromJson(JsonMap json) =>
      UserShortInfo._fromJsonWithKeys(
        json,
        const DefaultUserInfoKeys(),
      );

  factory UserShortInfo.fromBitrixJson(JsonMap json) =>
      UserShortInfo._fromJsonWithKeys(
        json,
        const _BitrixUserInfoKeys(),
      );

  factory UserShortInfo.fromJsonImportantBlogPost(JsonMap json) =>
      UserShortInfo._fromJsonWithKeys(
        json,
        const _BlogPostUserInfoKeys(),
        photoBaseUrl: '${ProtocolType.https.name}://${Host.unn}',
      );

  factory UserShortInfo.fromMessageJson(JsonMap json) =>
      UserShortInfo._fromJsonWithKeys(
        json,
        const _MessageUserInfoKeys(),
      );

  factory UserShortInfo.fromProfileJson(JsonMap json) {
    const keys = _ProfileUserInfoKeys();

    final photoSrc = json[keys.photoSrc];
    if (photoSrc is Map) {
      json[keys.photoSrc] = photoSrc[keys.orig];
    }

    return UserShortInfo._fromJsonWithKeys(
      json,
      keys,
      photoBaseUrl: '${ProtocolType.https.name}://${Host.unn}',
    );
  }

  @protected
  @override
  Map<JsonKeyFormat, JsonKeys> get availableFormats => const {
        JsonKeyFormat.standard: DefaultUserInfoKeys(),
        JsonKeyFormat.bitrix: _BitrixUserInfoKeys(),
        JsonKeyFormat.blogPost: _BlogPostUserInfoKeys(),
        JsonKeyFormat.message: _MessageUserInfoKeys(),
        JsonKeyFormat.profile: _ProfileUserInfoKeys(),
      };

  @protected
  @override
  JsonMap buildJsonMap(JsonKeys jsonKeys) {
    jsonKeys as _UserInfoKeys;
    return {
      jsonKeys.id: bitrixId?.toString(),
      jsonKeys.fullname: fullname,
      jsonKeys.photoSrc: photoSrc,
    };
  }
}

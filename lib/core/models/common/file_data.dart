// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/json/json_key.dart';
import 'package:unn_mobile/core/misc/json/json_key_format.dart';
import 'package:unn_mobile/core/misc/json/json_serializable.dart';

abstract class _FileDataKeys extends JsonKeys {
  String get id;
  String get name;
  String get size;
  String get downloadUrl;
}

class _DefaultFileDataKeys implements _FileDataKeys {
  const _DefaultFileDataKeys();
  @override
  String get id => 'id';
  @override
  String get name => 'name';
  @override
  String get size => 'size';
  @override
  String get downloadUrl => 'href';
}

class _BitrixFileDataKeys implements _FileDataKeys {
  const _BitrixFileDataKeys();
  @override
  String get id => 'ID';
  @override
  String get name => 'NAME';
  @override
  String get size => 'SIZE';
  @override
  String get downloadUrl => 'DOWNLOAD_URL';
}

class _MessageFileDataKeys implements _FileDataKeys {
  const _MessageFileDataKeys();
  @override
  String get id => 'id';
  @override
  String get name => 'name';
  @override
  String get size => 'size';
  @override
  String get downloadUrl => 'urlDownload';
}

class FileData
    with
        MultiFormatJsonSerializable,
        BitrixJsonSerializable,
        MessageJsonSerializable {
  final int id;
  final String name;
  final int sizeInBytes;
  final String downloadUrl;

  FileData({
    required this.id,
    required this.name,
    required this.sizeInBytes,
    required this.downloadUrl,
  });

  factory FileData._fromJsonWithKeys(
    Map<String, dynamic> json,
    _FileDataKeys keys, {
    bool generateIdFromName = false,
  }) {
    final id = switch (generateIdFromName) {
      true => (json[keys.name] as String).hashCode,
      false => switch (json[keys.id]) {
          final int idValue => idValue,
          final String idString => int.parse(idString),
          _ => throw const FormatException('Invalid ID format in JSON'),
        },
    };

    final size = switch (json[keys.size]) {
      final String sizeString => int.parse(sizeString),
      final int sizeInt => sizeInt,
      _ => throw const FormatException('Invalid size format in JSON'),
    };

    return FileData(
      id: id,
      name: json[keys.name] as String,
      sizeInBytes: size,
      downloadUrl: json[keys.downloadUrl] as String,
    );
  }

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData._fromJsonWithKeys(
      json,
      const _DefaultFileDataKeys(),
      generateIdFromName: true,
    );
  }

  factory FileData.fromBitrixJson(Map<String, dynamic> json) {
    return FileData._fromJsonWithKeys(
      json,
      const _BitrixFileDataKeys(),
    );
  }

  factory FileData.fromMessageJson(Map<String, dynamic> json) {
    return FileData._fromJsonWithKeys(
      json,
      const _MessageFileDataKeys(),
    );
  }

  @protected
  @override
  Map<JsonKeyFormat, JsonKeys> get availableFormats => const {
        JsonKeyFormat.standard: _DefaultFileDataKeys(),
        JsonKeyFormat.bitrix: _BitrixFileDataKeys(),
        JsonKeyFormat.message: _MessageFileDataKeys(),
      };

  @protected
  @override
  Map<String, dynamic> buildJsonMap(JsonKeys keys) {
    keys as _FileDataKeys;
    return {
      keys.id: id.toString(),
      keys.name: name,
      keys.size: sizeInBytes.toString(),
      keys.downloadUrl: downloadUrl,
    };
  }
}

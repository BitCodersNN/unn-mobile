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

class FileData extends JsonSerializable {
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
    final id = generateIdFromName
        ? (json[keys.name] as String).hashCode
        : json[keys.id] is int
            ? json[keys.id]
            : int.parse(json[keys.id] as String);

    final size = json[keys.size] is String
        ? int.parse(json[keys.size] as String)
        : (json[keys.size] as int);

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
  Map<JsonKeyFormat, JsonKeys> get formatToKeys => const {
        JsonKeyFormat.standard: _DefaultFileDataKeys(),
        JsonKeyFormat.bitrix: _BitrixFileDataKeys(),
        JsonKeyFormat.message: _MessageFileDataKeys(),
      };

  @protected
  @override
  Map<String, dynamic> buildJsonMap(JsonKeys jsonKeys) {
    jsonKeys as _FileDataKeys;
    return {
      jsonKeys.id: id.toString(),
      jsonKeys.name: name,
      jsonKeys.size: sizeInBytes.toString(),
      jsonKeys.downloadUrl: downloadUrl,
    };
  }
}

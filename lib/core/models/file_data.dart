class _KeysForFileDataJsonConverterLegacy {
  static const String id = 'ID';
  static const String name = 'NAME';
  static const String size = 'SIZE';
  static const String downloadUrl = 'DOWNLOAD_URL';
}

class _KeysForFileDataJsonConverter {
  static const String name = 'name';
  static const String size = 'size';
  static const String href = 'href';
}

class FileData {
  final int id;
  final String name;
  final int sizeInBytes;
  final String downloadUrl;

  FileData._({
    required this.id,
    required this.name,
    required this.sizeInBytes,
    required this.downloadUrl,
  });

  factory FileData.fromJson(Map<String, Object?> jsonMap) {
    final fileName = jsonMap[_KeysForFileDataJsonConverter.name] as String;
    return FileData._(
      id: fileName.hashCode,
      name: fileName,
      sizeInBytes: int.parse(
        jsonMap[_KeysForFileDataJsonConverter.size] as String,
      ),
      downloadUrl: jsonMap[_KeysForFileDataJsonConverter.href] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForFileDataJsonConverter.name: name,
        _KeysForFileDataJsonConverter.size: sizeInBytes.toString(),
        _KeysForFileDataJsonConverter.href: downloadUrl,
      };

  factory FileData.fromJsonLegacy(Map<String, Object?> jsonMap) {
    return FileData._(
      id: int.parse(jsonMap[_KeysForFileDataJsonConverterLegacy.id] as String),
      name: jsonMap[_KeysForFileDataJsonConverterLegacy.name] as String,
      sizeInBytes: int.parse(
        jsonMap[_KeysForFileDataJsonConverterLegacy.size] as String,
      ),
      downloadUrl:
          jsonMap[_KeysForFileDataJsonConverterLegacy.downloadUrl] as String,
    );
  }
}

class _KeysForFileDataJsonConverter {
  static const String id = 'ID';
  static const String name = 'NAME';
  static const String size = 'SIZE';
  static const String downloadUrl = 'DOWNLOAD_URL';
}

class _KeysForFileDataJsonConverterPortal2 {
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
    return FileData._(
      id: int.parse(jsonMap[_KeysForFileDataJsonConverter.id] as String),
      name: jsonMap[_KeysForFileDataJsonConverter.name] as String,
      sizeInBytes:
          int.parse(jsonMap[_KeysForFileDataJsonConverter.size] as String),
      downloadUrl: jsonMap[_KeysForFileDataJsonConverter.downloadUrl] as String,
    );
  }

  factory FileData.fromJsonPortal2(Map<String, Object?> jsonMap) {
    final fileName =
        jsonMap[_KeysForFileDataJsonConverterPortal2.name] as String;
    return FileData._(
      id: fileName.hashCode,
      name: fileName,
      sizeInBytes: int.parse(
        jsonMap[_KeysForFileDataJsonConverterPortal2.size] as String,
      ),
      downloadUrl: jsonMap[_KeysForFileDataJsonConverterPortal2.href] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForFileDataJsonConverter.id: id,
        _KeysForFileDataJsonConverter.name: name,
        _KeysForFileDataJsonConverter.size: sizeInBytes,
        _KeysForFileDataJsonConverter.downloadUrl: downloadUrl,
      };
}

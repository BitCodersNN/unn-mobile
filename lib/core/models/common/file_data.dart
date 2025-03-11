class _FileDataBitrixJsonKeys {
  static const String id = 'ID';
  static const String name = 'NAME';
  static const String size = 'SIZE';
  static const String downloadUrl = 'DOWNLOAD_URL';
}

class _FileDataJsonKeys {
  static const String name = 'name';
  static const String size = 'size';
  static const String href = 'href';
}

class FileData {
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

  factory FileData.fromJson(Map<String, Object?> jsonMap) {
    final fileName = jsonMap[_FileDataJsonKeys.name] as String;
    return FileData(
      id: fileName.hashCode,
      name: fileName,
      sizeInBytes: int.parse(
        jsonMap[_FileDataJsonKeys.size] as String,
      ),
      downloadUrl: jsonMap[_FileDataJsonKeys.href] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        _FileDataJsonKeys.name: name,
        _FileDataJsonKeys.size: sizeInBytes.toString(),
        _FileDataJsonKeys.href: downloadUrl,
      };

  factory FileData.fromBitrixJson(Map<String, Object?> jsonMap) {
    return FileData(
      id: int.parse(jsonMap[_FileDataBitrixJsonKeys.id] as String),
      name: jsonMap[_FileDataBitrixJsonKeys.name] as String,
      sizeInBytes: int.parse(
        jsonMap[_FileDataBitrixJsonKeys.size] as String,
      ),
      downloadUrl: jsonMap[_FileDataBitrixJsonKeys.downloadUrl] as String,
    );
  }
}

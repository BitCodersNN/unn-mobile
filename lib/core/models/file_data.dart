class _KeysForFileDataJsonConverter {
  static const String id = 'ID';
  static const String name = 'NAME';
  static const String size = 'SIZE';
  static const String downloadUrl = 'DOWNLOAD_URL';
}

class FileData {
  final int _id;
  final String _name;
  final int _sizeInByte;
  final String _downloadUrl;

  FileData(
    this._id,
    this._name,
    this._sizeInByte,
    this._downloadUrl,
  );

  int get id => _id;
  String get name => _name;
  int get sizeInByte => _sizeInByte;
  String get downloadUrl => _downloadUrl;

  factory FileData.fromJson(Map<String, Object?> jsonMap) => FileData(
        int.parse(jsonMap[_KeysForFileDataJsonConverter.id] as String),
        jsonMap[_KeysForFileDataJsonConverter.name] as String,
        int.parse(jsonMap[_KeysForFileDataJsonConverter.size] as String),
        jsonMap[_KeysForFileDataJsonConverter.downloadUrl] as String,
      );

  Map<String, dynamic> toJson() => {
        _KeysForFileDataJsonConverter.id: _id,
        _KeysForFileDataJsonConverter.name: _name,
        _KeysForFileDataJsonConverter.size: _sizeInByte,
        _KeysForFileDataJsonConverter.downloadUrl: _downloadUrl,
      };
}

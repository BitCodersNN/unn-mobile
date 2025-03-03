import 'package:unn_mobile/core/constants/api/host_with_base_path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_material_data.dart';
import 'package:unn_mobile/core/models/file_data.dart';

class _KeysForFileDataJsonConverter {
  static const String id = 'id';
  static const String fileSrcName = 'file_src_name';
  static const String fileSize = 'file_size';
  static const String fileHash = 'file_hash';
  static const String comment = 'comment';
  static const String fileDate = 'file_date';
}

final class DistanceFileData extends DistanceMaterialData {
  static final _baseDownloadUrl =
      '${ProtocolType.https.name}://${HostWithBasePath.sourceFile}?hash=';

  late final FileData _fileData;

  DistanceFileData({
    required int id,
    required String name,
    required int sizeInBytes,
    required String downloadUrl,
    required super.comment,
    required super.dateTime,
  }) {
    _fileData = FileData(
      id: id,
      name: name,
      sizeInBytes: sizeInBytes,
      downloadUrl: downloadUrl,
    );
  }

  int get id => _fileData.id;
  String get name => _fileData.name;
  int get sizeInBytes => _fileData.sizeInBytes;
  String get downloadUrl => _fileData.downloadUrl;

  @override
  factory DistanceFileData.fromJson(Map<String, Object?> jsonMap) =>
      DistanceFileData(
        comment: jsonMap[_KeysForFileDataJsonConverter.comment] as String,
        dateTime: DateTime.parse(
          jsonMap[_KeysForFileDataJsonConverter.fileDate] as String,
        ),
        id: int.parse(jsonMap[_KeysForFileDataJsonConverter.id] as String),
        name: jsonMap[_KeysForFileDataJsonConverter.fileSrcName] as String,
        sizeInBytes: int.parse(
          jsonMap[_KeysForFileDataJsonConverter.fileSize] as String,
        ),
        downloadUrl:
            '$_baseDownloadUrl${jsonMap[_KeysForFileDataJsonConverter.fileHash]}',
      );

  @override
  Map<String, Object?> toJson() => {
        _KeysForFileDataJsonConverter.comment: comment,
        _KeysForFileDataJsonConverter.fileDate: dateTime.toIso8601String(),
        _KeysForFileDataJsonConverter.id: id.toString(),
        _KeysForFileDataJsonConverter.fileSrcName: name,
        _KeysForFileDataJsonConverter.fileSize: sizeInBytes.toString(),
        _KeysForFileDataJsonConverter.fileHash: downloadUrl.split('hash=')[1],
      };
}

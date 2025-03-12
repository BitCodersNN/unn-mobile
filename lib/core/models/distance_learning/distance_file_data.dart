import 'package:unn_mobile/core/constants/api/host_with_base_path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/models/distance_learning/distance_material_data.dart';
import 'package:unn_mobile/core/models/common/file_data.dart';

class _FileDataJsonKeys {
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
        comment: jsonMap[_FileDataJsonKeys.comment] as String,
        dateTime: DateTime.parse(
          jsonMap[_FileDataJsonKeys.fileDate] as String,
        ),
        id: int.parse(jsonMap[_FileDataJsonKeys.id] as String),
        name: jsonMap[_FileDataJsonKeys.fileSrcName] as String,
        sizeInBytes: int.parse(
          jsonMap[_FileDataJsonKeys.fileSize] as String,
        ),
        downloadUrl: '$_baseDownloadUrl${jsonMap[_FileDataJsonKeys.fileHash]}',
      );

  @override
  Map<String, Object?> toJson() => {
        _FileDataJsonKeys.comment: comment,
        _FileDataJsonKeys.fileDate: dateTime.toIso8601String(),
        _FileDataJsonKeys.id: id.toString(),
        _FileDataJsonKeys.fileSrcName: name,
        _FileDataJsonKeys.fileSize: sizeInBytes.toString(),
        _FileDataJsonKeys.fileHash: downloadUrl.split('hash=')[1],
      };
}

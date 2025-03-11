import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

class _UserInfoJsonBitrixKeys {
  static const String id = 'USER_ID';
  static const String fullname = 'FULL_NAME';
  static const String photoSrc = 'PHOTO_SRC';
}

class _UserInfoJsonKeys {
  static const String id = 'id';
  static const String fullname = 'fio';
  static const String photoSrc = 'avatar';
}

class _UserInfoJsonImportantBlogPostKeys {
  static const String id = 'ID';
  static const String fullname = 'FULL_NAME';
  static const String photoSrc = 'PHOTO_SRC';
}

class UserShortInfo {
  final int? bitrixId;
  final String fullname;
  final String? photoSrc;

  UserShortInfo(
    this.bitrixId,
    this.fullname,
    this.photoSrc,
  );

  factory UserShortInfo.fromJson(Map<String, Object?> jsonMap) {
    final id = jsonMap[_UserInfoJsonKeys.id];
    final userId = id is int ? id : (id is String ? int.tryParse(id) : null);
    return UserShortInfo(
      userId,
      jsonMap[_UserInfoJsonKeys.fullname] as String,
      jsonMap[_UserInfoJsonKeys.photoSrc] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _UserInfoJsonKeys.id: bitrixId.toString(),
        _UserInfoJsonKeys.fullname: fullname,
        _UserInfoJsonKeys.photoSrc: photoSrc,
      };

  factory UserShortInfo.fromJsonImportantBlogPost(
    Map<String, Object?> jsonMap,
  ) {
    final id = int.tryParse(
      jsonMap[_UserInfoJsonImportantBlogPostKeys.id] as String,
    );
    final fullname =
        jsonMap[_UserInfoJsonImportantBlogPostKeys.fullname]
            as String;
    final photoSrc =
        jsonMap[_UserInfoJsonImportantBlogPostKeys.photoSrc]
            as String?;

    final String? resolvedPhotoSrc = photoSrc?.isNotEmpty == true
        ? '${ProtocolType.https.name}://${Host.unn}${photoSrc!}'
        : null;

    return UserShortInfo(
      id,
      fullname,
      resolvedPhotoSrc,
    );
  }

  factory UserShortInfo.fromJsonLegacy(Map<String, Object?> jsonMap) =>
      UserShortInfo(
        int.tryParse(jsonMap[_UserInfoJsonBitrixKeys.id] as String),
        jsonMap[_UserInfoJsonBitrixKeys.fullname] as String,
        jsonMap[_UserInfoJsonBitrixKeys.photoSrc] as String?,
      );
}

import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

class _KeysForUserInfoJsonConverterLegacy {
  static const String id = 'USER_ID';
  static const String fullname = 'FULL_NAME';
  static const String photoSrc = 'PHOTO_SRC';
}

class _KeysForUserInfoJsonConverter {
  static const String id = 'id';
  static const String fullname = 'fio';
  static const String photoSrc = 'avatar';
}

class _KeysForUserInfoJsonConverterImportantBlogPost {
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
    final id = jsonMap[_KeysForUserInfoJsonConverter.id];
    final userId = id is int ? id : (id is String ? int.tryParse(id) : null);
    return UserShortInfo(
      userId,
      jsonMap[_KeysForUserInfoJsonConverter.fullname] as String,
      jsonMap[_KeysForUserInfoJsonConverter.photoSrc] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        _KeysForUserInfoJsonConverter.id: bitrixId.toString(),
        _KeysForUserInfoJsonConverter.fullname: fullname,
        _KeysForUserInfoJsonConverter.photoSrc: photoSrc,
      };

  factory UserShortInfo.fromJsonImportantBlogPost(
    Map<String, Object?> jsonMap,
  ) {
    final id = int.tryParse(
      jsonMap[_KeysForUserInfoJsonConverterImportantBlogPost.id] as String,
    );
    final fullname =
        jsonMap[_KeysForUserInfoJsonConverterImportantBlogPost.fullname]
            as String;
    final photoSrc =
        jsonMap[_KeysForUserInfoJsonConverterImportantBlogPost.photoSrc]
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
        int.tryParse(jsonMap[_KeysForUserInfoJsonConverterLegacy.id] as String),
        jsonMap[_KeysForUserInfoJsonConverterLegacy.fullname] as String,
        jsonMap[_KeysForUserInfoJsonConverterLegacy.photoSrc] as String?,
      );
}

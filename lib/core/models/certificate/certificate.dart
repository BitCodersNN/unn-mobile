import 'package:unn_mobile/core/models/certificate/certificate_types_info.dart';

class KeysForCertificateJsonConverter {
  static const String name = 'name';
  static const String sendtype = 'sendtype';
  static const String description = 'description';
  static const String certificatePath = 'certificate_path';
}

class Certificate {
  final String name;
  final int sendtype;
  final String description;
  final String certificatePath;

  Certificate({
    required this.name,
    required this.sendtype,
    required this.description,
    required this.certificatePath,
  });

  String? get certificateSigPath =>
      certificatePath.isEmpty ? null : '$certificatePath.sig';

  factory Certificate.fromJson(Map<String, Object?> jsonMap) => Certificate(
        name: jsonMap[KeysForCertificateJsonConverter.name] as String,
        sendtype: jsonMap[KeysForCertificateJsonConverter.sendtype] as int,
        description:
            jsonMap[KeysForCertificateJsonConverter.description] as String,
        certificatePath:
            jsonMap[KeysForCertificateJsonConverter.certificatePath] as String,
      );

  factory Certificate.fromPracticeUrl(String practiceUrl) {
    return Certificate(
      name: 'Предписание на практику',
      sendtype: certificateTypesInfo['practices']?['sendtype'] as int,
      description: certificateTypesInfo['practices']?['description'] as String,
      certificatePath: practiceUrl,
    );
  }
  Map<String, dynamic> toJson() => {
        KeysForCertificateJsonConverter.name: name,
        KeysForCertificateJsonConverter.sendtype: sendtype,
        KeysForCertificateJsonConverter.description: description,
        KeysForCertificateJsonConverter.certificatePath: certificatePath,
      };
}

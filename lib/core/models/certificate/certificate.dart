// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/certificate/certificate_types_info.dart';

class CertificateJsonKeys {
  static const String name = 'name';
  static const String sendtype = 'sendtype';
  static const String description = 'description';
  static const String certificatePath = 'certificate_path';
  static const String practices = 'practices';
  static const String practice = 'practice';
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
        name: jsonMap[CertificateJsonKeys.name] as String,
        sendtype: jsonMap[CertificateJsonKeys.sendtype] as int,
        description: jsonMap[CertificateJsonKeys.description] as String,
        certificatePath: jsonMap[CertificateJsonKeys.certificatePath] as String,
      );

  factory Certificate.fromPracticeUrl(String practiceUrl) {
    final practiceTypeInfo =
        certificateTypesInfo[CertificateJsonKeys.practices];
    return Certificate(
      name: 'Предписание на практику',
      sendtype: practiceTypeInfo?[CertificateJsonKeys.sendtype] as int,
      description: practiceTypeInfo?[CertificateJsonKeys.description] as String,
      certificatePath: practiceUrl,
    );
  }
  Map<String, dynamic> toJson() => {
        CertificateJsonKeys.name: name,
        CertificateJsonKeys.sendtype: sendtype,
        CertificateJsonKeys.description: description,
        CertificateJsonKeys.certificatePath: certificatePath,
      };
}

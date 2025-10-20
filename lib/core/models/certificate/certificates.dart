// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/certificate/certificate.dart';
import 'package:unn_mobile/core/models/certificate/certificate_types_info.dart';
import 'package:unn_mobile/core/models/certificate/practice_order.dart';

class _CertificatesJsonKeys {
  static const String practices = 'practices';
  static const String practice = 'practice';
}

class Certificates {
  final List<Certificate> certificates;

  Certificates._({required this.certificates});

  Certificates.empty() : this._(certificates: []);

  factory Certificates.fromJson(JsonMap jsonMap) {
    final certificates = <Certificate>[];
    jsonMap.forEach((certificateType, certificate) {
      if (certificateType == _CertificatesJsonKeys.practices) {
        certificates.addAll(_parsePracticeCertificates(certificate! as List));
      } else if (certificateTypesInfo.containsKey(certificateType)) {
        final certificateJson = _createCertificateJson(
          certificateType,
          certificate as String?,
        );
        certificates.add(Certificate.fromJson(certificateJson));
      }
    });
    if ((jsonMap[_CertificatesJsonKeys.practice]! as String).isNotEmpty) {
      certificates.add(
        Certificate.fromPracticeUrl(
          jsonMap[_CertificatesJsonKeys.practice]! as String,
        ),
      );
    }
    return Certificates._(certificates: certificates);
  }

  static List<Certificate> _parsePracticeCertificates(List<dynamic> practices) {
    return practices
        .whereType<JsonMap>()
        .map(
          (practice) => PracticeOrder.fromJson(
            _createPracticeCertificateJson(practice),
          ),
        )
        .toList();
  }

  static JsonMap _createCertificateJson(
    String certificateType,
    String? certificateUri,
  ) {
    final certificateJson =
        JsonMap.from(certificateTypesInfo[certificateType]!);

    certificateJson[CertificateJsonKeys.certificatePath] =
        certificateUri?.isNotEmpty ?? false
            ? Uri.parse(certificateUri!).path.substring(1)
            : '';

    return certificateJson;
  }

  static JsonMap _createPracticeCertificateJson(
    JsonMap practice,
  ) {
    final certificateUri = practice[_CertificatesJsonKeys.practice] as String?;
    final practiceReferenceJson = JsonMap.from(practice)
      ..addAll(
        certificateTypesInfo[_CertificatesJsonKeys.practices]!,
      );
    practiceReferenceJson[CertificateJsonKeys.certificatePath] =
        certificateUri?.isNotEmpty ?? false
            ? Uri.parse(certificateUri!).path.substring(1)
            : '';
    return practiceReferenceJson;
  }
}

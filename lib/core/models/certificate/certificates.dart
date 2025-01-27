import 'package:unn_mobile/core/models/certificate/practice_order.dart';
import 'package:unn_mobile/core/models/certificate/certificate.dart';
import 'package:unn_mobile/core/models/certificate/certificate_types_info.dart';

class _KeysForCertificatesJsonConverter {
  static const String practices = 'practices';
  static const String practice = 'practice';
}

class Certificates {
  final List<Certificate> certificates;

  Certificates._({required this.certificates});

  Certificates.empty() : this._(certificates: []);

  factory Certificates.fromJson(Map<String, Object?> jsonMap) {
    final certificates = <Certificate>[];
    jsonMap.forEach((certificateType, certificate) {
      if (certificateType == _KeysForCertificatesJsonConverter.practices) {
        certificates.addAll(_parsePracticeCertificates(certificate as List));
      } else if (certificateTypesInfo.containsKey(certificateType)) {
        final certificateJson = _createCertificateJson(
          certificateType,
          certificate as String?,
        );
        certificates.add(Certificate.fromJson(certificateJson));
      }
    });
    return Certificates._(certificates: certificates);
  }

  static List<Certificate> _parsePracticeCertificates(List<dynamic> practices) {
    return practices
        .whereType<Map<String, Object?>>()
        .map(
          (practice) => PracticeOrder.fromJson(
            _createPracticeCertificateJson(practice),
          ),
        )
        .toList();
  }

  static Map<String, Object?> _createCertificateJson(
    String certificateType,
    String? certificateUri,
  ) {
    final certificateJson =
        Map<String, Object?>.from(certificateTypesInfo[certificateType]!);

    certificateJson[KeysForCertificateJsonConverter.certificatePath] =
        certificateUri?.isNotEmpty == true
            ? Uri.parse(certificateUri!).path.substring(1)
            : '';

    return certificateJson;
  }

  static Map<String, Object?> _createPracticeCertificateJson(
    Map<String, Object?> practice,
  ) {
    final certificateUri =
        practice[_KeysForCertificatesJsonConverter.practice] as String?;
    final practiceReferenceJson = Map<String, Object?>.from(practice);
    practiceReferenceJson.addAll(
      certificateTypesInfo[_KeysForCertificatesJsonConverter.practice]!,
    );
    practiceReferenceJson[KeysForCertificateJsonConverter.certificatePath] =
        certificateUri?.isNotEmpty == true
            ? Uri.parse(certificateUri!).path.substring(1)
            : '';
    return practiceReferenceJson;
  }
}

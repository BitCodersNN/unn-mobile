import 'package:unn_mobile/core/models/certificate/practice_order.dart';
import 'package:unn_mobile/core/models/certificate/certificate.dart';
import 'package:unn_mobile/core/models/certificate/certificate_types_info.dart';

class _KeysForCertificatesJsonConverter {
  static const String practices = 'practices';
  static const String practice = 'practice';
}

class Certificates {
  final List<Certificate> references;

  Certificates._({required this.references});

  Certificates.empty() : this._(references: []);

  factory Certificates.fromJson(Map<String, Object?> jsonMap) {
    final references = <Certificate>[];
    jsonMap.forEach((referenceType, reference) {
      if (referenceType == _KeysForCertificatesJsonConverter.practices) {
        references.addAll(_parsePracticeReferences(reference as List));
      } else if (certificateTypesInfo.containsKey(referenceType)) {
        final referenceJson = _createReferenceJson(
          referenceType,
          reference as String?,
        );
        references.add(Certificate.fromJson(referenceJson));
      }
    });
    return Certificates._(references: references);
  }

  static List<Certificate> _parsePracticeReferences(List<dynamic> practices) {
    return practices
        .whereType<Map<String, Object?>>()
        .map(
          (practice) => PracticeOrder.fromJson(
            _createPracticeReferenceJson(practice),
          ),
        )
        .toList();
  }

  static Map<String, Object?> _createReferenceJson(
    String referenceType,
    String? referenceUri,
  ) {
    final referenceJson =
        Map<String, Object?>.from(certificateTypesInfo[referenceType]!);

    referenceJson[KeysForCertificateJsonConverter.referencePath] =
        referenceUri?.isNotEmpty == true
            ? Uri.parse(referenceUri!).path.substring(1)
            : '';

    return referenceJson;
  }

  static Map<String, Object?> _createPracticeReferenceJson(
    Map<String, Object?> practice,
  ) {
    final referenceUri =
        practice[_KeysForCertificatesJsonConverter.practice] as String?;
    final practiceReferenceJson = Map<String, Object?>.from(practice);
    practiceReferenceJson
        .addAll(certificateTypesInfo[_KeysForCertificatesJsonConverter.practice]!);
    practiceReferenceJson[KeysForCertificateJsonConverter.referencePath] =
        referenceUri?.isNotEmpty == true
            ? Uri.parse(referenceUri!).path.substring(1)
            : '';
    return practiceReferenceJson;
  }
}

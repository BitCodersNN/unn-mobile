import 'package:unn_mobile/core/models/reference_order/practice_reference.dart';
import 'package:unn_mobile/core/models/reference_order/reference.dart';
import 'package:unn_mobile/core/models/reference_order/reference_types_info.dart';

class _KeysForPracticesJsonConverter {
  static const String practices = 'practices';
  static const String practice = 'practice';
}

class References {
  final List<Reference> references;

  References._({required this.references});

  References.empty() : this._(references: []);

  factory References.fromJson(Map<String, Object?> jsonMap) {
    final references = <Reference>[];
    jsonMap.forEach((referenceType, reference) {
      if (referenceType == _KeysForPracticesJsonConverter.practices) {
        references.addAll(_parsePracticeReferences(reference as List));
      } else if (referenceTypesInfo.containsKey(referenceType)) {
        final referenceJson = _createReferenceJson(referenceType, reference);
        references.add(Reference.fromJson(referenceJson));
      }
    });
    return References._(references: references);
  }

  static List<Reference> _parsePracticeReferences(List<dynamic> practices) {
    return practices
        .whereType<Map<String, Object?>>()
        .map(
          (practice) => PracticeReference.fromJson(
            _createPracticeReferenceJson(practice),
          ),
        )
        .toList();
  }

  static Map<String, Object?> _createReferenceJson(
    String referenceType,
    Object? reference,
  ) {
    final referenceJson = Map<String, Object?>.from(referenceTypesInfo[referenceType]!);
    referenceJson[KeysForReferenceJsonConverter.referenceUrl] = reference;
    return referenceJson;
  }

  static Map<String, Object?> _createPracticeReferenceJson(
    Map<String, Object?> practice,
  ) {
    final practiceReferenceJson = Map<String, Object?>.from(practice);
    practiceReferenceJson
        .addAll(referenceTypesInfo[_KeysForPracticesJsonConverter.practice]!);
    practiceReferenceJson[KeysForReferenceJsonConverter.referenceUrl] =
        practice[_KeysForPracticesJsonConverter.practice];
    return practiceReferenceJson;
  }
}

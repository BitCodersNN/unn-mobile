class KeysForReferenceJsonConverter {
  static const String name = 'name';
  static const String sendtype = 'sendtype';
  static const String description = 'description';
  static const String referencePath = 'reference_path';
}

class Reference {
  final String name;
  final int sendtype;
  final String description;
  final String referencePath;

  Reference({
    required this.name,
    required this.sendtype,
    required this.description,
    required this.referencePath,
  });

  String? get referenceSigPath =>
      referencePath.isEmpty ? null : '$referencePath.sig';

  factory Reference.fromJson(Map<String, Object?> jsonMap) => Reference(
        name: jsonMap[KeysForReferenceJsonConverter.name] as String,
        sendtype: jsonMap[KeysForReferenceJsonConverter.sendtype] as int,
        description:
            jsonMap[KeysForReferenceJsonConverter.description] as String,
        referencePath:
            jsonMap[KeysForReferenceJsonConverter.referencePath] as String,
      );

  Map<String, dynamic> toJson() => {
        KeysForReferenceJsonConverter.name: name,
        KeysForReferenceJsonConverter.sendtype: sendtype,
        KeysForReferenceJsonConverter.description: description,
        KeysForReferenceJsonConverter.referencePath: referencePath,
      };
}

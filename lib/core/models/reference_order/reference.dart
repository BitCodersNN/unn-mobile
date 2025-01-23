class KeysForReferenceJsonConverter {
  static const String name = 'name';
  static const String sendtype = 'sendtype';
  static const String description = 'description';
  static const String referenceUrl = 'reference_url';
}

class Reference {
  final String name;
  final int sendtype;
  final String description;
  final String referenceUrl;

  Reference({
    required this.name,
    required this.sendtype,
    required this.description,
    required this.referenceUrl,
  });

  factory Reference.fromJson(Map<String, Object?> jsonMap) => Reference(
        name: jsonMap[KeysForReferenceJsonConverter.name] as String,
        sendtype: jsonMap[KeysForReferenceJsonConverter.sendtype] as int,
        description:
            jsonMap[KeysForReferenceJsonConverter.description] as String,
        referenceUrl:
            jsonMap[KeysForReferenceJsonConverter.referenceUrl] as String,
      );

  Map<String, dynamic> toJson() => {
        KeysForReferenceJsonConverter.name: name,
        KeysForReferenceJsonConverter.sendtype: sendtype,
        KeysForReferenceJsonConverter.description: description,
        KeysForReferenceJsonConverter.referenceUrl: referenceUrl,
      };
}

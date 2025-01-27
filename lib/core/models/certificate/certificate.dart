class KeysForCertificateJsonConverter {
  static const String name = 'name';
  static const String sendtype = 'sendtype';
  static const String description = 'description';
  static const String referencePath = 'reference_path';
}

class Certificate {
  final String name;
  final int sendtype;
  final String description;
  final String referencePath;

  Certificate({
    required this.name,
    required this.sendtype,
    required this.description,
    required this.referencePath,
  });

  String? get referenceSigPath =>
      referencePath.isEmpty ? null : '$referencePath.sig';

  factory Certificate.fromJson(Map<String, Object?> jsonMap) => Certificate(
        name: jsonMap[KeysForCertificateJsonConverter.name] as String,
        sendtype: jsonMap[KeysForCertificateJsonConverter.sendtype] as int,
        description:
            jsonMap[KeysForCertificateJsonConverter.description] as String,
        referencePath:
            jsonMap[KeysForCertificateJsonConverter.referencePath] as String,
      );

  Map<String, dynamic> toJson() => {
        KeysForCertificateJsonConverter.name: name,
        KeysForCertificateJsonConverter.sendtype: sendtype,
        KeysForCertificateJsonConverter.description: description,
        KeysForCertificateJsonConverter.referencePath: referencePath,
      };
}

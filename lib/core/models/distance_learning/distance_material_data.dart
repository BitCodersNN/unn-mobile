abstract base class DistanceMaterialData {
  final String comment;
  final DateTime dateTime;

  DistanceMaterialData({
    required this.comment,
    required this.dateTime,
  });

  Map<String, Object?> toJson();
}

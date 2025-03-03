class KeysForSemesterJsonConverter {
  static const String semester = 'semester';
  static const String year = 'year';
}

class Semester {
  final int semester;
  final int year;

  Semester({
    required this.semester,
    required this.year,
  });

  factory Semester.fromJson(Map<String, Object?> jsonMap) => Semester(
        semester: int.parse(
          jsonMap[KeysForSemesterJsonConverter.semester] as String,
        ),
        year: int.parse(
          jsonMap[KeysForSemesterJsonConverter.year] as String,
        ),
      );

  Map<String, Object?> toJson() => {
        KeysForSemesterJsonConverter.semester: semester.toString(),
        KeysForSemesterJsonConverter.year: year.toString(),
      };
}

class SemesterJsonKeys {
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
          jsonMap[SemesterJsonKeys.semester] as String,
        ),
        year: int.parse(
          jsonMap[SemesterJsonKeys.year] as String,
        ),
      );

  Map<String, Object?> toJson() => {
        SemesterJsonKeys.semester: semester.toString(),
        SemesterJsonKeys.year: year.toString(),
      };
}

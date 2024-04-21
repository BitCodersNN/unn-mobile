class _AbbreviatedNamesOfSubjectTypes {
  static const String controlType = 'control_type';
  static const String date = 'date';
  static const String hours = 'hours';
  static const String lecturers = 'lecturers';
  static const String mark = 'mark';
  static const String subject = 'subject';
}

enum MarkType {
  notCredited,
  credited,
  notSatisfactory,
  satisfactory,
  good,
  veryGood,
  excellent,
  perfectly,
}

extension MarkTypeExtension on MarkType {
  double parseDouble() {
    switch (this) {
      case MarkType.notCredited:
        return 0;
      case MarkType.credited:
        return 1;
      case MarkType.notSatisfactory:
        return 2;
      case MarkType.satisfactory:
        return 3;
      case MarkType.good:
        return 4;
      case MarkType.veryGood:
        return 4.5;
      case MarkType.excellent:
        return 5;
      case MarkType.perfectly:
        return 5.5;
    }
  }

  String parseString() {
    switch (this) {
      case MarkType.notCredited:
        return 'не зачтено';
      case MarkType.credited:
        return 'зачтено';
      case MarkType.notSatisfactory:
        return 'не удовлетворительно';
      case MarkType.satisfactory:
        return 'удовлетворительно';
      case MarkType.good:
        return 'хорошо';
      case MarkType.veryGood:
        return 'очень хорошо';
      case MarkType.excellent:
        return 'отлично';
      case MarkType.perfectly:
        return 'превосходно';
    }
  }

  static MarkType fromDouble(double value) {
    switch (value) {
      case 0:
        return MarkType.notCredited;
      case 1:
        return MarkType.credited;
      case 2:
        return MarkType.notSatisfactory;
      case 3:
        return MarkType.satisfactory;
      case 4:
        return MarkType.good;
      case 4.5:
        return MarkType.veryGood;
      case 5:
        return MarkType.excellent;
      case 5.5:
        return MarkType.perfectly;
      default:
        throw Exception("Unknown value for Status enum");
    }
  }

  static MarkType fromString(String value) {
    switch (value) {
      case 'не зачтено':
        return MarkType.notCredited;
      case 'зачтено':
        return MarkType.credited;
      case 'не удовлетворительно':
        return MarkType.notSatisfactory;
      case 'удовлетворительно':
        return MarkType.satisfactory;
      case 'хорошо':
        return MarkType.good;
      case 'очень хорошо':
        return MarkType.veryGood;
      case 'отлично':
        return MarkType.excellent;
      case 'превосходно':
        return MarkType.perfectly;
      default:
        throw Exception("Unknown value for Status enum");
    }
  }
}

class MarkBySubject {
  final int _creditedHoursPerHour = 36;

  final String _controlType;
  final DateTime _date;
  final int _hours;
  final String _lecturers;
  final MarkType _markType;
  final String _subject;

  MarkBySubject({
    required String controlType,
    required DateTime date,
    required int hours,
    required String lecturers,
    required MarkType markType,
    required String subject,
  })  : _controlType = controlType,
        _date = date,
        _hours = hours,
        _lecturers = lecturers,
        _markType = markType,
        _subject = subject;

  DateTime get date => _date;
  int get hours => _hours;
  String get lecturers => _lecturers;
  MarkType get markType => _markType;
  String get controlType => _controlType;
  int get creditedHours => hours ~/ _creditedHoursPerHour;
  String get subject => _subject;

  factory MarkBySubject.fromJson(Map<String, Object?> jsonMap) {
    return MarkBySubject(
      controlType:
          jsonMap[_AbbreviatedNamesOfSubjectTypes.controlType] as String,
      date: DateTime.parse(
        jsonMap[_AbbreviatedNamesOfSubjectTypes.date] as String,
      ),
      hours: jsonMap[_AbbreviatedNamesOfSubjectTypes.hours] as int,
      lecturers: jsonMap[_AbbreviatedNamesOfSubjectTypes.lecturers] as String,
      markType: MarkTypeExtension.fromDouble(
        jsonMap[_AbbreviatedNamesOfSubjectTypes.mark] as double,
      ),
      subject: jsonMap[_AbbreviatedNamesOfSubjectTypes.subject] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      _AbbreviatedNamesOfSubjectTypes.controlType: controlType,
      _AbbreviatedNamesOfSubjectTypes.date: date.toIso8601String(),
      _AbbreviatedNamesOfSubjectTypes.hours: hours,
      _AbbreviatedNamesOfSubjectTypes.lecturers: lecturers,
      _AbbreviatedNamesOfSubjectTypes.mark: markType.parseDouble(),
      _AbbreviatedNamesOfSubjectTypes.subject: subject,
    };
  }
}

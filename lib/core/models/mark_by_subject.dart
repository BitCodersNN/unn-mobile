class _KeysForMarkBySubjectJsonConverter {
  static const String controlType = 'control_type';
  static const String date = 'date';
  static const String hours = 'hours';
  static const String lecturers = 'lecturers';
  static const String mark = 'mark';
  static const String subject = 'subject';
}

class _MarkTypeString {
  static const String notCredited = 'не зачтено';
  static const String credited = 'зачтено';
  static const String notSatisfactory = 'не удовлетворительно';
  static const String satisfactory = 'удовлетворительно';
  static const String good = 'хорошо';
  static const String veryGood = 'очень хорошо';
  static const String excellent = 'отлично';
  static const String perfect = 'превосходно';
}

class _MarkTypeDouble {
  static const double notCredited = 0;
  static const double credited = 1;
  static const double notSatisfactory = 2;
  static const double satisfactory = 3;
  static const double good = 4;
  static const double veryGood = 4.5;
  static const double excellent = 5;
  static const double perfect = 5.5;
}

enum MarkType {
  notCredited,
  credited,
  notSatisfactory,
  satisfactory,
  good,
  veryGood,
  excellent,
  perfect,
}

extension MarkTypeExtension on MarkType {
  double parseDouble() {
    switch (this) {
      case MarkType.notCredited:
        return _MarkTypeDouble.notCredited;
      case MarkType.credited:
        return _MarkTypeDouble.credited;
      case MarkType.notSatisfactory:
        return _MarkTypeDouble.notSatisfactory;
      case MarkType.satisfactory:
        return _MarkTypeDouble.satisfactory;
      case MarkType.good:
        return _MarkTypeDouble.good;
      case MarkType.veryGood:
        return _MarkTypeDouble.veryGood;
      case MarkType.excellent:
        return _MarkTypeDouble.excellent;
      case MarkType.perfect:
        return _MarkTypeDouble.perfect;
    }
  }

  String parseString() {
    switch (this) {
      case MarkType.notCredited:
        return _MarkTypeString.notCredited;
      case MarkType.credited:
        return _MarkTypeString.credited;
      case MarkType.notSatisfactory:
        return _MarkTypeString.notSatisfactory;
      case MarkType.satisfactory:
        return _MarkTypeString.satisfactory;
      case MarkType.good:
        return _MarkTypeString.good;
      case MarkType.veryGood:
        return _MarkTypeString.veryGood;
      case MarkType.excellent:
        return _MarkTypeString.excellent;
      case MarkType.perfect:
        return _MarkTypeString.perfect;
    }
  }

  static MarkType fromDouble(double value) {
    switch (value) {
      case _MarkTypeDouble.notCredited:
        return MarkType.notCredited;
      case _MarkTypeDouble.credited:
        return MarkType.credited;
      case _MarkTypeDouble.notSatisfactory:
        return MarkType.notSatisfactory;
      case _MarkTypeDouble.satisfactory:
        return MarkType.satisfactory;
      case _MarkTypeDouble.good:
        return MarkType.good;
      case _MarkTypeDouble.veryGood:
        return MarkType.veryGood;
      case _MarkTypeDouble.excellent:
        return MarkType.excellent;
      case _MarkTypeDouble.perfect:
        return MarkType.perfect;
      default:
        throw Exception('Unknown value for Status enum');
    }
  }

  static MarkType fromString(String value) {
    switch (value) {
      case _MarkTypeString.notCredited:
        return MarkType.notCredited;
      case _MarkTypeString.credited:
        return MarkType.credited;
      case _MarkTypeString.notSatisfactory:
        return MarkType.notSatisfactory;
      case _MarkTypeString.satisfactory:
        return MarkType.satisfactory;
      case _MarkTypeString.good:
        return MarkType.good;
      case _MarkTypeString.veryGood:
        return MarkType.veryGood;
      case _MarkTypeString.excellent:
        return MarkType.excellent;
      case _MarkTypeString.perfect:
        return MarkType.perfect;
      default:
        throw Exception('Unknown value for Status enum');
    }
  }
}

class MarkBySubject {
  final int _creditedHoursPerHour = 36;

  final String _controlType;
  final DateTime _date;
  final int _hours;
  final String? _lecturers;
  final MarkType _markType;
  final String _subject;

  MarkBySubject({
    required String controlType,
    required DateTime date,
    required int hours,
    required String? lecturers,
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
  String? get lecturers => _lecturers;
  MarkType get markType => _markType;
  String get controlType => _controlType;
  int get creditedHours => hours ~/ _creditedHoursPerHour;
  String get subject => _subject;

  factory MarkBySubject.fromJson(Map<String, Object?> jsonMap) {
    return MarkBySubject(
      controlType:
          jsonMap[_KeysForMarkBySubjectJsonConverter.controlType] as String,
      date: DateTime.parse(
        jsonMap[_KeysForMarkBySubjectJsonConverter.date] as String,
      ),
      hours: int.parse(
        jsonMap[_KeysForMarkBySubjectJsonConverter.hours] as String,
      ),
      lecturers:
          jsonMap[_KeysForMarkBySubjectJsonConverter.lecturers] as String?,
      markType: MarkTypeExtension.fromDouble(
        (jsonMap[_KeysForMarkBySubjectJsonConverter.mark] as dynamic)
            .toDouble(),
      ),
      subject: jsonMap[_KeysForMarkBySubjectJsonConverter.subject] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      _KeysForMarkBySubjectJsonConverter.controlType: controlType,
      _KeysForMarkBySubjectJsonConverter.date: date.toIso8601String(),
      _KeysForMarkBySubjectJsonConverter.hours: hours.toString(),
      _KeysForMarkBySubjectJsonConverter.lecturers: lecturers,
      _KeysForMarkBySubjectJsonConverter.mark: markType.parseDouble(),
      _KeysForMarkBySubjectJsonConverter.subject: subject,
    };
  }
}

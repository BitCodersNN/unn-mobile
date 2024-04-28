class _KeysForMarkBySubjectJsonConverter {
  static const String controlType = 'control_type';
  static const String date = 'date';
  static const String hours = 'hours';
  static const String lecturers = 'lecturers';
  static const String mark = 'mark';
  static const String subject = 'subject';
}

class _MarkTypeString {
  static const Map<MarkType, String> _map = {
    MarkType.notCredited: 'Не зачтено',
    MarkType.credited: 'Зачтено',
    MarkType.notSatisfactory: 'Неудовлетворительно',
    MarkType.satisfactory: 'Удовлетворительно',
    MarkType.good: 'Хорошо',
    MarkType.veryGood: 'Очень хорошо',
    MarkType.excellent: 'Отлично',
    MarkType.perfect: 'Превосходно',
  };

  static String parse(MarkType markType) => _map[markType]!;
  static MarkType fromString(String value) => _map.entries
      .firstWhere(
        (e) => e.value == value,
        orElse: () => throw Exception('Unknown value for MarkType enum'),
      )
      .key;
}

class _MarkTypeDouble {
  static const Map<MarkType, double> _map = {
    MarkType.notCredited: 0.0,
    MarkType.credited: 1.0,
    MarkType.notSatisfactory: 2.0,
    MarkType.satisfactory: 3.0,
    MarkType.good: 4.0,
    MarkType.veryGood: 4.5,
    MarkType.excellent: 5.0,
    MarkType.perfect: 5.5,
  };

  static double parse(MarkType markType) => _map[markType]!;
  static MarkType fromDouble(double value) => _map.entries
      .firstWhere(
        (e) => e.value == value,
        orElse: () => throw Exception('Unknown value for MarkType enum'),
      )
      .key;
}

enum MarkType {
  notCredited,
  credited,
  notSatisfactory,
  satisfactory,
  good,
  veryGood,
  excellent,
  perfect;

  factory MarkType.fromString(String value) =>
      _MarkTypeString.fromString(value);
  factory MarkType.fromDouble(double value) =>
      _MarkTypeDouble.fromDouble(value);
}

extension MarkTypeExtension on MarkType {
  double convertToDouble() => _MarkTypeDouble.parse(this);
  String convertToString() => _MarkTypeString.parse(this);
}

class MarkBySubject {
  final int _hoursPerCreditedHour = 36;

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
  int get creditedHours => hours ~/ _hoursPerCreditedHour;
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
      markType: MarkType.fromDouble(
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
      _KeysForMarkBySubjectJsonConverter.mark: markType.convertToString(),
      _KeysForMarkBySubjectJsonConverter.subject: subject,
    };
  }
}

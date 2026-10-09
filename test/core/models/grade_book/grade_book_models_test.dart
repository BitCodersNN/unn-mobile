import 'package:flutter_test/flutter_test.dart';
import 'package:unn_mobile/core/models/grade_book/grade_assessment.dart';
import 'package:unn_mobile/core/models/grade_book/grade_book_summary.dart';
import 'package:unn_mobile/core/models/grade_book/grade_distribution.dart';
import 'package:unn_mobile/core/models/grade_book/grade_semester.dart';
import 'package:unn_mobile/core/models/grade_book/grade_statistics.dart';
import 'package:unn_mobile/core/models/grade_book/mark_by_subject.dart';
import 'package:unn_mobile/core/models/grade_book/mark_type.dart';

void main() {
  test('All mark types preserve the API and cache JSON schema', () {
    for (final type in MarkType.values) {
      final json = <String, Object?>{
        'control_type': 'Экзамен',
        'date': '2026-01-12T00:00:00.000',
        'hours': '108',
        'lecturers': null,
        'mark': type.value == type.value.roundToDouble()
            ? type.value.toInt()
            : type.value,
        'subject': 'Математика',
      };
      final mark = MarkBySubject.fromJson(json);
      expect(mark.markType, type);
      expect(mark.creditedHours, 3);
      expect(mark.toJson(), json);
      expect(MarkType.fromString(type.label), type);
      expect(MarkType.fromDouble(type.value), type);
    }
  });

  test('Unknown numeric and textual marks report invalid data', () {
    expect(() => MarkType.fromDouble(6), throwsFormatException);
    expect(() => MarkType.fromString('Unknown'), throwsFormatException);
  });

  test('Control classification normalizes case and ё', () {
    final credit = _mark(MarkType.good, control: 'Дифференцированный ЗАЧЁТ');
    final missedCredit = _mark(MarkType.noShow, control: 'ЗАЧЁТ');
    final missedExam = _mark(MarkType.noShow, control: 'ЭКЗАМЕН');
    expect(credit.isCreditControl, isTrue);
    expect(credit.averageValue, isNull);
    expect(credit.resultGroup, GradeResultGroup.grades);
    expect(missedCredit.resultGroup, GradeResultGroup.credits);
    expect(missedExam.resultGroup, GradeResultGroup.grades);
    expect(missedExam.isExam, isTrue);
  });

  test('Only failed, not credited and missed results require retakes', () {
    final marks = MarkType.values.map(_mark).toList();
    final statistics = GradeStatistics.fromMarks(marks);
    expect(statistics.subjectCount, 9);
    expect(statistics.examCount, 9);
    expect(statistics.retakeCount, 3);
    expect(
      marks.where((mark) => mark.requiresRetake).map((mark) => mark.markType),
      [MarkType.noShow, MarkType.notCredited, MarkType.notSatisfactory],
    );
  });

  test('The average excludes credits and absent results', () {
    final statistics = GradeStatistics.fromMarks([
      _mark(MarkType.excellent),
      _mark(MarkType.satisfactory),
      _mark(MarkType.notSatisfactory),
      _mark(MarkType.credited, control: 'Зачет'),
      _mark(MarkType.notCredited, control: 'Зачет'),
      _mark(MarkType.good, control: 'Дифференцированный зачет'),
      _mark(MarkType.noShow),
    ]);
    expect(statistics.average, 3.33);
  });

  test('Fractional averages round mathematical ties up', () {
    final statistics = GradeStatistics.fromMarks([
      _mark(MarkType.good),
      _mark(MarkType.good),
      _mark(MarkType.good),
      _mark(MarkType.veryGood),
    ]);
    expect(statistics.average, 4.13);
  });

  test('Combined averages use mark counts instead of semester averages', () {
    final summary = GradeBookSummary.fromGradeBook({
      1: [_mark(MarkType.excellent)],
      2: List.generate(3, (_) => _mark(MarkType.notSatisfactory)),
    });
    expect(summary.overall.average, 2.75);
    expect(summary.overall.subjectCount, 4);
    expect(summary.overall.retakeCount, 3);
  });

  test('Combining statistics preserves precision across repeated merges', () {
    final first = GradeStatistics.fromMarks([
      _mark(MarkType.good),
      _mark(MarkType.good),
      _mark(MarkType.excellent),
    ]);
    final second = GradeStatistics.fromMarks([_mark(MarkType.veryGood)]);
    final combined = GradeStatistics.combine([first, second]);
    expect(first.average, 4.33);
    expect(combined.average, 4.38);
    expect(
      GradeStatistics.combine([
        combined,
        GradeStatistics.fromMarks([_mark(MarkType.good)]),
      ]).average,
      4.3,
    );
  });

  test('Average comparison uses the displayed averages', () {
    final current = GradeStatistics.fromMarks([_mark(MarkType.excellent)]);
    final reference = GradeStatistics.fromMarks([_mark(MarkType.good)]);
    expect(current.averageDifferenceFrom(reference), 25);
    expect(reference.averageDifferenceFrom(current), -20);
  });

  test('Empty and credit-only collections have no average', () {
    final empty = GradeBookSummary.fromGradeBook({});
    final credit = GradeStatistics.fromMarks([_mark(MarkType.credited)]);
    expect(empty.semesters, isEmpty);
    expect(empty.overall.subjectCount, 0);
    expect(empty.overall.distribution.entries, isEmpty);
    expect(empty.overall.average, isNull);
    expect(credit.average, isNull);
    expect(credit.averageDifferenceFrom(empty.overall), isNull);
    expect(empty.overall.averageDifferenceFrom(credit), isNull);
  });

  test('Distribution percentages are independent for grades and credits', () {
    final distribution = GradeDistribution.fromMarks([
      _mark(MarkType.excellent),
      _mark(MarkType.excellent),
      _mark(MarkType.noShow),
      _mark(MarkType.credited, control: 'Зачет'),
      _mark(MarkType.noShow, control: 'Зачет'),
    ]);
    final missed = distribution.entries
        .where((entry) => entry.type == MarkType.noShow)
        .toList();
    expect(distribution.counts[MarkType.noShow], 2);
    expect(missed.map((entry) => entry.group), GradeResultGroup.values);
    expect(missed.first.percentage, closeTo(100 / 3, 0.0001));
    expect(missed.last.percentage, 50);
  });

  test('Distribution merging recalculates totals within each group', () {
    final combined = GradeDistribution.combine([
      GradeDistribution.fromMarks([
        _mark(MarkType.excellent),
        _mark(MarkType.credited),
      ]),
      GradeDistribution.fromMarks([
        _mark(MarkType.excellent),
        _mark(MarkType.good),
        _mark(MarkType.notCredited),
      ]),
    ]);
    final excellent = combined.entries
        .singleWhere((entry) => entry.type == MarkType.excellent);
    final credit = combined.entries
        .singleWhere((entry) => entry.type == MarkType.credited);
    expect(excellent.count, 2);
    expect(excellent.total, 3);
    expect(credit.percentage, 50);
    expect(combined.counts.values.fold(0, (sum, count) => sum + count), 5);
  });

  test('Semester consumes its input once and consistently orders equal dates',
      () {
    final first = _mark(MarkType.good, day: 2);
    final second = _mark(MarkType.excellent, day: 1);
    final third = _mark(MarkType.noShow, day: 1);
    final semester = GradeSemester(
      number: 1,
      marks: _SinglePassIterable([first, second, third]),
    );
    expect(semester.marks, [second, third, first]);
    expect(semester.statistics.average, 4.5);
    expect(semester.exams, semester.marks);
    expect(semester.retakes, [third]);
  });

  test('Statistics and combining consume external iterables only once', () {
    final first = GradeStatistics.fromMarks(
      _SinglePassIterable([_mark(MarkType.good)]),
    );
    final combined = GradeStatistics.combine(_SinglePassIterable([first]));
    expect(combined.average, 4);
    expect(combined.subjectCount, 1);
  });

  test('Summary snapshots are immutable and do not mutate source data', () {
    final later = _mark(MarkType.good, day: 2);
    final earlier = _mark(MarkType.excellent, day: 1);
    final marks = [later, earlier];
    final source = <int, List<MarkBySubject>>{2: marks, 1: []};
    final summary = GradeBookSummary.fromGradeBook(source);
    expect(summary.semesters.map((semester) => semester.number), [1, 2]);
    expect(marks, [later, earlier]);
    marks.clear();
    source.clear();
    expect(summary.semesters.last.marks, [earlier, later]);
    expect(summary.overall.subjectCount, 2);
    expect(summary.semesters.clear, throwsUnsupportedError);
    expect(() => summary.semesters.last.marks.clear(), throwsUnsupportedError);
    expect(
      summary.overall.distribution.counts.clear,
      throwsUnsupportedError,
    );
    expect(
      summary.overall.distribution.entries.clear,
      throwsUnsupportedError,
    );
  });
}

MarkBySubject _mark(
  MarkType type, {
  String control = 'Экзамен',
  int day = 1,
}) =>
    MarkBySubject(
      controlType: control,
      date: DateTime(2026, 1, day),
      hours: 108,
      lecturers: null,
      markType: type,
      subject: 'Предмет',
    );

class _SinglePassIterable<T> extends Iterable<T> {
  final Iterable<T> _items;
  bool _consumed = false;

  _SinglePassIterable(this._items);

  @override
  Iterator<T> get iterator {
    if (_consumed) {
      throw StateError('The input has already been consumed');
    }
    _consumed = true;
    return _items.iterator;
  }
}

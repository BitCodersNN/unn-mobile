// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

enum MarkType {
  noShow(-1, 'Неявка'),
  notCredited(0, 'Не зачтено'),
  credited(1, 'Зачтено'),
  notSatisfactory(2, 'Неудовлетворительно'),
  satisfactory(3, 'Удовлетворительно'),
  good(4, 'Хорошо'),
  veryGood(4.5, 'Очень хорошо'),
  excellent(5, 'Отлично'),
  perfect(5.5, 'Превосходно');

  final double value;
  final String label;

  const MarkType(this.value, this.label);

  factory MarkType.fromString(String label) => values.firstWhere(
        (type) => type.label == label,
        orElse: () => throw FormatException('Unknown mark label', label),
      );

  factory MarkType.fromDouble(double value) => values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown mark value', value),
      );

  bool get isNumeric => switch (this) {
        noShow || notCredited || credited => false,
        _ => true,
      };

  bool get isCredit => this == credited || this == notCredited;

  bool get requiresRetake => switch (this) {
        noShow || notCredited || notSatisfactory => true,
        _ => false,
      };
}

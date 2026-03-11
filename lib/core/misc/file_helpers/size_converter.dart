// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:math';

enum SizeUnit {
  byte,
  kilobyte,
  megabyte,
  gigabyte,
}

extension UnitNames on SizeUnit {
  String getUnitStringRu() {
    switch (this) {
      case SizeUnit.byte:
        return 'Б';
      case SizeUnit.kilobyte:
        return 'КБ';
      case SizeUnit.megabyte:
        return 'МБ';
      case SizeUnit.gigabyte:
        return 'ГБ';
    }
  }

  String getUnitStringEn() {
    switch (this) {
      case SizeUnit.byte:
        return 'B';
      case SizeUnit.kilobyte:
        return 'KB';
      case SizeUnit.megabyte:
        return 'MB';
      case SizeUnit.gigabyte:
        return 'GB';
    }
  }

  List<String> getAllUnitVariants() => [getUnitStringRu(), getUnitStringEn()];
}

class SizeConverter {
  static const int _base = 10;
  static final String _allUnits =
      SizeUnit.values.expand((unit) => unit.getAllUnitVariants()).join('|');
  static final Map<SizeUnit?, num> _coefficients = {
    SizeUnit.byte: pow(_base, 0),
    SizeUnit.kilobyte: pow(_base, 3),
    SizeUnit.megabyte: pow(_base, 6),
    SizeUnit.gigabyte: pow(_base, 9),
    null: pow(_base, 3),
  };
  SizeUnit? _lastUsedUnit;

  /// Возвращает единицы измерения, используемые в последней операции
  SizeUnit? get lastUsedUnit => _lastUsedUnit;

  /// Парсит строку с размером файла (например, "1.5 ГБ", "100 КБ", "2.3 TB")
  /// и возвращает размер в байтах.
  ///
  /// Поддерживает русские (Б, КБ, МБ, ГБ) и латинские (B, KB, MB, GB) обозначения,
  /// а также запятую или точку в качестве десятичного разделителя.
  static int parseFileSize(String sizeText) {
    final pattern = '([\\d.,]+)\\s*($_allUnits)';

    final regex = RegExp(
      pattern,
      caseSensitive: false,
    );

    final match = regex.firstMatch(sizeText);
    if (match == null) {
      return 0;
    }

    final value =
        double.tryParse(match.group(1)?.replaceAll(',', '.') ?? '0') ?? 0;

    final unit = match.group(2)?.toUpperCase() ?? 'Б';

    for (final sizeUnit in SizeUnit.values) {
      if (sizeUnit.getAllUnitVariants().any(
            (u) => u.toUpperCase() == unit,
          )) {
        return (value * _coefficients[sizeUnit]!).toInt();
      }
    }

    return value.toInt();
  }

  /// Преобразует байты в указанные единицы измерения или в наибольшие единицы, в которых целая часть числа не равна 0.
  ///
  /// [bytes] - кол-во байтов
  /// [unit] - требуемая единица измерения. Если не указано, то преобразование будет произведено в максимально возможное значение, но при этом часть целого числа не будет равна 0.
  ///
  /// Возвращает новый размер и сохраняет единицу измерения в [lastUsedUnit]
  double convertBytesToSize(int bytes, [SizeUnit? unit]) {
    double size = bytes.toDouble();

    switch (unit) {
      case null:
        size = _convertBitsToUnknownSize(size);
      default:
        size /= _coefficients[unit]!.toInt();
        _lastUsedUnit = unit;
    }

    return size;
  }

  double _convertBitsToUnknownSize(double size) {
    int counter = 0;
    while (size > _coefficients[null]!.toInt()) {
      counter++;
      size /= _coefficients[null]!.toInt();
    }
    switch (counter) {
      case 0:
        _lastUsedUnit = SizeUnit.byte;
      case 1:
        _lastUsedUnit = SizeUnit.kilobyte;
      case 2:
        _lastUsedUnit = SizeUnit.megabyte;
      case 3:
        _lastUsedUnit = SizeUnit.gigabyte;
    }
    return size;
  }
}

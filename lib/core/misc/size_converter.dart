import 'dart:math';

enum SizeUnit {
  byte,
  kilobyte,
  megabyte,
  gigabyte,
}

class SizeConverter {
  final int _base = 10;
  final Map<SizeUnit?, int> _exponents = {
    SizeUnit.byte: 0,
    SizeUnit.kilobyte: 3,
    SizeUnit.megabyte: 6,
    SizeUnit.gigabyte: 9,
    null: 3,
  };
  SizeUnit? _lastUsedUnit;
  /// Возвращает единицы измерения, используемые в последней операции
  SizeUnit? get lastUsedUnit => _lastUsedUnit;
  
  /// Преобразует байты в указанные единицы измерения или в наибольшие единицы, в которых целая часть числа не равна 0.
  /// 
  /// [bytes] - кол-во байтов
  /// [unit] - требуемая единица измерения. Если не указано, то преобразование будет произведено в максимально возможное значение, но при этом часть целого числа не будет равна 0.
  /// 
  /// Возвращает новый размер и сохраняет единицу измерения в [lastUsedUnit]
  double convertBitsToSize(int bytes, [SizeUnit? unit]) {
    double size = bytes.toDouble();

    switch (unit) {
      case null:
        size = _convertBitsToUnknownSize(size);
      default:
        size /= pow(_base, _exponents[unit]!);
        _lastUsedUnit = unit;
    }

    return size;
  }

  double _convertBitsToUnknownSize(double size) {
    int counter = 0;
    while (size > pow(_base, _exponents[null]!)) {
      counter++;
      size /= pow(_base, _exponents[null]!);
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

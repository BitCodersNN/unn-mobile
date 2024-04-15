import 'dart:math';

enum SizeUnit {
  byte,
  kilobyte,
  megabyte,
  gigabyte,
}

class SizeConverter {
  static const int _base = 10;
  final Map<SizeUnit?, num> _coefficients = {
    SizeUnit.byte: pow(_base, 0),
    SizeUnit.kilobyte: pow(_base, 3),
    SizeUnit.megabyte: pow(_base, 6),
    SizeUnit.gigabyte: pow(_base, 9),
    null: pow(_base, 3),
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

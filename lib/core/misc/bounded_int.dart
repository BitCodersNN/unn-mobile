class BoundedInt {
  final int _value;
  final int _min;
  final int _max;

  /// Создаёт экземпляр с проверкой, что [value] находится в диапазоне [min]..[max].
  /// [paramName] — имя параметра для сообщения об ошибке (по умолчанию 'value').
  /// [errorMessage] — кастомное сообщение об ошибке (если null — будет сгенерировано автоматически).
  BoundedInt({
    required int value,
    required int min,
    required int max,
    String paramName = 'value',
    String? errorMessage,
  })  : _min = min,
        _max = max,
        _value = _validate(
          value,
          min,
          max,
          paramName,
          errorMessage ?? 'Должно быть от $min до $max',
        );

  static int _validate(
    int value,
    int min,
    int max,
    String paramName,
    String errorMessage,
  ) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, paramName, errorMessage);
    }
    return value;
  }

  int get value => _value;

  int get min => _min;
  int get max => _max;

  @override
  String toString() => 'BoundedInt($value)';

  @override
  bool operator ==(Object other) =>
      other is BoundedInt &&
      other.value == value &&
      other.min == min &&
      other.max == max;

  @override
  int get hashCode => Object.hash(value, min, max);
}

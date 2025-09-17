// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class BoundedInt {
  final int value;
  final int min;
  final int max;

  /// Создаёт экземпляр с проверкой, что [value] находится в диапазоне [min]..[max].
  /// [paramName] — имя параметра для сообщения об ошибке (по умолчанию 'value').
  /// [errorMessage] — кастомное сообщение об ошибке (если null — будет сгенерировано автоматически).
  BoundedInt({
    required int value,
    required this.min,
    required this.max,
    String paramName = 'value',
    String? errorMessage,
  })  : value = _validate(
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
}

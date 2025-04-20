T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere(
    (element) => element.toString().split('.').last == value,
    orElse: () => throw ArgumentError('Неверное значение: $value'),
  );
}

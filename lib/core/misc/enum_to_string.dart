// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere(
    (element) => element.toString().split('.').last == value,
    orElse: () => throw ArgumentError('Неверное значение: $value'),
  );
}

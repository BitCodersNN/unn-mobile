// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class ResponseTypeException implements Exception {
  final String message;
  final Type expectedType;
  final Type actualType;
  final dynamic responseData;

  ResponseTypeException({
    required this.expectedType,
    required this.actualType,
    this.message = 'Invalid response type',
    this.responseData,
  });

  @override
  String toString() =>
      '$message: expected $expectedType, got $actualType, $responseData';
}

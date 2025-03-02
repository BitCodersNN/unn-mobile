class ResponseTypeError implements Exception {
  final String message;
  final Type expectedType;
  final Type actualType;
  final dynamic responseData;

  ResponseTypeError({
    required this.expectedType,
    required this.actualType,
    this.message = 'Invalid response type',
    this.responseData,
  });

  @override
  String toString() =>
      '$message: expected $expectedType, got $actualType, $responseData';
}

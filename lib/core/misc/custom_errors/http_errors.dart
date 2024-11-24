class RequestException implements Exception {
  final String cause;

  RequestException(this.cause);
}

class TimeoutException extends RequestException {
  TimeoutException(super.cause);
}

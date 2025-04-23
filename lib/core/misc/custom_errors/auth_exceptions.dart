// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class SessionCookieException implements Exception {
  final String message;
  final Map<String, String>? privateInformation;

  SessionCookieException({required this.message, this.privateInformation});

  @override
  String toString() {
    return 'SessionCookieException: message: $message';
  }
}

class CsrfValueException implements Exception {
  final String message;

  final Map<String, String>? privateInformation;

  CsrfValueException({required this.message, this.privateInformation});

  @override
  String toString() {
    return 'SessionCookieException: message: $message';
  }
}

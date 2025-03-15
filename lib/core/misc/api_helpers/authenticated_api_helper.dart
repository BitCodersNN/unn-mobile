import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_service.dart';

abstract class AuthenticatedApiHelper extends ApiHelper {
  String? get sessionId => authorizationService.sessionId;

  @protected
  final AuthorisationService authorizationService;

  AuthenticatedApiHelper(
    this.authorizationService, {
    required super.options,
  }) {
    authorizationService.addListener(onAuthChanged);
  }

  @protected
  void onAuthChanged() {
    final currentHeaders = authorizationService.headers;
    if (currentHeaders == null) {
      return;
    }
    updateHeaders(currentHeaders);
  }
}

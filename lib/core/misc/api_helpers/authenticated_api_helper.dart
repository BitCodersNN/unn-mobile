import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';

abstract class AuthenticatedApiHelper extends ApiHelper {
  final AuthorizationService _authorizationService;

  AuthenticatedApiHelper(
    this._authorizationService, {
    required super.options,
  }) {
    _authorizationService.addListener(_updateHeaders);
  }

  void _updateHeaders() {
    final currentHeaders = _authorizationService.headers;
    if (currentHeaders == null) {
      return;
    }
    updateHeaders(currentHeaders);
  }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_event.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _ResponseDataJsonKeys {
  static const String status = 'status';
  static const String errors = 'errors';
  static const String error = 'error';
}

class ResponseStatusValidator {
  static bool validate(JsonMap responseData, LoggerService loggerService) {
    final status = responseData[_ResponseDataJsonKeys.status];

    if (status == _ResponseDataJsonKeys.error) {
      loggerService.log(
        DiagnosticEvent.serverRejectedRequest,
        information: [responseData[_ResponseDataJsonKeys.errors]],
      );
      return false;
    }

    return true;
  }
}

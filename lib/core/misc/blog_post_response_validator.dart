import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class _ResponseDataJsonKeys {
  static const String status = 'status';
  static const String errors = 'errors';
  static const String error = 'error';
  static const String message = 'message';
}

class FeedResponseValidator {
  static bool validate(
    Map<String, dynamic> responseData,
    LoggerService loggerService,
  ) {
    final status = responseData[_ResponseDataJsonKeys.status];

    if (status == _ResponseDataJsonKeys.error) {
      final error = responseData[_ResponseDataJsonKeys.errors][0];
      final errorMessage = error[_ResponseDataJsonKeys.message];
      loggerService.log(errorMessage);
      return false;
    }

    return true;
  }
}

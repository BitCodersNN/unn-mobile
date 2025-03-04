import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/authorisation/authorisation_request_result.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:dartz/dartz.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class AuthorisationHelper {
  final OnlineStatusData _onlineStatus;
  final ApiHelper _apiHelper;
  final LoggerService _loggerService;
  final String _pathOfEndpoint;

  AuthorisationHelper(
    this._onlineStatus,
    this._apiHelper,
    this._loggerService,
    this._pathOfEndpoint,
  );

  Future<Either<AuthRequestResult, Response>> auth(
    Map<String, dynamic> formData, {
    List<int> additionalGoodStatusCodes = const [],
  }) async {
    if (await _isOffline()) {
      return Left(await _getOfflineResult());
    }

    try {
      return Right(
        await _apiHelper.post(
          path: _pathOfEndpoint,
          data: formData,
          options: Options(
            validateStatus: (status) {
              return (status != null && status >= 200 && status < 300) ||
                  additionalGoodStatusCodes.contains(status);
            },
          ),
        ),
      );
    } on DioException catch (exception) {
      switch (exception.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return Left(await _getOfflineResult());
        case DioExceptionType.badCertificate:
        case DioExceptionType.cancel:
        case DioExceptionType.unknown:
          _loggerService.logError(
            exception.error,
            exception.stackTrace,
          );
          return const Left(AuthRequestResult.unknown);
        case DioExceptionType.badResponse:
          if (exception.response!.statusCode == 401) {
            return const Left(AuthRequestResult.wrongCredentials);
          }
          return const Left(AuthRequestResult.unknown);
      }
    }
  }

  Future<AuthRequestResult> _getOfflineResult() async {
    _onlineStatus.isOnline = false;
    return AuthRequestResult.noInternet;
  }

  Future<bool> _isOffline() async {
    return (await Connectivity().checkConnectivity())
        .contains(ConnectivityResult.none);
  }
}

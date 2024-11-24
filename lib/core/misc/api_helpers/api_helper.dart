import 'package:dio/dio.dart';

abstract interface class ApiHelper {
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<String> responseToStringBody(Response response);

  void updateOptions(BaseOptions newOptions);
}

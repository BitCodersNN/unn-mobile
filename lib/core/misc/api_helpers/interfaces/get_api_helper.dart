import 'package:dio/dio.dart';

abstract interface class GetApiHelper {
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
}

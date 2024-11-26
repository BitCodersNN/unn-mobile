import 'package:dio/dio.dart';

abstract interface class PostApiHelper {
  Future<Response> post({
    required String path,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
}

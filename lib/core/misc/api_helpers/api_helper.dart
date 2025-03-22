import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/api_options_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/get_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/post_api_helper.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_type_interceptor.dart';

class ApiHelper implements GetApiHelper, PostApiHelper, ApiOptionsHelper {
  @protected
  final Dio dio;

  ApiHelper({
    required BaseOptions options,
    List<Interceptor> interceptors = const [],
  }) : dio = Dio(options) {
    if (interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }
    dio.interceptors.add(ResponseTypeInterceptor());
  }

  @override
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response> post({
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  void updateOptions(BaseOptions newOptions) {
    dio.options = newOptions;
  }

  @override
  void updateHeaders(Map<String, dynamic> newHeaders) {
    dio.options.headers.addAll(newHeaders);
  }
}

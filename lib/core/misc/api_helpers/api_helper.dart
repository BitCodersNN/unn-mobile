import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/api_options_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/get_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/post_api_helper.dart';

class ApiHelper implements GetApiHelper, PostApiHelper, ApiOptionsHelper {
  @protected
  final Dio dio;

  ApiHelper({
    required BaseOptions options,
  }) : dio = Dio(options);

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

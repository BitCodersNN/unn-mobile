import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/api_options_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/get_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/interfaces/post_api_helper.dart';

class BaseApiHelper implements GetApiHelper, PostApiHelper, ApiOptionsHelper {
  final Dio _dio;

  BaseApiHelper({
    required BaseOptions options,
  }) : _dio = Dio(options);

  @override
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  void updateOptions(BaseOptions newOptions) {
    _dio.options = newOptions;
  }

  @override
  void updateHeaders(Map<String, dynamic> newHeaders) {
    _dio.options.headers.addAll(newHeaders);
  }
}

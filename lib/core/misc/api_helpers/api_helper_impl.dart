import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';

class ApiHelperImpl implements ApiHelper {
  final Dio _dio;

  ApiHelperImpl({
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
  Future<String> responseToStringBody(Response response) async {
    if (response.data is String) {
      return response.data.trim();
    } else {
      return response.data.toString().trim();
    }
  }

  @override
  void updateOptions(BaseOptions newOptions) {
    _dio.options = newOptions;
  }
}

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api_url_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/misc/api_helpers/http_methods.dart';

class WebAuthenticatedApiHelper extends AuthenticatedApiHelper {
  final String _baseUrl;

  WebAuthenticatedApiHelper({
    required baseUrl,
    required authorizationService,
  })  : _baseUrl = baseUrl,
        super(
          authorizationService,
          options: createBaseOptions(
            baseUrl: ApiPaths.redirectUrl,
            headers: authorizationService.headers,
          ),
        );

  @override
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _request(
      httpMethod: HttpMethod.get,
      path: path,
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
    return await _request(
      httpMethod: HttpMethod.post,
      path: path,
      body: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> _request({
    required HttpMethod httpMethod,
    required String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _baseUrl;
    throw UnimplementedError();
  }
}

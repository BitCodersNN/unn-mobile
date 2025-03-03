import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/api/host_with_base_path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/constants/regular_expressions.dart';
import 'package:unn_mobile/core/constants/session_identifier_strings.dart';
import 'package:unn_mobile/core/misc/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/misc/api_helpers/http_methods.dart';

class _HttpHeaders {
  static const String cookieKey = 'Cookie';
  static const String myUrlKey = 'MYURL';
  static const String myMethodKey = 'MYMETHOD';
  static const String myContentTypeKey = 'MYCONTENTTYPE';
  static const String myCookieKey = 'MYCOOKIE';
  static const String myCsrfKey = 'MYCSRF';
  static const String myParamsKey = 'MYPARAMS';
}

abstract class WebAuthenticatedApiHelper extends AuthenticatedApiHelper {
  final String _baseUrl;
  String? _dioCookie;

  WebAuthenticatedApiHelper({
    required host,
    required authorizationService,
    ProtocolType protocol = ProtocolType.https,
  })  : _baseUrl = '${protocol.name}://$host/',
        super(
          authorizationService,
          options: createBaseOptions(
            host: HostWithBasePath.redirect,
          ),
        ) {
    onAuthChanged();
  }

  @override
  @protected
  void onAuthChanged() {
    final currentHeaders = authorizationService.headers;
    _dioCookie = currentHeaders?.remove(_HttpHeaders.cookieKey);
    if (currentHeaders == null) {
      return;
    }
    updateHeaders(currentHeaders);
  }

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
    final response = await super.post(
      path: '',
      data: _buildRequestData(
        httpMethod,
        path,
        body,
        queryParameters,
        options,
      ),
      options: options,
    );

    try {
      response.data = jsonDecode(response.data);
    } catch (_) {
      // Если не удалось декодировать JSON, оставляем response.data без изменений
    }

    return response;
  }

  String _buildCookieString(Options? options) {
    final optionsCookie = options?.headers?.remove('Cookie');
    final cookieString = StringBuffer()
      ..write(_dioCookie ?? '')
      ..write(';')
      ..write(optionsCookie ?? '');
    return cookieString.toString().replaceAll(
          RegularExpressions.cookieCleanupRegExp,
          '',
        );
  }

  Map<String, String> _buildRequestData(
    HttpMethod httpMethod,
    String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  ) {
    final cleanedCookieString = _buildCookieString(options);
    final contentType = options?.contentType ?? dio.options.contentType;
    final csrf = dio.options.headers[SessionIdentifierStrings.csrfToken] ?? '';
    final myParams = jsonEncode({...?body, ...?queryParameters});

    return {
      _HttpHeaders.myUrlKey: '$_baseUrl$path',
      _HttpHeaders.myMethodKey: httpMethod.asString,
      _HttpHeaders.myContentTypeKey: contentType!,
      _HttpHeaders.myCookieKey: cleanedCookieString,
      _HttpHeaders.myCsrfKey: csrf,
      _HttpHeaders.myParamsKey: myParams,
    };
  }
}

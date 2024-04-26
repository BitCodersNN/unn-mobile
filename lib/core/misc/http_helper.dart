import 'dart:convert';
import 'dart:io';

import 'package:unn_mobile/core/constants/string_for_api.dart';

class HttpRequestSender {
  static const maxTimeout = 4;
  final String _path;
  final String _host;
  final Map<String, dynamic> _queryParams;
  final bool _useSSL;

  final Map<String, String> _headers;
  final Map<String, String> _cookies;

  HttpRequestSender({
    bool useSSL = true,
    String host = ApiPaths.host,
    required String path,
    Map<String, dynamic> queryParams = const {},
    Map<String, String> headers = const {},
    Map<String, String> cookies = const {},
  })  : _cookies = cookies,
        _headers = headers,
        _useSSL = useSSL,
        _queryParams = queryParams,
        _host = host,
        _path = path;

  /// Конвертирует http ответ в строку
  ///
  /// [response]: результат запроса
  ///
  /// Возращает строку
  static Future<String> responseToStringBody(
    HttpClientResponse response,
  ) async {
    return await response.transform(utf8.decoder).join();
  }

  /// Отправляет post запрос на сервер unn-portal
  ///
  /// Throws [TimeoutException], если превышено время выполнения запроса
  /// Throws [Exception], если произошла неизвестная ошибка
  ///
  /// [body]: тело запроса
  /// [timeoutSeconds]: время ожидания
  ///
  /// Возращает результат запроса
  Future<HttpClientResponse> postForm(
    Map<String, dynamic> body, {
    int timeoutSeconds = maxTimeout,
  }) async {
    final request =
        await _prepareHttpClientRequest(_HttpMethod.post, timeoutSeconds);

    request.headers.add('Content-Type', 'application/x-www-form-urlencoded');

    //add body
    request.add(
      utf8.encode(
        Uri(queryParameters: body)
            .query, //it means that [k1=v1&k2=v2&...&kn=vn] encoded to unicode
      ),
    );

    //fetch response
    return await request.closeWithTimeout(timeoutSeconds);
  }

  /// Отправляет get запрос на сервер unn-portal
  ///
  /// Throws [TimeoutException], если превышено время выполнения запроса
  /// Throws [Exception], если произошла неизвестная ошибка
  ///
  /// [timeoutSeconds]: время ожидания
  ///
  /// Возращает результат запроса
  Future<HttpClientResponse> get({int timeoutSeconds = maxTimeout}) async {
    final request =
        await _prepareHttpClientRequest(_HttpMethod.get, timeoutSeconds);

    return await request.close();
  }

  Future<HttpClientRequest> _prepareHttpClientRequest(
    _HttpMethod method,
    int timeoutSeconds,
  ) async {
    final httpClient = HttpClient();

    final request = await httpClient.openUrl(method.name, _createURI()).timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () => throw TimeoutException('Open url timed out'),
        );

    _headers.forEach((key, value) {
      request.headers.add(key, value);
    });

    _cookies.forEach((key, value) {
      request.cookies.add(Cookie(key, value));
    });

    return request;
  }

  Uri _createURI() {
    return Uri.parse("${_useSSL ? "https" : "http"}://$_host/$_path")
        .replace(queryParameters: _queryParams);
  }
}

extension on HttpClientRequest {
  Future<HttpClientResponse> closeWithTimeout(int timeoutSeconds) async {
    return await close().timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () => throw TimeoutException('close request timed out'),
    );
  }
}

enum _HttpMethod {
  get,
  post,
}

class RequestException implements Exception {
  final String cause;

  RequestException(this.cause);
}

class TimeoutException extends RequestException {
  TimeoutException(super.cause);
}

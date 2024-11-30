import 'package:dio/dio.dart';

BaseOptions createBaseOptions({
  required String baseUrl,
  bool useSSL = true,
  String contentType = Headers.formUrlEncodedContentType,
  Duration sendTimeout = const Duration(seconds: 15),
  Duration receiveTimeout = const Duration(seconds: 15),
  Map<String, dynamic>? headers,
}) {
  return BaseOptions(
    baseUrl: '${useSSL ? "https" : "http"}://$baseUrl/',
    contentType: contentType,
    sendTimeout: sendTimeout,
    receiveTimeout: receiveTimeout,
    headers: headers,
  );
}

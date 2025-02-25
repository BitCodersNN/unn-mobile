import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

BaseOptions createBaseOptions({
  required String host,
  ProtocolType protocol = ProtocolType.https,
  String contentType = Headers.formUrlEncodedContentType,
  Duration sendTimeout = const Duration(seconds: 15),
  Duration receiveTimeout = const Duration(seconds: 15),
  Map<String, dynamic>? headers,
}) {
  return BaseOptions(
    baseUrl: '${protocol.name}://$host/',
    contentType: contentType,
    sendTimeout: sendTimeout,
    receiveTimeout: receiveTimeout,
    headers: headers,
  );
}

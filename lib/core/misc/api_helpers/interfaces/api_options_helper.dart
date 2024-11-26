import 'package:dio/dio.dart';

abstract interface class ApiOptionsHelper {
  void updateOptions(BaseOptions newOptions);
  void updateHeaders(Map<String, dynamic> newHeaders);
}

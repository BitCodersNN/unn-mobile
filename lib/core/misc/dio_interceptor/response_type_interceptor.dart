// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/custom_errors/response_type_exception.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';

class ResponseTypeInterceptorKey {
  static String expectedType = 'expectedType';
}

void _checkType<T>(dynamic data) {
  if (data is! T) {
    throw ResponseTypeException(
      expectedType: T,
      actualType: data.runtimeType,
      responseData: data,
    );
  }
}

final Map<ResponseDataType, Function(dynamic)> _typeCheckers = {
  ResponseDataType.jsonMap: _checkType<Map<String, dynamic>>,
  ResponseDataType.list: _checkType<List>,
  ResponseDataType.string: _checkType<String>,
};

class ResponseTypeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final expectedType = response.requestOptions
        .extra[ResponseTypeInterceptorKey.expectedType] as ResponseDataType?;
    final checker = _typeCheckers[expectedType];

    if (checker == null) {
      super.onResponse(response, handler);
      return;
    }

    if (jsonParsableTypes.contains(expectedType) && response.data is String) {
      response.data = jsonDecode(response.data);
    }

    checker(response.data);

    super.onResponse(response, handler);
  }
}

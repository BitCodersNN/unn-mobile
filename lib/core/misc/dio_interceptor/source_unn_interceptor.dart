// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';

class SourceUnnInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is String && data.startsWith(')]}\',')) {
      response.data = data.substring(6);
    }

    super.onResponse(response, handler);
  }
}

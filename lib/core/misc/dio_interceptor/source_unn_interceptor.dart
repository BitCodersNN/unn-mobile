// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';

class SourceUnnInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String && response.data.startsWith(')]}\',')) {
      response.data = response.data.substring(6);
    }

    super.onResponse(response, handler);
  }
}

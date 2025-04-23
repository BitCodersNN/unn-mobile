// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';

abstract interface class PostApiHelper {
  Future<Response> post({
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
}

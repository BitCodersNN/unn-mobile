// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';

abstract interface class ApiOptionsHelper {
  void updateOptions(BaseOptions newOptions);
  void updateHeaders(Map<String, dynamic> newHeaders);
}

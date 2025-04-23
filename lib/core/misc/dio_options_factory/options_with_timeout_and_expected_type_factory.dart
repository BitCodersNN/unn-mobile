// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/dio_interceptor/response_data_type.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';

class OptionsWithTimeoutAndExpectedTypeFactory {
  static Options options(int duration, ResponseDataType responseDataType) =>
      Options(
        sendTimeout: Duration(seconds: duration),
        receiveTimeout: Duration(seconds: duration),
        extra: OptionsWithExpectedTypeFactory.mapWithExpectedType(
          responseDataType,
        ),
      );
}

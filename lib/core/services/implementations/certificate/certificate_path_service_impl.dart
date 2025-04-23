// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_path_service.dart';

class _DataNames {
  static const String sendtype = 'sendtype';
  static const String num = 'num';
}

class CertificatePathServiceImpl implements CertificatePathService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  CertificatePathServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<String?> getCertificatePath({
    required int sendtype,
    int number = 0,
  }) async {
    Response response;
    try {
      response = await _apiHelper.post(
        path: ApiPath.createSpravka,
        data: {
          _DataNames.sendtype: sendtype,
          _DataNames.num: number,
        },
        options: OptionsWithExpectedTypeFactory.string,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    return '${ApiPath.spravkaDocs}/${response.data}.pdf';
  }
}

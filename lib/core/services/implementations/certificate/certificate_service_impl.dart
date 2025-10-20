// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/json/json_utils.dart';
import 'package:unn_mobile/core/models/certificate/certificates.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificates_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

class CertificatesServiceImpl implements CertificatesService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  CertificatesServiceImpl(
    this._loggerService,
    this._apiHelper,
  );

  @override
  Future<Certificates?> getCertificates() async {
    Response response;

    try {
      response = await _apiHelper.get(
        path: ApiPath.spravka,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
    final jsonMap = jsonDecode(response.data) as JsonMap;
    if (!(jsonMap['enabled']! as bool)) {
      return Certificates.empty();
    }

    return Certificates.fromJson(jsonMap);
  }
}

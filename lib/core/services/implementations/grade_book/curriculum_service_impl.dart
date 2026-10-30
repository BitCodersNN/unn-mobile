// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/dio_options_factory/options_with_expected_type_factory.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum.dart';
import 'package:unn_mobile/core/models/grade_book/curriculum_semester.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/grade_book/curriculum_service.dart';

class CurriculumServiceImpl implements CurriculumService {
  final LoggerService _loggerService;
  final ApiHelper _apiHelper;

  CurriculumServiceImpl(this._loggerService, this._apiHelper);

  @override
  Future<Map<int, CurriculumSemester>?> getCurriculum() async {
    Response response;
    try {
      response = await _apiHelper.get(
        path: ApiPath.curriculum,
        options: OptionsWithExpectedTypeFactory.list,
      );
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }

    try {
      return Curriculum.fromJson(
        response.data,
        loggerService: _loggerService,
      ).semesters;
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
      return null;
    }
  }
}

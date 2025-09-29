// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/employee/preview_employee.dart';
import 'package:unn_mobile/core/models/profile/lecturer_search_result.dart';
import 'package:unn_mobile/core/models/profile/search_filter.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/lecturer_profile_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_search_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_service.dart';

class LecturerProfileServiceImpl implements LecturerProfileService {
  final LoggerService _loggerService;
  final ProfileSearchService _profileSearchService;
  final ProfileService _profileService;

  LecturerProfileServiceImpl(
    this._loggerService,
    this._profileSearchService,
    this._profileService,
  );

  @override
  Future<LecturerSearchResult> getProfile(
    String fullname,
    String syncId,
  ) async {
    const pageSize = 10;

    int offset = 0;
    int? total;

    do {
      final employees = await _profileSearchService.getEmployees(
        EmployeeSearchFilter(globalFilter: fullname),
        ordinalNumberFirst: offset,
        count: pageSize,
      );

      if (employees == null) {
        _loggerService.log(
          'Не удалось получить список сотрудников для фильтра: $fullname',
        );
        return LecturerSearchResult.error();
      }
      total ??= employees.total;

      if (employees.items.isEmpty || offset >= total) {
        break;
      }

      final result = await _findProfileInEmployees(employees.items, syncId);
      if (result.isFound) {
        return result;
      }
      if (result.isError) {
        _loggerService.log(
          'Ошибка при поиске профиля среди сотрудников: $fullname, syncId: $syncId',
        );
        return result;
      }

      offset += pageSize;
    } while (true);

    _loggerService.log(
      'Сотрудник с фамилией "$fullname" и syncId "$syncId" не найден.',
    );

    return LecturerSearchResult.notFound();
  }

  Future<LecturerSearchResult> _findProfileInEmployees(
    List<PreviewEmployee> employees,
    String syncId,
  ) async {
    for (final employee in employees) {
      final employeeProfile = await _profileService.getProfile(
        userId: employee.userId,
      ) as EmployeeData?;

      if (employeeProfile == null) {
        return LecturerSearchResult.error();
      }

      if (employeeProfile.syncId == syncId) {
        return LecturerSearchResult.found(employeeProfile);
      }
    }

    return LecturerSearchResult.notFound();
  }
}

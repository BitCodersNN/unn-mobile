// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/constants/academic_year.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_range_type.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_ranges.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/export_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';

class ScheduleScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  final CurrentUserSyncStorage _userStorage;
  final SearchIdOnPortalService _searchIdOnPortalService;
  final ScheduleService _scheduleService;
  final ScheduleSearchHistoryService _searchHistoryService;
  final ExportScheduleService _exportScheduleService;

  IdType get selectedUser => _selectedUser;
  set selectedUser(IdType value) {
    _selectedUser = value;
    notifyListeners();
  }

  DateTimeRange selectedTimeRange = DateTimeRanges.currentWeek();
  final defaultTimeRange = DateTimeRanges.currentWeek();

  int weekOffset = 0;

  List<IdType> get sortedUserTypeList => switch (_userStorage.typeOfUser) {
        const (EmployeeData) => [
            IdType.lecturer,
            IdType.auditoriun,
            IdType.student,
          ],
        _ => [
            IdType.student,
            IdType.group,
            IdType.lecturer,
          ]
      };

  ScheduleTabViewModel? get currentTab => modelsByType[selectedUser];

  bool get canExport => currentTab?.hasAnyId ?? false;

  int get weekNumber {
    final monday = selectedTimeRange.start;
    final semester = _semesterForWeek(monday);
    return _weeksFromSemester(semester, monday);
  }

  final Map<IdType, ScheduleTabViewModel> modelsByType = {};

  IdType _selectedUser = IdType.student;

  ScheduleScreenViewModel(
    this._userStorage,
    this._searchIdOnPortalService,
    this._scheduleService,
    this._searchHistoryService,
    this._exportScheduleService,
  );

  FutureOr<void> init() => busyCallAsync(() async {
        selectedUser = sortedUserTypeList.first;
        for (final type in sortedUserTypeList) {
          modelsByType[type] = ScheduleTabViewModel(
            type,
            this,
            _userStorage,
            _searchIdOnPortalService,
            _scheduleService,
            _searchHistoryService,
          );
        }
        await Future.wait(modelsByType.values.map((v) async => await v.init()));
      });

  void refreshTab() {
    for (final vm in modelsByType.values) {
      vm.refresh();
    }
  }

  void nextWeek() {
    weekOffset++;
    recalculateDateTimeRange();
    notifyListeners();
    refreshTab();
  }

  void previousWeek() {
    weekOffset--;
    recalculateDateTimeRange();
    notifyListeners();
    refreshTab();
  }

  void recalculateDateTimeRange() {
    final weekRange = WeekRange(weekOffset: weekOffset);
    selectedTimeRange = DateTimeRange(
      start: weekRange.start,
      end: weekRange.end,
    );
  }

  Future<RequestCalendarPermissionResult> askForExportPermission() =>
      _exportScheduleService.requestCalendarPermission();

  Future<bool> exportSchedule(DateTimeRangeType type) async {
    final week = WeekRange(weekOffset: weekOffset);

    final range = type.getRange(
      startDate: week.start,
      referenceDate: week.end,
    );

    final exportScheduleFilter =
        currentTab?.searchFilter?.copyWith(dateTimeRange: range);

    if (exportScheduleFilter == null) {
      return false;
    }

    final res =
        await _exportScheduleService.exportSchedule(exportScheduleFilter);
    return res == ExportScheduleResult.success;
  }

  Future openSettingsWindow() async {
    await _exportScheduleService.openSettings();
  }

  static DateTimeRange _semesterForWeek(DateTime monday) {
    final semester = _semesterFor(monday);
    final nextStart = _nextSemester(semester).start;
    if (!monday.isBefore(nextStart) ||
        monday.addWeeks(1).startOfWeek.isSameDate(nextStart)) {
      return _nextSemester(semester);
    }
    return semester;
  }

  static DateTimeRange _semesterFor(DateTime date) {
    if (date.month >= DateTime.september) {
      return AcademicYear.firstSemester(date.year);
    }
    if (date.month == DateTime.january) {
      return AcademicYear.firstSemester(date.year - 1);
    }
    return AcademicYear.secondSemester(date.year);
  }

  static DateTimeRange _nextSemester(DateTimeRange semester) =>
      semester.start.month == DateTime.september
          ? AcademicYear.secondSemester(semester.start.year + 1)
          : AcademicYear.firstSemester(semester.start.year);

  static int _weeksFromSemester(DateTimeRange semester, DateTime monday) {
    final semesterMonday = semester.start.startOfWeek;
    return monday.difference(semesterMonday).inDays ~/ 7 + 1;
  }

  @override
  void refresh() {
    if (weekOffset == 0) {
      for (final vm in modelsByType.values) {
        vm.triggerScrollToToday = true;
      }
      notifyListeners();
      return;
    }

    weekOffset = 0;
    recalculateDateTimeRange();
    notifyListeners();
    refreshTab();
  }
}

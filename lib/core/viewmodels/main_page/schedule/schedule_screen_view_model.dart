// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_range_type.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_ranges.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/export_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_tab_state.dart';

class ScheduleScreenViewModel extends BaseViewModel
    implements MainPageTabState {
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
  @override
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
    selectedTimeRange = DateTimeRange(
      start: defaultTimeRange.start.add(Duration(days: 7 * weekOffset)),
      end: defaultTimeRange.end.add(Duration(days: 7 * weekOffset)),
    );
  }

  Future<RequestCalendarPermissionResult> askForExportPermission() =>
      _exportScheduleService.requestCalendarPermission();

  Future<bool> exportSchedule(DateTimeRangeType type) async {
    final range = type.getRange(startDate: getStartDate());

    final exportScheduleFilter =
        currentTab?.searchFilter?.copyWith(dateTimeRange: range);

    if (exportScheduleFilter == null) {
      return false;
    }
    final res =
        await _exportScheduleService.exportSchedule(exportScheduleFilter);
    return res == ExportScheduleResult.success;
  }

  DateTime? getStartDate() {
    if (weekOffset == 0) {
      return null;
    }

    final now = DateTime.now();
    final currentMonday = now.subtract(
      Duration(days: now.weekday - DateTime.monday),
    );

    return currentMonday.add(Duration(days: 7 * weekOffset)).copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
  }

  Future openSettingsWindow() async {
    await _exportScheduleService.openSettings();
  }
}

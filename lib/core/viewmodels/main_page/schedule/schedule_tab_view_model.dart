// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';

class ScheduleTabViewModel extends BaseViewModel {
  final IdType _userType;
  final ScheduleScreenViewModel _parent;
  final CurrentUserSyncStorage _userStorage;
  final SearchIdOnPortalService _searchIdService;
  final ScheduleService _scheduleService;
  final ScheduleSearchHistoryService _searchHistoryService;

  String? defaultId;
  String? selectedId;
  String? foundName;

  List<List<Subject>>? schedule;

  ScheduleFilter? searchFilter;

  bool needsDefaultIdRefresh = true;
  bool triggerScrollToToday = false;

  bool get hasAnyId => defaultId != null || selectedId != null;

  int? get todayOrNextDayIndex =>
      _firstNonEmptyDayIndex(DateTime.now().weekdayIndex);

  WeekRange get selectedWeek => _parent.selectedWeek;
  int get weekOffset => _parent.weekOffset;

  OfflineSchedule? offlineSchedule;

  ScheduleTabViewModel(
    this._userType,
    this._parent,
    this._userStorage,
    this._searchIdService,
    this._scheduleService,
    this._searchHistoryService,
  );

  FutureOr<void> init() async => await refresh();

  Future<void> refreshDefaultId() async {
    final profile = _userStorage.currentUserData;
    if (profile == null) {
      return;
    }
    if (_userType == IdType.group && profile is StudentData) {
      final groupId = await _searchIdService.findIdOnPortal(
        profile.baseEduInfo.eduGroup,
        IdType.group,
      );
      defaultId = groupId?.first.id;
      if (defaultId != null) {
        needsDefaultIdRefresh = false;
      }
    } else {
      final currentUserId = await tryLoginAndRetrieveData(
        () async {
          final id = await _searchIdService.getIdOfLoggedInUser();

          return id;
        },
        () {
          needsDefaultIdRefresh = true;
          return null;
        },
      );
      if (isIdTypeMatchingUser(_userType, profile)) {
        defaultId = currentUserId?.id;
        needsDefaultIdRefresh = false;
      }
    }
  }

  bool isIdTypeMatchingUser(IdType type, UserData? data) {
    switch (data) {
      case EmployeeData _:
        switch (type) {
          case IdType.person:
          case IdType.lecturer:
            return true;
          default:
            return false;
        }
      case StudentData _:
        switch (type) {
          case IdType.student:
            return true;
          default:
            return false;
        }
      default:
        return false;
    }
  }

  void updateFilter() {
    if (selectedId == null && defaultId == null) {
      searchFilter = null;
      return;
    }
    searchFilter = ScheduleFilter(
      _userType,
      selectedId ?? defaultId!,
      _parent.selectedWeek.dateTimeRange,
    );
  }

  Future<void> loadSchedule({bool useRasp = false}) async {
    if (useRasp) {
      if (_userStorage.currentUserData?.login == null) {
        return;
      }

      final foundSchedule = await _scheduleService.getCurrentUserSchedule(
            _userStorage.currentUserData!.login!,
            _parent.selectedWeek.start,
          ) ??
          [];
      schedule = partitionSchedule(foundSchedule);
      return;
    }

    if (searchFilter == null) {
      return;
    }

    final List<Subject> foundSchedule = await tryLoginAndRetrieveData(
          () => _scheduleService.getSchedule(searchFilter!),
          () => schedule?.expand((e) => e).toList(),
        ) ??
        []
      ..sort((a, b) => a.dateTimeRange.start.compareTo(b.dateTimeRange.start));

    if (defaultId != null && searchFilter!.id == defaultId) {
      offlineSchedule = OfflineSchedule(_parent.selectedWeek, foundSchedule);
    }

    schedule = partitionSchedule(foundSchedule);
  }

  List<List<Subject>> partitionSchedule(List<Subject> schedule) =>
      List<List<Subject>>.generate(
        6,
        (day) => schedule
            .where((s) => s.dateTimeRange.start.weekday == day + 1)
            .toList(),
      );

  Future<List<ScheduleSearchSuggestionItem>> getSuggestions(String text) async {
    if (text.length <= 2) {
      final history = await _searchHistoryService.getHistory(_userType);
      if (history.isNotEmpty) {
        return history;
      }
    }
    return await _searchIdService.findIdOnPortal(text, _userType) ??
        <ScheduleSearchSuggestionItem>[];
  }

  FutureOr<void> refresh({bool triggerOfflineUpdate = false}) =>
      busyCallAsync(() async {
        if (AppSettings.useRaspSchedule &&
            selectedId == null &&
            isIdTypeMatchingUser(_userType, _userStorage.currentUserData)) {
          defaultId = ''; // Чтоб не был null
          updateFilter(); // Даже если мы этот фильтр не используем, пусть будет актуальный
          await loadSchedule(useRasp: true);
          if (triggerOfflineUpdate) {
            await _parent.saveOfflineSchedule();
          }
        } else {
          if (needsDefaultIdRefresh) {
            await refreshDefaultId();
          }
          updateFilter();
          await loadSchedule();
          if (triggerOfflineUpdate) {
            await _parent.saveOfflineSchedule();
          }
        }
      });

  Future<void> applySearchSuggestion(ScheduleSearchSuggestionItem s) async {
    selectedId = s.id;
    foundName = s.label;
    await _searchHistoryService.pushToHistory(_userType, s);
    await refresh();
  }

  Future<void> clearSearch() async {
    selectedId = null;
    foundName = null;
    await refresh();
  }

  String scrollContextKey(int weekOffset) =>
      '$weekOffset|${selectedId ?? ''}|${foundName ?? ''}';

  int? _firstNonEmptyDayIndex(int start) {
    final currentSchedule = schedule;
    if (currentSchedule == null) {
      return null;
    }

    final index = currentSchedule.indexWhere((item) => item.isNotEmpty, start);

    if (index == -1) {
      return null;
    }
    return index;
  }
}

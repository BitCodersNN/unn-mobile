// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:dio/dio.dart';
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
  WeekRange? scheduleWeek;

  ScheduleFilter? searchFilter;

  bool needsDefaultIdRefresh = true;
  bool triggerScrollToToday = false;
  bool _refreshRequested = false;
  bool _offlineUpdateRequested = false;
  CancelToken? _scheduleRequest;

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

  @override
  void dispose() {
    _scheduleRequest?.cancel();
    super.dispose();
  }

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
    final cancelToken = CancelToken();
    _scheduleRequest = cancelToken;
    try {
      await _loadSchedule(useRasp: useRasp, cancelToken: cancelToken);
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error)) {
        rethrow;
      }
    } finally {
      if (identical(_scheduleRequest, cancelToken)) {
        _scheduleRequest = null;
      }
    }
  }

  Future<void> _loadSchedule({
    required bool useRasp,
    required CancelToken cancelToken,
  }) async {
    final week = selectedWeek;
    final filter = searchFilter;
    if (useRasp) {
      if (_userStorage.currentUserData?.login == null) {
        return;
      }

      final foundSchedule =
          await _scheduleService.getCurrentUserSchedule(
            _userStorage.currentUserData!.login!,
            week.start,
            cancelToken: cancelToken,
          ) ??
          [];
      if (disposed ||
          cancelToken.isCancelled ||
          week.start != selectedWeek.start ||
          selectedId != null ||
          !AppSettings.useRaspSchedule) {
        return;
      }
      schedule = partitionSchedule(foundSchedule);
      scheduleWeek = week;
      return;
    }

    if (filter == null) {
      return;
    }
    final foundSchedule = await tryLoginAndRetrieveData<List<Subject>>(
      () => _scheduleService.getSchedule(filter, cancelToken: cancelToken),
      () => scheduleWeek?.start == week.start
          ? schedule?.expand((subject) => subject).toList()
          : null,
    );
    if (disposed ||
        cancelToken.isCancelled ||
        foundSchedule == null ||
        week.start != selectedWeek.start ||
        filter.id != (selectedId ?? defaultId)) {
      return;
    }
    foundSchedule.sort(
      (first, second) =>
          first.dateTimeRange.start.compareTo(second.dateTimeRange.start),
    );
    if (defaultId != null && filter.id == defaultId) {
      offlineSchedule = OfflineSchedule(week, foundSchedule);
    }
    schedule = partitionSchedule(foundSchedule);
    scheduleWeek = week;
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

  FutureOr<void> refresh({bool triggerOfflineUpdate = false}) {
    _refreshRequested = true;
    _offlineUpdateRequested |= triggerOfflineUpdate;
    _scheduleRequest?.cancel();
    return busyCallAsync(_refreshSchedule);
  }

  Future<void> _refreshSchedule() async {
    do {
      _refreshRequested = false;
      final saveOffline = _offlineUpdateRequested;
      _offlineUpdateRequested = false;
      final useRasp =
          AppSettings.useRaspSchedule &&
          selectedId == null &&
          isIdTypeMatchingUser(_userType, _userStorage.currentUserData);
      if (useRasp) {
        defaultId = '';
      } else if (needsDefaultIdRefresh) {
        await refreshDefaultId();
      }
      if (disposed) {
        return;
      }
      updateFilter();
      await loadSchedule(useRasp: useRasp);
      if (saveOffline && !disposed) {
        await _parent.saveOfflineSchedule();
      }
    } while (_refreshRequested && !disposed);
  }

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

// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/schedule_cache_limits.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/cache/lru_cache.dart';
import 'package:unn_mobile/core/misc/cache/restore_cache_then_refresh.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_key.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
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
  final OfflineScheduleProvider _offlineScheduleProvider;
  final LRUCache<ScheduleCacheKey, OfflineSchedule> _cachedSchedules = LRUCache(
    ScheduleCacheLimits.maxEntries,
  );

  bool failedToLoad = false;

  String? defaultId;
  String? selectedId;
  String? foundName;

  List<List<Subject>>? get schedule {
    final cached = cachedScheduleFor(selectedWeek);
    return cached == null ? null : partitionSchedule(cached.subjects);
  }

  ScheduleFilter? searchFilter;

  bool needsDefaultIdRefresh = true;
  bool triggerScrollToToday = false;
  bool _refreshRequested = false;
  CancelToken? _scheduleRequest;

  bool get hasAnyId => _useRasp || defaultId != null || selectedId != null;

  int? get todayOrNextDayIndex =>
      _firstNonEmptyDayIndex(DateTime.now().weekdayIndex);

  WeekRange get selectedWeek => _parent.selectedWeek;
  int get weekOffset => _parent.weekOffset;

  ScheduleTabViewModel(
    this._userType,
    this._parent,
    this._userStorage,
    this._searchIdService,
    this._scheduleService,
    this._searchHistoryService,
    this._offlineScheduleProvider,
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
    if (!isIdTypeMatchingUser(_userType, profile) &&
        !(_userType == IdType.group && profile is StudentData)) {
      needsDefaultIdRefresh = false;
      return;
    }
    if (_userType == IdType.group && profile is StudentData) {
      final groupId = await _searchIdService.findIdOnPortal(
        profile.baseEduInfo.eduGroup,
        IdType.group,
      );
      defaultId = groupId?.firstOrNull?.id;
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
        needsDefaultIdRefresh = defaultId == null;
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

  bool get _useRasp =>
      AppSettings.useRaspSchedule &&
      selectedId == null &&
      isIdTypeMatchingUser(_userType, _userStorage.currentUserData);

  ScheduleCacheKey cacheKeyFor(WeekRange week) => (
    ownerId: _userStorage.currentUserData?.userId ?? 0,
    type: _userType,
    id: selectedId,
    useRasp: _useRasp,
    weekStart: week.start,
  );

  OfflineSchedule? cachedScheduleFor(WeekRange week) =>
      _cachedSchedules.get(cacheKeyFor(week));

  bool _isCurrent(ScheduleCacheKey key, CancelToken token) =>
      !disposed && !token.isCancelled && key == cacheKeyFor(selectedWeek);

  void _showSchedule(ScheduleCacheKey key, OfflineSchedule data) {
    _cachedSchedules.save(key, data);
    notifyListeners();
  }

  Future<void> _loadFreshSchedule(
    WeekRange week,
    ScheduleCacheKey key,
    CancelToken token,
  ) async {
    if (!key.useRasp && selectedId == null && needsDefaultIdRefresh) {
      await refreshDefaultId();
    }
    if (!_isCurrent(key, token)) {
      return;
    }
    updateFilter();
    final filter = searchFilter;
    final login = _userStorage.currentUserData?.login;
    if (key.useRasp ? login == null : filter == null) {
      failedToLoad = key.useRasp || needsDefaultIdRefresh;
      return;
    }
    final subjects = await tryLoginAndRetrieveData<List<Subject>>(
      () => key.useRasp
          ? _scheduleService.getCurrentUserSchedule(
              login!,
              week.start,
              cancelToken: token,
            )
          : _scheduleService.getSchedule(filter!, cancelToken: token),
      () => null,
    );
    if (!_isCurrent(key, token)) {
      return;
    }
    failedToLoad = subjects == null;
    if (subjects == null) {
      return;
    }
    final data = OfflineSchedule(week, subjects);
    _showSchedule(key, data);
    await _offlineScheduleProvider.saveSchedule(key, data);
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

  FutureOr<void> refresh() {
    _refreshRequested = true;
    _scheduleRequest?.cancel();
    return busyCallAsync(_refreshSchedule);
  }

  Future<void> _refreshSchedule() async {
    do {
      _refreshRequested = false;
      failedToLoad = false;
      final week = selectedWeek;
      final key = cacheKeyFor(week);
      final token = CancelToken();
      _scheduleRequest = token;
      final cached = _cachedSchedules.get(key);
      notifyListeners();
      try {
        await restoreCacheThenRefresh<OfflineSchedule>(
          readCache: () async =>
              await _offlineScheduleProvider.getSchedule(key) ?? cached,
          restore: (data) => _showSchedule(key, data),
          refresh: () => _loadFreshSchedule(week, key, token),
          isCurrent: () => _isCurrent(key, token),
        );
      } on DioException catch (error) {
        if (!CancelToken.isCancel(error)) {
          rethrow;
        }
      } finally {
        if (identical(_scheduleRequest, token)) {
          _scheduleRequest = null;
        }
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

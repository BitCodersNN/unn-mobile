// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/models/schedule/offline_schedule.dart';
import 'package:unn_mobile/core/models/schedule/schedule_cache_key.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_configuration.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/offline_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';

typedef _LoadedSchedule = ({List<Subject> subjects, DateTime validUntil});

class ScheduleWidgetServiceImpl implements ScheduleWidgetService {
  final CurrentUserSyncStorage _userStorage;
  final AuthDataProvider _credentials;
  final ScheduleService _scheduleService;
  final SearchIdOnPortalService _search;
  final OfflineScheduleService _offline;
  final ScheduleWidgetPlatform _platform;
  final LoggerService _logger;

  Future<void>? _pending;
  CancelToken? _request;
  bool? _requestUseRasp;
  int _generation = 0;
  bool _refreshRequested = false;

  ScheduleWidgetServiceImpl(
    this._userStorage,
    this._credentials,
    this._scheduleService,
    this._search,
    this._offline,
    this._platform,
    this._logger,
  );

  @override
  Future<void> refresh() {
    if (!_platform.isSupported) {
      return Future.value();
    }
    _refreshRequested = true;
    if (_requestUseRasp != null &&
        _requestUseRasp != AppSettings.useRaspSchedule) {
      _request?.cancel();
    }
    return _pending ??= _refreshAll().whenComplete(() => _pending = null);
  }

  Future<void> _refreshAll() async {
    while (_refreshRequested) {
      _refreshRequested = false;
      try {
        await _refresh(_generation);
      } catch (error, stack) {
        if (error is! DioException || !CancelToken.isCancel(error)) {
          _logger.logError(error, stack);
        }
      } finally {
        _request = null;
        _requestUseRasp = null;
      }
    }
  }

  Future<void> _refresh(int generation) async {
    final user = _userStorage.currentUserData;
    if (user == null || (user is! StudentData && user is! EmployeeData)) {
      return;
    }
    if (!await _credentials.isContained()) {
      await clear();
      return;
    }
    final credentials = await _credentials.getData();
    if (credentials.login != user.login || generation != _generation) {
      return;
    }
    final useRasp = AppSettings.useRaspSchedule;
    await _offline.configureWidget(
      ScheduleWidgetConfiguration(
        ownerId: user.userId,
        ownerLabel: user is StudentData
            ? user.baseEduInfo.eduGroup
            : 'Личное расписание',
        type: user is StudentData ? IdType.student : IdType.lecturer,
        useRasp: useRasp,
      ),
    );
    if (generation != _generation ||
        _userStorage.currentUserData?.userId != user.userId) {
      return;
    }
    final token = CancelToken();
    _request = token;
    _requestUseRasp = useRasp;
    final week = WeekRange(weekOffset: 0);
    final next = WeekRange(weekOffset: 1, reference: week.reference);
    final loaded = useRasp
        ? await _loadOnline(user, week, next, token, useRasp: true)
        : await tryLoginAndRetrieveData<_LoadedSchedule>(
            () => _loadOnline(user, week, next, token, useRasp: false),
            () => null,
          );
    if (generation != _generation || token.isCancelled) {
      return;
    }
    _request = null;
    if (loaded == null || !await _canSave(user, generation, useRasp: useRasp)) {
      return;
    }
    await _cacheSchedule(user, loaded, week, useRasp: useRasp);
  }

  Future<bool> _canSave(
    UserData user,
    int generation, {
    required bool useRasp,
  }) async {
    if (!await _credentials.isContained()) {
      return false;
    }
    final credentials = await _credentials.getData();
    return generation == _generation &&
        _userStorage.currentUserData?.userId == user.userId &&
        credentials.login == user.login &&
        useRasp == AppSettings.useRaspSchedule;
  }

  Future<void> _cacheSchedule(
    UserData user,
    _LoadedSchedule loaded,
    WeekRange firstWeek, {
    required bool useRasp,
  }) async {
    final schedules = <ScheduleCacheKey, OfflineSchedule>{};
    for (int offset = 0; ; offset++) {
      final week = WeekRange(weekOffset: offset, reference: firstWeek.start);
      if (!week.start.isBefore(loaded.validUntil)) {
        break;
      }
      schedules[(
        ownerId: user.userId,
        type: user is StudentData ? IdType.student : IdType.lecturer,
        id: null,
        useRasp: useRasp,
        weekStart: week.start,
      )] = OfflineSchedule(
        week,
        loaded.subjects.where(
          (subject) => week.contains(subject.dateTimeRange.start),
        ),
      );
    }
    await _offline.saveSchedules(schedules);
  }

  Future<_LoadedSchedule?> _loadOnline(
    UserData user,
    WeekRange week,
    WeekRange next,
    CancelToken token, {
    required bool useRasp,
  }) async {
    if (useRasp) {
      final login = user.login;
      if (login == null) {
        return null;
      }
      return _loadWeeks(
        week,
        next,
        (range) => _scheduleService.getCurrentUserSchedule(
          login,
          range.start,
          cancelToken: token,
        ),
      );
    }
    final id = await _search.getIdOfLoggedInUser();
    if (id == null || token.isCancelled) {
      return null;
    }
    return _loadWeeks(
      week,
      next,
      (range) => _scheduleService.getSchedule(
        ScheduleFilter(
          user is StudentData ? IdType.student : IdType.lecturer,
          id.id,
          range.dateTimeRange,
        ),
        cancelToken: token,
      ),
    );
  }

  Future<_LoadedSchedule?> _loadWeeks(
    WeekRange week,
    WeekRange next,
    Future<List<Subject>?> Function(WeekRange) load,
  ) async {
    final results = await Future.wait([load(week), load(next)]);
    final current = results.first;
    if (current == null) {
      return null;
    }
    final upcoming = results.last;
    return (
      subjects: [...current, ...?upcoming],
      validUntil: upcoming == null ? week.endExclusive : next.endExclusive,
    );
  }

  @override
  Future<void> clear() async {
    _generation++;
    _refreshRequested = false;
    _request?.cancel();
    _request = null;
    await _offline.configureWidget(null);
  }
}

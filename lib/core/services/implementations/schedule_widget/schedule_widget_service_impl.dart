// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/week_range.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/employee/employee_data.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/profile/user_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/models/schedule_widget/schedule_widget_data.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_platform.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_widget/schedule_widget_service.dart';

typedef _LoadedSchedule = ({List<Subject> subjects, DateTime validUntil});

class ScheduleWidgetServiceImpl implements ScheduleWidgetService {
  final CurrentUserSyncStorage _userStorage;
  final AuthDataProvider _credentials;
  final ScheduleService _scheduleService;
  final SearchIdOnPortalService _search;
  final OfflineScheduleProvider _offline;
  final ScheduleWidgetPlatform _platform;
  final LoggerService _logger;

  Future<void>? _pending;
  CancelToken? _request;
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
    final cached = await _platform.read();
    if (generation != _generation ||
        _userStorage.currentUserData?.userId != user.userId) {
      return;
    }
    if (cached != null && cached.ownerId != user.userId) {
      await _platform.write(null);
    }
    final token = CancelToken();
    _request = token;
    final week = WeekRange(weekOffset: 0);
    final next = WeekRange(weekOffset: 1, reference: week.reference);
    final useRasp = AppSettings.useRaspSchedule;
    final loaded = await tryLoginAndRetrieveData<_LoadedSchedule>(
      () => _loadOnline(user, week, next, token, useRasp: useRasp),
      () => null,
    );
    if (generation != _generation || token.isCancelled) {
      return;
    }
    _request = null;
    if (loaded != null) {
      await _publish(
        user,
        loaded.subjects,
        week.start,
        loaded.validUntil,
        generation: generation,
        useRasp: useRasp,
      );
      return;
    }
    if (cached != null && cached.ownerId == user.userId) {
      return;
    }
    final offline = await _offline.getData();
    if (generation != _generation) {
      return;
    }
    final saved =
        offline[user is StudentData ? IdType.student : IdType.lecturer];
    if (saved != null) {
      await _publish(
        user,
        saved.subjects,
        saved.week.start,
        saved.week.endExclusive,
        generation: generation,
        useRasp: useRasp,
      );
    }
  }

  Future<_LoadedSchedule?> _loadOnline(
    UserData user,
    WeekRange week,
    WeekRange next,
    CancelToken token, {
    required bool useRasp,
  }) async {
    if (useRasp && user.login != null) {
      final results = await Future.wait([
        _scheduleService.getCurrentUserSchedule(
          user.login!,
          week.start,
          cancelToken: token,
        ),
        _scheduleService.getCurrentUserSchedule(
          user.login!,
          next.start,
          cancelToken: token,
        ),
      ]);
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
    final id = await _search.getIdOfLoggedInUser();
    if (id == null || token.isCancelled) {
      return null;
    }
    final subjects = await _scheduleService.getSchedule(
      ScheduleFilter(
        user is StudentData ? IdType.student : IdType.lecturer,
        id.id,
        DateTimeRange(start: week.start, end: next.end),
      ),
      cancelToken: token,
    );
    return subjects == null
        ? null
        : (subjects: subjects, validUntil: next.endExclusive);
  }

  Future<void> _publish(
    UserData user,
    List<Subject> subjects,
    DateTime start,
    DateTime end, {
    required int generation,
    required bool useRasp,
  }) async {
    if (!await _credentials.isContained()) {
      return;
    }
    final credentials = await _credentials.getData();
    if (generation != _generation ||
        _userStorage.currentUserData?.userId != user.userId ||
        credentials.login != user.login ||
        useRasp != AppSettings.useRaspSchedule) {
      return;
    }
    await _platform.write(
      ScheduleWidgetData(
        ownerId: user.userId,
        ownerLabel: user is StudentData
            ? user.baseEduInfo.eduGroup
            : 'Личное расписание',
        updatedAt: DateTime.now(),
        validFrom: start,
        validUntil: end,
        lessons: subjects.map(ScheduleWidgetLesson.fromSubject),
      ),
    );
  }

  @override
  Future<void> clear() async {
    _generation++;
    _refreshRequested = false;
    _request?.cancel();
    _request = null;
    await _platform.write(null);
  }
}

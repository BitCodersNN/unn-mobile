// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/student/student_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_new_viewmodel.dart';

class ScheduleTabViewModel extends BaseViewModel {
  final IdType _userType;
  final ScheduleScreenViewmodel _parent;
  final CurrentUserSyncStorage _userStorage;
  final SearchIdOnPortalService _searchIdService;
  final ScheduleService _scheduleService;
  final ScheduleSearchHistoryService _searchHistoryService;

  String? defaultId;
  String? selectedId;
  String? foundName;

  List<List<Subject>>? schedule;

  ScheduleFilter? _searchFilter;

  bool needsDefaultIdRefresh = true;

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
          needsDefaultIdRefresh = false;
          return id;
        },
        () {
          needsDefaultIdRefresh = true;
          return null;
        },
      );
      if (_userType == currentUserId?.idType) {
        defaultId = currentUserId?.id;
      }
    }
  }

  void updateFilter() {
    if (selectedId == null && defaultId == null) {
      _searchFilter = null;
    }
    _searchFilter = ScheduleFilter(
      _userType,
      selectedId ?? defaultId!,
      _parent.selectedTimeRange,
    );
  }

  Future<void> loadSchedule() async {
    final List<Subject> foundSchedule = await tryLoginAndRetrieveData(
          () => _scheduleService.getSchedule(_searchFilter!),
          () => schedule?.expand((e) => e).toList(),
        ) ??
        []
      ..sort((a, b) => a.dateTimeRange.start.compareTo(b.dateTimeRange.start));
    schedule = List<List<Subject>>.generate(
      6,
      (day) => foundSchedule
          .where((s) => s.dateTimeRange.start.weekday == day + 1)
          .toList(),
    );
  }

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

  FutureOr<void> refresh() => busyCallAsync(() async {
        if (needsDefaultIdRefresh) {
          await refreshDefaultId();
        }
        updateFilter();
        await loadSchedule();
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
}

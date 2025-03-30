import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_ranges.dart';
import 'package:unn_mobile/core/misc/authorisation/try_login_and_retrieve_data.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule/schedule_search_suggestion_item.dart';
import 'package:unn_mobile/core/models/profile/student_data.dart';
import 'package:unn_mobile/core/models/schedule/subject.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/export_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class ScheduleTabViewModel extends BaseViewModel {
  final int minValueLenForFindId = 3;

  final ScheduleService _getScheduleService;
  final SearchIdOnPortalService _searchIdOnPortalService;
  final OfflineScheduleProvider _offlineScheduleProvider;
  final ProfileOfCurrentUserService _gettingProfileOfCurrentUser;
  final ScheduleSearchHistoryService _historyService;
  final OnlineStatusData _onlineStatusData;
  final ExportScheduleService _exportScheduleService;

  void Function()? onRefresh;

  String _currentId = '';
  String selectedId = '';

  String lastSearchQuery = '';

  IdType _idType = IdType.student;

  Future<Map<int, List<Subject>>>? _scheduleLoader;

  int displayedWeekOffset = 0;
  // По идее - надо использовать decidePivotWeek,
  // но его нельзя в инициализации использовать.
  // Поэтому используем как есть, потом в init создаём как надо
  ScheduleFilter _filter = ScheduleFilter(
    IdType.student,
    '',
    DateTimeRanges.currentWeek(),
  );
  String _searchPlaceholderText = '';
  void Function(Map<int, List<Subject>>)? _onScheduleLoaded;

  final LoggerService _loggerService;

  ScheduleTabViewModel(
    this._getScheduleService,
    this._searchIdOnPortalService,
    this._offlineScheduleProvider,
    this._gettingProfileOfCurrentUser,
    this._historyService,
    this._onlineStatusData,
    this._exportScheduleService,
    this._loggerService,
  );

  @override
  void dispose() {
    _onlineStatusData.notifier.removeListener(updateOnlineStatus);
    super.dispose();
  }

  void updateOnlineStatus() {
    _updateScheduleLoader();
    notifyListeners();
  }

  DateTimeRange get displayedWeek =>
      offline ? decidePivotWeek() : _filter.dateTimeRange;
  ScheduleFilter get filter => _filter;
  bool get offline => !_onlineStatusData.isOnline;
  Future<Map<int, List<Subject>>>? get scheduleLoader => _scheduleLoader;

  String get searchPlaceholderText => _searchPlaceholderText;

  FutureOr<void> addHistoryItem(ScheduleSearchSuggestionItem item) =>
      _historyService.pushToHistory(_idType, item);

  Future<RequestCalendarPermissionResult> askForExportPermission() async {
    return await _exportScheduleService.requestCalendarPermission();
  }

  DateTimeRange decidePivotWeek() => DateTime.now().weekday == DateTime.sunday
      ? DateTimeRanges.nextWeek()
      : DateTimeRanges.currentWeek();

  Future<void> decrementWeek() async {
    displayedWeekOffset--;
    _filter = ScheduleFilter(
      _filter.idType,
      _filter.id,
      DateTimeRange(
        start: _filter.dateTimeRange.start.subtract(
          const Duration(days: DateTime.daysPerWeek),
        ),
        end: _filter.dateTimeRange.end.subtract(
          const Duration(days: DateTime.daysPerWeek),
        ),
      ),
    );
    _updateScheduleLoader();
    notifyListeners();
  }

  Future<bool> exportSchedule(DateTimeRange range) async {
    final exportScheduleFilter = ScheduleFilter(_idType, _currentId, range);
    final res =
        await _exportScheduleService.exportSchedule(exportScheduleFilter);
    return res == ExportScheduleResult.success;
  }

  Future<List<ScheduleSearchSuggestionItem>> getSearchSuggestions(
    String value,
  ) async {
    if (value.isEmpty || value.length < minValueLenForFindId) {
      return await _getHistorySuggestions();
    }
    final suggestions = await tryLoginAndRetrieveData(
      () async => await _searchIdOnPortalService.findIdOnPortal(value, _idType),
      () async => <ScheduleSearchSuggestionItem>[],
    );

    return suggestions;
  }

  Future<void> incrementWeek() async {
    displayedWeekOffset++;
    _filter = ScheduleFilter(
      _filter.idType,
      _filter.id,
      DateTimeRange(
        start: _filter.dateTimeRange.start.add(
          const Duration(days: DateTime.daysPerWeek),
        ),
        end: _filter.dateTimeRange.end.add(
          const Duration(days: DateTime.daysPerWeek),
        ),
      ),
    );
    _updateScheduleLoader();
    notifyListeners();
  }

  void init(
    IdType type, {
    void Function(Map<int, List<Subject>> schedule)? onScheduleLoaded,
  }) {
    if (isInitialized) {
      return;
    }
    setState(ViewState.busy);
    _onlineStatusData.notifier.addListener(updateOnlineStatus);
    isInitialized = true;
    _onScheduleLoaded = onScheduleLoaded;
    _idType = type;
    switch (type) {
      case IdType.student:
        _initHuman(_SearchBarPlaceholders.student, IdType.student);
        break;
      case IdType.group:
        _initGroup();
        break;
      case IdType.person:
      case IdType.lecturer:
        _initHuman(_SearchBarPlaceholders.lecturer, IdType.person);
        break;
      default:
        break;
    }
  }

  Future openSettingsWindow() async {
    await _exportScheduleService.openSettings();
  }

  void refresh() {
    onRefresh?.call();
  }

  Future<void> resetWeek() async {
    displayedWeekOffset = 0;
    _filter = ScheduleFilter(
      _filter.idType,
      _filter.id,
      decidePivotWeek(),
    );
    _updateScheduleLoader();
    notifyListeners();
  }

  Future<void> submitSearch(String query) async {
    if (query.isEmpty) {
      _filter = ScheduleFilter(_idType, _currentId, displayedWeek);
      if (_currentId.isEmpty) {
        _scheduleLoader = null;
        notifyListeners();
        return;
      }
    } else {
      final searchResult =
          await _searchIdOnPortalService.findIdOnPortal(query, _idType);

      if (searchResult == null) {
        throw Exception('Schedule search result was null');
      }
      _filter = ScheduleFilter(_idType, searchResult[0].id, displayedWeek);
    }

    final loader = _getScheduleLoader();
    _scheduleLoader = loader;
    _scheduleLoader!.then(
      _invokeOnScheduleLoaded,
    );
    notifyListeners();
  }

  void updateFilter(String id) {
    _filter = ScheduleFilter(_idType, id, displayedWeek);
    _updateScheduleLoader();
    notifyListeners();
  }

  Future<List<ScheduleSearchSuggestionItem>> _getHistorySuggestions() async {
    return await _historyService.getHistory(_idType);
  }

  Future<Map<int, List<Subject>>> _getScheduleLoader() async {
    setState(ViewState.busy);
    try {
      if (!offline && _filter.id.isEmpty) {
        final id = await tryLoginAndRetrieveData<IdForSchedule?>(
          _searchIdOnPortalService.getIdOfLoggedInUser,
          () => null,
        );
        if (id == null) {
          _loggerService.logError(
            Exception('Cannot get id'),
            StackTrace.current,
          );
          return {};
        }
        _filter = ScheduleFilter(_filter.idType, id.id, _filter.dateTimeRange);
      }
      if (_filter.id == '-1') {
        _filter = ScheduleFilter(
          _ExclusionId._vacancy.idType,
          _ExclusionId._vacancy.id,
          displayedWeek,
        );
      }

      final schedule = await tryLoginAndRetrieveData(
        () async => await _getScheduleService.getSchedule(filter),
        _offlineScheduleProvider.getData,
      );

      if (schedule == null) {
        throw Exception('Schedule was null');
      }

      final result = SplayTreeMap<int, List<Subject>>();
      for (final Subject subject in schedule) {
        final weekday = subject.dateTimeRange.start.weekday;
        result.putIfAbsent(weekday, () => []);
        result[weekday]!.add(subject);
      }

      if (!offline && displayedWeekOffset == 0 && filter.id == _currentId) {
        _offlineScheduleProvider.saveData(schedule);
      }
      return result;
    } finally {
      setState(ViewState.idle);
    }
  }

  void _initGroup() {
    _searchPlaceholderText = _SearchBarPlaceholders.group;
    tryLoginAndRetrieveData(
      _gettingProfileOfCurrentUser.getProfileOfCurrentUser,
      () => null,
    ).then((value) async {
      if (value == null) {
        _updateScheduleLoader();
        return;
      }

      if (value is StudentData) {
        final groupId = await _searchIdOnPortalService.findIdOnPortal(
          value.eduGroup,
          IdType.group,
        );
        _filter = ScheduleFilter(
          IdType.group,
          groupId!.first.id,
          decidePivotWeek(),
        );
        _currentId = groupId.first.id;
        _updateScheduleLoader();
      }

      notifyListeners();
    });
  }

  void _initHuman(String placeholderText, IdType idType) {
    _searchPlaceholderText = placeholderText;
    _filter = ScheduleFilter(
      _filter.idType,
      _filter.id,
      decidePivotWeek(),
    );
    tryLoginAndRetrieveData(
      _searchIdOnPortalService.getIdOfLoggedInUser,
      () => null,
    ).then((value) async {
      if (value == null) {
        _updateScheduleLoader();
        return;
      }
      if (value.idType == idType) {
        _filter = ScheduleFilter(value.idType, value.id, decidePivotWeek());
        _currentId = value.id;
        _updateScheduleLoader();
        return;
      }
      setState(ViewState.idle);
    });
  }

  FutureOr<void> _invokeOnScheduleLoaded(value) {
    _onScheduleLoaded?.call(value);
  }

  void _updateScheduleLoader() {
    _scheduleLoader = _getScheduleLoader()..then(_invokeOnScheduleLoaded);
  }
}

class _ExclusionId {
  static const _vacancy = IdForSchedule(IdType.lecturer, '26579');
}

class _SearchBarPlaceholders {
  static const String student = 'Имя студента';
  static const String group = 'Название группы';
  static const String lecturer = 'Имя преподавателя';
}

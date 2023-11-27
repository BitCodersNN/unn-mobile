import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/date_time_ranges.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/schedule_search_result_item.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class ScheduleScreenViewModel extends BaseViewModel {
  final GettingScheduleService _getScheduleService =
      Injector.appInstance.get<GettingScheduleService>();
  final SearchIdOnPortalService _searchIdOnPortalService =
      Injector.appInstance.get<SearchIdOnPortalService>();
  final OfflineScheduleProvider _offlineScheduleProvider =
      Injector.appInstance.get<OfflineScheduleProvider>();
  final AuthorisationService _authorisationService =
      Injector.appInstance.get<AuthorisationService>();
  final ScheduleSearchHistoryService _historyService =
      Injector.appInstance.get<ScheduleSearchHistoryService>();
  String _currentUserId = '';

  String selectedId = '';
  String lastSearchQuery = '';

  IDType _idType = IDType.student;
  bool _offline = false;
  bool get offline => _offline;
  Future<Map<int, List<Subject>>>? _scheduleLoader;
  Future<Map<int, List<Subject>>>? get scheduleLoader => _scheduleLoader;
  int displayedWeekOffset = 0;
  DateTimeRange get displayedWeek => _filter.dateTimeRange;
  ScheduleFilter _filter =
      ScheduleFilter(IDType.student, '', DateTimeRanges.currentWeek());
  String _searchPlaceholderText = '';
  String get searchPlaceholderText => _searchPlaceholderText;
  ScheduleFilter get filter => _filter;

  void Function(Map<int, List<Subject>>)? _onScheduleLoaded;

  Future<void> incrementWeek() async {
    displayedWeekOffset++;
    _filter = ScheduleFilter(
      _filter.idType,
      _filter.id,
      DateTimeRange(
        start: _filter.dateTimeRange.start.add(const Duration(days: 7)),
        end: _filter.dateTimeRange.end.add(const Duration(days: 7)),
      ),
    );
    _updateScheduleLoader();
    notifyListeners();
  }

  Future<void> decrementWeek() async {
    displayedWeekOffset--;
    _filter = ScheduleFilter(
      _filter.idType,
      _filter.id,
      DateTimeRange(
        start: _filter.dateTimeRange.start.subtract(const Duration(days: 7)),
        end: _filter.dateTimeRange.end.subtract(const Duration(days: 7)),
      ),
    );
    _updateScheduleLoader();
    notifyListeners();
  }

  FutureOr<void> _invokeOnScheduleLoaded(value) {
    if (_onScheduleLoaded != null) {
      _onScheduleLoaded!(value);
    }
  }

  Future<Map<int, List<Subject>>> _getScheduleLoader() async {
    final schedule = offline
        ? await _offlineScheduleProvider.loadSchedule()
        : await _getScheduleService.getSchedule(_filter);

    if (schedule == null) {
      throw Exception('Schedule was null');
    }
    final result = SplayTreeMap<int, List<Subject>>();
    for (Subject subject in schedule) {
      if (!result.keys.contains(subject.dateTimeRange.start.weekday)) {
        result.addEntries([
          MapEntry<int, List<Subject>>(subject.dateTimeRange.start.weekday, [])
        ]);
      }
      result[subject.dateTimeRange.start.weekday]!.add(subject);
    }
    if (!offline && displayedWeekOffset == 0) {
      _offlineScheduleProvider.saveSchedule(schedule);
    }
    return result;
  }

  void updateFilter(String id) {
    _filter = ScheduleFilter(_idType, id, displayedWeek);
    _updateScheduleLoader();
    notifyListeners();
  }

  Future<void> submitSearch(String query) async {
    if (query.isNotEmpty) {
      final searchResult =
          await _searchIdOnPortalService.findIDOnPortal(query, _idType);
      if (searchResult == null) {
        throw Exception('schedule search result was null');
      }
      addHistoryItem(query);
      _filter = ScheduleFilter(_idType, searchResult[0].id, displayedWeek);
    } else {
      _filter = ScheduleFilter(_idType, _currentUserId, displayedWeek);
    }
    final loader = _getScheduleLoader();
    _scheduleLoader = loader;
    _scheduleLoader!.then(
      _invokeOnScheduleLoaded,
    );
    notifyListeners();
  }

  FutureOr<void> addHistoryItem(String query) => _historyService.pushToHistory(type: _idType, value: query);

  Future<List<ScheduleSearchResultItem>> getSearchSuggestions(
      String value) async {
    final suggestions =
        await _searchIdOnPortalService.findIDOnPortal(value, _idType);
    if (suggestions == null) {
      throw Exception('Received null from suggestions service');
    }
    return suggestions;
  }

  Future<List<String>> getHistorySuggestions() async {
    return await _historyService.getHistory(_idType);
  }

  void init(IDType type,
      {void Function(Map<int, List<Subject>> schedule)? onScheduleLoaded}) {
    _onScheduleLoaded = onScheduleLoaded;
    _idType = type;
    switch (type) {
      case IDType.student:
        _searchPlaceholderText = 'Имя студента';
        setState(ViewState.busy);
        if (!_authorisationService.isAuthorised) {
          _offline = true;
          _updateScheduleLoader();
        } else {
          _searchIdOnPortalService.getIdOfLoggedInUser().then(
            (value) async {
              if (value == null) {
                throw Exception('Could not find current user. This is a bug');
              }
              _filter = ScheduleFilter(
                  value.$1, value.$2, DateTimeRanges.currentWeek());
              _updateScheduleLoader();
              notifyListeners();
            },
          );
        }
        setState(ViewState.idle);
        break;
      case IDType.group:
        _searchPlaceholderText = 'Название группы';
        setState(ViewState.busy);
        if (!_authorisationService.isAuthorised) {
          _offline = true;
          _updateScheduleLoader();
        } else {
          _searchIdOnPortalService.getIdOfLoggedInUser().then(
            (value) async {
              if (value == null) {
                throw Exception('Could not find current user. This is a bug');
              }
              _filter = ScheduleFilter(
                  value.$1, value.$2, DateTimeRanges.currentWeek());
              _updateScheduleLoader();
              notifyListeners();
            },
          );
        }
        setState(ViewState.idle);
        break;
      case IDType.person:
        _searchPlaceholderText = 'Имя преподавателя';
      default:
        break;
    }
  }

  void _updateScheduleLoader() {
    _scheduleLoader = _getScheduleLoader();
    _scheduleLoader!.then(
      _invokeOnScheduleLoaded,
    );
  }
}

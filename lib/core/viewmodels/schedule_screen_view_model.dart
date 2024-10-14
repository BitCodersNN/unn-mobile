part of 'package:unn_mobile/core/viewmodels/library.dart';

class _ExclusionID {
  static const _vacancy = IDForSchedule(IDType.lecturer, '26579');
}

class ScheduleScreenViewModel extends BaseViewModel {
  final GettingScheduleService _getScheduleService;
  final SearchIdOnPortalService _searchIdOnPortalService;
  final OfflineScheduleProvider _offlineScheduleProvider;
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;
  final ScheduleSearchHistoryService _historyService;
  final OnlineStatusData _onlineStatusData;
  final ExportScheduleService _exportScheduleService;
  final String _studentNameText = 'Имя студента';
  final String _lecturerNameText = 'Имя преподавателя';
  final String _groupNameText = 'Название группы';

  String _currentId = '';

  String selectedId = '';
  String lastSearchQuery = '';

  IDType _idType = IDType.student;

  ScheduleScreenViewModel(
    this._getScheduleService,
    this._searchIdOnPortalService,
    this._offlineScheduleProvider,
    this._gettingProfileOfCurrentUser,
    this._historyService,
    this._onlineStatusData,
    this._exportScheduleService,
  );
  bool get offline => !_onlineStatusData.isOnline;
  Future<Map<int, List<Subject>>>? _scheduleLoader;
  Future<Map<int, List<Subject>>>? get scheduleLoader => _scheduleLoader;
  int displayedWeekOffset = 0;
  DateTimeRange get displayedWeek =>
      offline ? decidePivotWeek() : _filter.dateTimeRange;
  // По идее - надо использовать decidePivotWeek,
  // но его нельзя в инициализации использовать.
  // Поэтому используем как есть, потом в init создаём как надо
  ScheduleFilter _filter = ScheduleFilter(
    IDType.student,
    '',
    DateTimeRanges.currentWeek(),
  );
  String _searchPlaceholderText = '';
  String get searchPlaceholderText => _searchPlaceholderText;
  ScheduleFilter get filter => _filter;

  void Function(Map<int, List<Subject>>)? _onScheduleLoaded;

  DateTimeRange decidePivotWeek() => DateTime.now().weekday == DateTime.sunday
      ? DateTimeRanges.nextWeek()
      : DateTimeRanges.currentWeek();

  void _initHuman(String placeholderText, IDType idType) {
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
      }
      notifyListeners();
    });
  }

  void _initGroup() {
    _searchPlaceholderText = _groupNameText;
    tryLoginAndRetrieveData(
      _gettingProfileOfCurrentUser.getProfileOfCurrentUser,
      () => null,
    ).then((value) async {
      if (value == null) {
        _updateScheduleLoader();
        return;
      }

      if (value is StudentData) {
        final groupID = await _searchIdOnPortalService.findIDOnPortal(
          value.eduGroup,
          IDType.group,
        );
        _filter = ScheduleFilter(
          IDType.group,
          groupID!.first.id,
          decidePivotWeek(),
        );
        _currentId = groupID.first.id;
        _updateScheduleLoader();
      }

      notifyListeners();
    });
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

  FutureOr<void> _invokeOnScheduleLoaded(value) {
    if (_onScheduleLoaded != null) {
      _onScheduleLoaded!(value);
    }
  }

  Future<Map<int, List<Subject>>> _getScheduleLoader() async {
    setState(ViewState.busy);
    if (_filter.id == '-1') {
      _filter = ScheduleFilter(
        _ExclusionID._vacancy.idType,
        _ExclusionID._vacancy.id,
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
      if (!result.keys.contains(subject.dateTimeRange.start.weekday)) {
        result.addEntries([
          MapEntry<int, List<Subject>>(
            subject.dateTimeRange.start.weekday,
            [],
          ),
        ]);
      }
      result[subject.dateTimeRange.start.weekday]!.add(subject);
    }

    if (!offline && displayedWeekOffset == 0 && filter.id == _currentId) {
      _offlineScheduleProvider.saveData(schedule);
    }

    setState(ViewState.idle);
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
        throw Exception('Schedule search result was null');
      }
      _filter = ScheduleFilter(_idType, searchResult[0].id, displayedWeek);
    } else {
      _filter = ScheduleFilter(_idType, _currentId, displayedWeek);
    }

    final loader = _getScheduleLoader();
    _scheduleLoader = loader;
    _scheduleLoader!.then(
      _invokeOnScheduleLoaded,
    );
    notifyListeners();
  }

  FutureOr<void> addHistoryItem(ScheduleSearchSuggestionItem item) =>
      _historyService.pushToHistory(_idType, item);

  Future<List<ScheduleSearchSuggestionItem>> getSearchSuggestions(
    String value,
  ) async {
    if (value.isEmpty) {
      return await _getHistorySuggestions();
    }
    final suggestions = await tryLoginAndRetrieveData(
      () async => await _searchIdOnPortalService.findIDOnPortal(value, _idType),
      () async => <ScheduleSearchSuggestionItem>[],
    );

    return suggestions;
  }

  Future<List<ScheduleSearchSuggestionItem>> _getHistorySuggestions() async {
    return await _historyService.getHistory(_idType);
  }

  void init(
    IDType type, {
    void Function(Map<int, List<Subject>> schedule)? onScheduleLoaded,
  }) {
    _onScheduleLoaded = onScheduleLoaded;
    _idType = type;
    switch (type) {
      case IDType.student:
        _initHuman(_studentNameText, IDType.student);
        break;
      case IDType.group:
        _initGroup();
        break;
      case IDType.person:
        _initHuman(_lecturerNameText, IDType.person);
        break;
      default:
        break;
    }
  }

  void _updateScheduleLoader() {
    _scheduleLoader = _getScheduleLoader();
    _scheduleLoader!.then(_invokeOnScheduleLoaded);
  }

  Future<RequestCalendarPermissionResult> askForExportPermission() async {
    return await _exportScheduleService.requestCalendarPermission();
  }

  Future openSettingsWindow() async {
    await _exportScheduleService.openSettings();
  }

  Future<bool> exportSchedule(DateTimeRange range) async {
    final exportScheduleFilter = ScheduleFilter(_idType, _currentId, range);
    final res =
        await _exportScheduleService.exportSchedule(exportScheduleFilter);
    return res == ExportScheduleResult.success;
  }
}

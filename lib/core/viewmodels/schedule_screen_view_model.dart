import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/date_time_ranges.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/core/models/subject.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class ScheduleScreenViewModel extends BaseViewModel {
  final GetScheduleService _getScheduleService =
      Injector.appInstance.get<GetScheduleService>();
  final SearchIdOnPortalService _searchIdOnPortalService =
      Injector.appInstance.get<SearchIdOnPortalService>();
  final OfflineScheduleProvider _offlineScheduleProvider =
      Injector.appInstance.get<OfflineScheduleProvider>();
  final AuthorisationService _authorisationService =
      Injector.appInstance.get<AuthorisationService>();
  String currentUserId = '';
  bool _offline = false;
  bool get offline => _offline;
  Future<Map<int, List<Subject>>>? _scheduleLoader;
  Future<Map<int, List<Subject>>>? get scheduleLoader => _scheduleLoader;
  int displayedWeekOffset = 0;
  DateTimeRange get displayedWeek => _filter.dateTimeRange;
  late ScheduleFilter _filter =
      ScheduleFilter(IDType.student, "", DateTimeRanges.currentWeek());
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
    _scheduleLoader = _getScheduleLoader();
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
    _scheduleLoader = _getScheduleLoader();
    notifyListeners();
  }

  Future<Map<int, List<Subject>>> _getScheduleLoader() async {
    final schedule = offline
        ? await _offlineScheduleProvider.loadSchedule()
        : await _getScheduleService.getSchedule(_filter);

    if (schedule == null) {
      throw Exception('Schedule was null');
    }
    Map<int, List<Subject>> result = {};
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

  void init() {
    setState(ViewState.busy);
    if (!_authorisationService.isAuthorised) {
      _offline = true;
      _scheduleLoader = _getScheduleLoader();
    } else {
      /*final HttpRequestSender sender = HttpRequestSender(
          path: 'bitrix/vuz/api/profile/current',
          cookies: {'PHPSESSID': _authorisationService.sessionId!});

      sender.get().then((response) async {
        Map<String, dynamic> data =
            jsonDecode(await responseToStringBody(response));
        String username = data['user']['fullname'];
        var ids = await _searchIdOnPortalService.findIDOnPortal(
            username, IDType.student);
        if (ids == null) {
          throw Exception(
              'Could not find current user. This is a bug. User name: $username');
        }
        _filter = ScheduleFilter(
            IDType.student, ids.values.first, DateTimeRanges.currentWeek());
        _scheduleLoader = _scheduleGetter();
        notifyListeners();
      });*/
      _searchIdOnPortalService.getIdOfLoggedInUser().then(
            (value) async {
              if(value == null)
              {
                throw Exception('Could not find current user. This is a bug');
              }
              _filter = ScheduleFilter(IDType.student, value, DateTimeRanges.currentWeek());
              _scheduleLoader = _getScheduleLoader();
              notifyListeners();
            },
          );
    }
    setState(ViewState.idle);
  }
}

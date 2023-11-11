import 'package:unn_mobile/core/models/schedule_search_result_item.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class SearchIdOnPortalService {
  Future<String?> getIdOfLoggedInUser();
  Future<List<ScheduleSearchResultItem>?> findIDOnPortal(String value, IDType valueType);
}

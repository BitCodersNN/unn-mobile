import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class SearchIdOnPortalService {
  Future<Map<String, String>?> findIDOnPortal(String value, IDType valueType);
}

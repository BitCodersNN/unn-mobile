import 'package:unn_mobile/core/models/schedule_filter.dart';

abstract interface class GettingIDService {
  Future<String> getID(String value, TypeID typeValue);
}

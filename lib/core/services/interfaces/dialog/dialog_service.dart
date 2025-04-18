import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';

abstract interface class DialogService {
  Future<PartialResult?> dialog({
    DialogQueryParameter dialogQueryParameter,
  });
}

import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';

abstract interface class DialogService {
  Future<List?> dialog({
    DialogQueryParameter dialogQueryParameter,
  });
}

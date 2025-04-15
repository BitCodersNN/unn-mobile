import 'package:unn_mobile/core/models/dialog/dialog.dart';
import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';

abstract interface class DialogService {
  Future<List<Dialog>?> dialog({
    DialogQueryParameter dialogQueryParameter,
  });
}

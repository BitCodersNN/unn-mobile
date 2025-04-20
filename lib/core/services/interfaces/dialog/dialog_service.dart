import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart';
import 'package:unn_mobile/core/models/dialog/dialog_query_parameter.dart';

abstract interface class DialogService {
  /// Получает список диалогов с сервера с возможностью пагинации.
  ///
  /// [dialogQueryParameter] - параметры запроса диалогов, включая лимит (по умолчанию 5).
  ///
  /// Возвращает [PartialResult<Dialog>] с:
  ///   - Списком диалогов (может быть [GroupDialog] или [UserDialog] в зависимости от типа)
  ///   - Флагом [hasMore], указывающим на наличие дополнительных диалогов для загрузки
  ///
  /// В случае ошибки:
  ///   - Возвращает `null`
  Future<PartialResult<Dialog>?> getDialogs({
    DialogQueryParameter dialogQueryParameter,
  });
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class MenuOrderProvider
    implements DataProvider<List<String>> {
  /// Получает сохранённый порядок разделов меню «Ещё».
  @override
  Future<List<String>> getData();

  /// Сохраняет порядок разделов меню «Ещё».
  @override
  Future<void> saveData(List<String> data);
}

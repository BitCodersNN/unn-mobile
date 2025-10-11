// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class LastCommitShaProvider
    implements DataProvider<String?> {
  @override
  Future<String?> getData();

  @override
  Future<void> saveData(String? loadingPages);

  @override
  Future<bool> isContained();
}

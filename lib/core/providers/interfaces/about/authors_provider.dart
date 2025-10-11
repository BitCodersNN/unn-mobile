// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class AuthorsProvider
    implements DataProvider<Map<String, List<Author>>?> {
  @override
  Future<Map<String, List<Author>>?> getData();

  @override
  Future<void> saveData(Map<String, List<Author>>? loadingPages);

  @override
  Future<bool> isContained();
}

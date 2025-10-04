// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/about/author.dart';

abstract interface class AuthorsConfigService {
  Future<Map<String, List<Author>>?> getAuthors();
}

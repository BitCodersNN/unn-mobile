// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/feed/blog_post.dart';
import 'package:unn_mobile/core/providers/interfaces/data_provider.dart';

abstract interface class BlogPostProvider
    implements DataProvider<List<BlogPost>?> {
  @override
  Future<List<BlogPost>?> getData();

  @override
  Future<void> saveData(List<BlogPost>? data);

  @override
  Future<bool> isContained();
}

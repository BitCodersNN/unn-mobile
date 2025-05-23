// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/models/loading_page/loading_page_data.dart';

abstract interface class LoadingPageConfigService {
  Future<List<LoadingPageModel>?> getLoadingPages();
}

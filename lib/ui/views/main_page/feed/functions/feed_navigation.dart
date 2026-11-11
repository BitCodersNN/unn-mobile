// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

Future<void> openFeedUserProfile(BuildContext context, int userId) {
  final profilePath = feedUserProfileRoute.pagePath.replaceFirst(
    ':userId',
    userId.toString(),
  );
  final location = AppRouter.of(context)
      .locationFor('${MainPagePaths.feed}/$profilePath');
  return context.push<void>(location);
}

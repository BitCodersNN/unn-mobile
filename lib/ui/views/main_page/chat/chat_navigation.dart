// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/constants/main_page_paths.dart';
import 'package:unn_mobile/core/models/profile/user_short_info.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_routing.dart';

Future<void> openUserDialog(BuildContext context, UserShortInfo user) {
  final userId = user.bitrixId;
  if (userId == null || userId <= 0) {
    return Future.value();
  }
  final dialogPath = userDialogRoute.pagePath.replaceFirst(
    ':userId',
    userId.toString(),
  );
  final location = AppRouter.of(context)
      .locationFor('${MainPagePaths.chats}/$dialogPath');
  return context.push<void>(location, extra: user);
}

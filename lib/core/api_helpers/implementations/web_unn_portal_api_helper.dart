// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/api_helpers/web_authenticated_api_helper.dart';
import 'package:unn_mobile/core/constants/api/host.dart';

final class WebUnnPortalApiHelper extends WebAuthenticatedApiHelper {
  WebUnnPortalApiHelper({
    required super.authorizationService,
  }) : super(
          host: Host.unn,
        );
}

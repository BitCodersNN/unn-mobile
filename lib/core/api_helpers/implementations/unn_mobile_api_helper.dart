// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/api_helpers/authenticated_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_service.dart';

final class UnnMobileApiHelper extends AuthenticatedApiHelper {
  UnnMobileApiHelper({
    required AuthorisationService authorizationService,
  }) : super(
          authorizationService,
          options: createBaseOptions(
            host: Host.unnMobile,
            headers: authorizationService.headers,
          ),
        );
}

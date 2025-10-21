// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/api_helpers/base_options_factory.dart';
import 'package:unn_mobile/core/constants/api/host.dart';

final class GithubApiHelper extends ApiHelper {
  GithubApiHelper()
      : super(
          options: createBaseOptions(
            host: Host.gitHubApi,
          ),
        );
}

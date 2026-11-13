// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';
import 'package:unn_mobile/core/constants/api/user_agents.dart';

final Uri _portalOrigin = Uri.parse(
  '${ProtocolType.https.name}://${Host.unn}/',
);

String feedImageUrl(String image) =>
    _portalOrigin.resolve(image.trim()).toString();

Map<String, String> feedImageHeaders(
  String url,
  Map<String, String>? authorizationHeaders,
) {
  final uri = Uri.parse(url);
  if (uri.origin == _portalOrigin.origin) {
    return authorizationHeaders ?? {};
  }
  return {
    'User-Agent': UserAgents.browser,
    'Referer': uri.origin,
    'Accept':
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  };
}

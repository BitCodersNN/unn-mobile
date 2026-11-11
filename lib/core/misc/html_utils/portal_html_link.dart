// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/api/host.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/constants/api/protocol_type.dart';

class PortalHtmlLink {
  static final _origin = Uri.https(Host.unn, '/');

  final Uri uri;

  const PortalHtmlLink._(this.uri);

  static PortalHtmlLink? tryParse(String href) {
    final uri = Uri.tryParse(href.trim());
    return uri == null ? null : PortalHtmlLink._(_origin.resolveUri(uri));
  }

  int? get mentionedUserId {
    if ((uri.scheme != ProtocolType.https.name &&
            uri.scheme != ProtocolType.http.name) ||
        uri.host != Host.unn ||
        uri.path != '/${ApiPath.ajax}' ||
        uri.queryParameters['page'] != 'user') {
      return null;
    }
    final id = int.tryParse(uri.queryParameters['id'] ?? '');
    return id != null && id > 0 ? id : null;
  }
}

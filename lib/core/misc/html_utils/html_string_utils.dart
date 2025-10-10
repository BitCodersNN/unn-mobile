// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

String removeHtmlComments(String html) {
  return html.replaceAllMapped(
    RegExp(r'<!--.*?-->', multiLine: true, dotAll: true),
    (match) => '',
  );
}

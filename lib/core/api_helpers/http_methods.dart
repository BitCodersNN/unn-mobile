// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
  options;

  String get asString => name.toUpperCase();
}

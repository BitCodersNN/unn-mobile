// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

abstract interface class StreamAuthService {
  Map<String, String>? get streamAuth;

  String? get sonetLAssetsCheckSum;
  String? get signedParameters;
  String? get commentFormUID;
  String? get blogCommentFormUID;

  Future<Map<String, String>?> getStreamAuthParams();
}

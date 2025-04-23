// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'dart:io';

abstract interface class DistanceLearningDownloaderService {
  Future<File?> downloadFile({
    required String fileName,
    required String downloadUrl,
    bool force,
  });
}

import 'dart:io';

abstract interface class DistanceLearningDownloaderService {
  Future<File?> downloadFile({
    required String fileName,
    required String downloadUrl,
    bool force,
  });
}

part of '../library.dart';

abstract interface class FileDownloaderService {
  Future<File?> downloadFile(
    String filePath, {
    String? downloadUrl,
    bool force = false,
  });

  Future<List<File>?> downloadFiles(List<String> filePaths);
}

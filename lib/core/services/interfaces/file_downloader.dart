import 'dart:io';

abstract interface class FileDownloaderService {
  Future<File?> downloadFile(String filePath);

  Future<List<File>?> downloadFiles(List<String> filePaths);
}

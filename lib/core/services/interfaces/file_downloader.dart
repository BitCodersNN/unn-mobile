import 'dart:io';

abstract interface class FileDownloader {
  Future<File?> downloadFile(String filePath);

  Future<List<File>?> downloadFiles(List<String> filePaths);
}

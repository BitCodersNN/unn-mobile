import 'dart:io';

abstract interface class FileUploader {
  Future<File?> downloadFile(String filePath);

  Future<List<File>?> downloadFiles(List<String> filePaths);
}

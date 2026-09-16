import 'dart:io';

abstract class FileService {
  Future<String?> pickDocument({List<String>? extensions});
  Future<List<String>?> pickMultipleDocuments({List<String>? extensions});
  Future<String> saveToOutputFolder(String tempFilePath, String suggestedName);
  Future<void> shareFile(String path);
  Future<void> openFile(String path);
  Future<Directory> tempWorkingDir();
  Future<void> clearTempWorkingDir();
  Future<int> cacheSizeBytes();
}

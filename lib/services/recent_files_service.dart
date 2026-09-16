abstract class RecentFilesService {
  Future<List<Map<String, dynamic>>> getRecentFiles();
  Future<void> addRecentFile(Map<String, dynamic> fileRecord);
  Future<void> removeRecentFile(String path);
  Future<void> clearRecentFiles();
}

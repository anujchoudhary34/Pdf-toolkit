abstract class PermissionService {
  Future<bool> requestStoragePermission();
  Future<bool> hasStoragePermission();
}

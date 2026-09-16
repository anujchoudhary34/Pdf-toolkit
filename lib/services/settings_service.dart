abstract class SettingsService {
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);
  Future<int> getDefaultDpi();
  Future<void> setDefaultDpi(int dpi);
  Future<String> getOutputFolderPath();
  Future<void> setOutputFolderPath(String path);
}

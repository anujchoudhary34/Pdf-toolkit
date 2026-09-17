# CHANGELOG.md

## [1.0.0] - Phase 1 Complete (Project Foundation + Navigation)

### Added
- Scaffolded Flutter Android project with `com.pdftoolkit.app` organization ID.
- Configured dependencies: `provider`, `shared_preferences`, and dev dependencies `flutter_lints`, `mocktail`.
- Configured Android build specifications (`minSdk = 26`, `targetSdk = 34`).
- Confirmed zero `INTERNET` permission requirement in `AndroidManifest.xml`.
- Added M3 Crimson theme system (`AppColors`, `AppTypography`, `AppTheme`) transcribing tokens from `DESIGN.md`.
- Added grid spacing and application constants (`AppSpacing`, `AppConstants`).
- Added typed app exception hierarchy (`AppExceptions`) and user copy translator (`ErrorTranslator`).
- Added application route manager (`AppRouter`) with placeholder routes for all 6 tools, Recent Files, and Settings.
- Defined abstract service interfaces under `lib/services/`:
  - `PdfService`
  - `ImageService`
  - `FileService`
  - `SettingsService`
  - `RecentFilesService`
  - `PermissionService`
- Built reusable error and empty state views (`ErrorStateView`, `EmptyStateView`).
- Implemented stub controllers (`SettingsController`, `RecentFilesController`).
- Implemented Home dashboard screen (`HomeScreen` & `ToolGridCard`) with 2x3 tool grid and "Offline • Secure" pill badge.
- Implemented root application shell (`PdfToolkitApp` & `MainRootShell`) with `MultiProvider` and 3-tab `IndexedStack` bottom navigation.
- Added smoke unit/widget test in `test/smoke_test.dart`.

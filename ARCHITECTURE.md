# ARCHITECTURE.md — PDF Toolkit (Flutter, Android-First)

> **Status**: No existing repository, README, or AI_HANDOFF.md was found in this workspace — only `DESIGN.md` was provided. This document assumes a **greenfield Flutter project** and defines the structure/conventions the implementation AI should scaffold from scratch. If a repository already exists elsewhere, reconcile it against this doc before writing code.
>
> **Scope discipline**: This document defines *how the app is built*, not *how it looks*. All visual/UX decisions remain governed by `DESIGN.md`. Nothing here should require redesigning a screen.
>
> **Audience**: A single beginner-to-intermediate developer (possibly assisted by AI) who will maintain this project long-term. Every decision below optimizes for **readability and low cognitive load over cleverness**.

---

## 1. Guiding Principles

1. **Feature-first, not layer-first.** Code is organized by *what it does for the user* (Merge PDF, Split PDF…), not by generic technical layer. A beginner should be able to find everything related to "Split PDF" in one folder.
2. **Thin UI, dumb widgets, small controllers.** Screens read state and call controller methods. Controllers hold UI state. Services do the actual work (PDF/image/file I/O). No widget talks to a third-party package directly.
3. **Boring technology.** Prefer the most widely-used, actively maintained package for each job. No package is added without a one-line justification in §9.
4. **Offline-only, always.** No package that requires network access, license phone-home, analytics, or telemetry is permitted. `android.permission.INTERNET` is never requested.
5. **Fail loud to the developer, fail soft to the user.** Every operation that can fail (corrupt PDF, low storage, cancelled job) has a typed error and a corresponding UI state already specified in `DESIGN.md` Screen 14.
6. **Don't build for scale you don't have.** This is a local utility app with no accounts, no sync, no multi-user data. Avoid architecture patterns (BLoC, full Clean Architecture with 4+ layers, dependency-injection frameworks) that solve problems this app doesn't have.

---

## 2. Flutter Folder Structure

Feature-first structure. Each feature folder is self-contained: if a feature is deleted, nothing elsewhere breaks (aside from its Home tool-grid entry and route registration).

```
lib/
├── main.dart                     # Entry point, runApp()
├── app.dart                      # MaterialApp, theme wiring, top-level Providers
│
├── core/                         # Cross-cutting, feature-agnostic code
│   ├── theme/
│   │   ├── app_colors.dart       # Design tokens from DESIGN.md §1.1 (light+dark)
│   │   ├── app_typography.dart   # Text styles from DESIGN.md §1.2
│   │   └── app_theme.dart        # ThemeData assembly (M3)
│   ├── constants/
│   │   ├── spacing.dart          # 8dp grid constants
│   │   └── app_constants.dart    # App name, output folder default name, etc.
│   ├── routing/
│   │   └── app_router.dart       # Route names + onGenerateRoute table
│   ├── errors/
│   │   ├── app_exceptions.dart   # Typed exceptions (see §7)
│   │   └── error_translator.dart # Exception -> user-facing message/copy
│   └── utils/
│       ├── file_size_formatter.dart
│       └── result.dart           # Lightweight Result<T> wrapper (see §7)
│
├── services/                     # Stateless-ish, testable "does the work" layer.
│   │                             # These wrap third-party packages so features never
│   │                             # import a plugin directly (see §5).
│   ├── pdf_service.dart          # Abstract interface
│   ├── pdf_service_impl.dart     # Concrete implementation (Syncfusion + `pdf` + pdfx)
│   ├── image_service.dart / _impl.dart
│   ├── file_service.dart / _impl.dart      # SAF pick/save, temp dir management
│   ├── settings_service.dart / _impl.dart  # SharedPreferences read/write
│   ├── recent_files_service.dart / _impl.dart
│   └── permission_service.dart / _impl.dart
│
├── shared/                       # Reusable UI shared by 2+ features
│   └── widgets/
│       ├── processing_sheet.dart       # Screen 12 spec
│       ├── success_screen.dart         # Screen 13 spec
│       ├── error_state_view.dart       # Screen 14 spec
│       ├── empty_state_view.dart       # Screen 14 spec
│       ├── page_thumbnail_grid.dart    # Reorderable grid, Screen 2.4
│       ├── file_source_picker.dart     # Screen 10 states
│       └── privacy_footnote.dart       # "Running locally on device" pill
│
└── features/
    ├── home/
    │   └── presentation/
    │       ├── home_screen.dart
    │       └── widgets/tool_grid_card.dart
    ├── recent_files/
    │   ├── application/recent_files_controller.dart
    │   ├── domain/recent_file.dart
    │   └── presentation/recent_files_screen.dart
    ├── settings/
    │   ├── application/settings_controller.dart
    │   ├── domain/app_settings.dart
    │   └── presentation/settings_screen.dart
    ├── images_to_pdf/
    │   ├── application/images_to_pdf_controller.dart
    │   └── presentation/images_to_pdf_screen.dart
    ├── manage_pages/
    │   ├── application/manage_pages_controller.dart
    │   └── presentation/manage_pages_screen.dart
    ├── merge_pdf/
    │   ├── application/merge_pdf_controller.dart
    │   └── presentation/merge_pdf_screen.dart
    ├── split_pdf/
    │   ├── application/split_pdf_controller.dart
    │   └── presentation/split_pdf_screen.dart
    ├── pdf_to_images/
    │   ├── application/pdf_to_images_controller.dart
    │   └── presentation/pdf_to_images_screen.dart
    └── compress_pdf/
        ├── application/compress_pdf_controller.dart
        └── presentation/compress_pdf_screen.dart
```

**Convention per feature folder**: only `application/` (state) and `presentation/` (widgets) are mandatory. Add `domain/` only if the feature needs its own model class beyond primitives. Do **not** pre-create a `data/` layer for tool features — they call `services/` directly, they don't own persistence (only `recent_files` and `settings` do).

Tests mirror this tree under `test/`, e.g. `test/services/pdf_service_impl_test.dart`, `test/features/split_pdf/split_pdf_controller_test.dart`.

---

## 3. Feature / Module Boundaries

| Module | Owns | Does NOT own |
|---|---|---|
| `home` | Tool grid, entry navigation, recent-activity peek (reads from `recent_files`) | Any processing logic |
| `recent_files` | List of past outputs (metadata + thumbnail path), filtering, delete/rename/share actions | The actual PDF files on disk (owned by `file_service`) |
| `settings` | Theme mode, default DPI/quality, output folder path, cache size display | Applying those defaults inside a tool — each tool controller *reads* settings via `SettingsService`, it doesn't reach into the settings feature |
| `images_to_pdf` … `compress_pdf` (6 tool features) | Their own screen's step flow (selection → config → processing → success/error), calling `PdfService`/`ImageService` | PDF page-rendering internals, file picking mechanics, storage paths — delegated to `services/` |
| `services/*` | All actual file I/O and PDF/image manipulation, hidden behind interfaces | Any widget/UI code, any `BuildContext` |
| `shared/widgets` | Presentational widgets reused by 3+ tool screens (progress, success, error, empty states, thumbnail grid) | Feature-specific business logic |

**Rule**: a `features/*/application` controller may import `services/*` and `core/*`, never another feature's controller. If two tools need to share logic, promote that logic into a service or `shared/`.

---

## 4. State Management Approach

**Choice: `provider` (official Flutter-team package) with `ChangeNotifier` controllers.**

Why, over alternatives:

| Option | Verdict | Reason |
|---|---|---|
| **`provider` + `ChangeNotifier`** ✅ | **Chosen** | Minimal boilerplate, huge documentation/tutorial base, no code generation step, easiest for a beginner to debug (it's "just a class with `notifyListeners()`"). Matches app's actual complexity: mostly local, per-screen state. |
| Riverpod | Rejected (for now) | More powerful (compile-safe DI, no `BuildContext` needed) but adds a steeper learning curve and, in newer versions, a code-generation build step — unnecessary overhead for an app with no complex cross-feature state graph. Can be revisited later without a full rewrite since controllers are already plain classes. |
| BLoC/Cubit | Rejected | Event/stream boilerplate is disproportionate to the app's needs (no complex async event sequencing beyond "run job, show progress, show result"). |
| `setState` only | Rejected | Fine for tiny widgets (used liberally for purely local UI toggles), but tool screens need state to survive rebuilds triggered by the shared progress/success widgets and to be unit-testable independent of widgets. |

**Pattern**:
- Each tool screen has exactly one controller (e.g. `MergePdfController extends ChangeNotifier`) created via `ChangeNotifierProvider` scoped to that screen's route (not global) — it's disposed when the user leaves the screen.
- App-wide state — `SettingsController` and `RecentFilesController` — is provided once at the app root via `MultiProvider` in `app.dart`, since Home, Recent Files, and every tool screen may need to read them (e.g. a tool reads default DPI from settings; every tool writes a new entry to recent files on success).
- Controllers expose a simple state enum/sealed class for the step flow, e.g.:
  ```dart
  enum ToolStep { selecting, configuring, processing, success, error }
  ```
  The screen's `build()` switches on `controller.step` to decide which `shared/widgets` view to show. This directly maps to the "Utility Workflows" step list in `DESIGN.md` §3.
- Controllers never import Flutter Material widgets — they may import `dart:async`/`Uri` etc. but stay UI-framework-agnostic, so they're testable with plain `flutter_test`/`test`.

---

## 5. PDF / Image Service Boundaries

All third-party PDF/image packages are accessed **only** through `services/`. Every service is defined as an abstract class + one implementation, so a future package swap (e.g. licensing issue) touches one file, not six features.

### `PdfService` (abstract)
```dart
abstract class PdfService {
  Future<PdfDocInfo> loadInfo(String path);           // page count, size, encrypted?
  Future<Uint8List> renderPageThumbnail(String path, int pageIndex, {int dpi});
  Future<String> imagesToPdf(List<String> imagePaths, ImagesToPdfOptions options);
  Future<String> mergePdfs(List<String> paths, MergeOptions options);
  Future<List<String>> splitPdf(String path, SplitOptions options);
  Future<String> reorderRotateDeletePages(String path, List<PageOp> ops);
  Future<List<String>> pdfToImages(String path, ExportOptions options);
  Future<String> compressPdf(String path, CompressionPreset preset);
}
```
- **Implementation packages**: `syncfusion_flutter_pdf` for reading/mutating existing PDF structure (merge, split, page delete/rotate/reorder, metadata strip); the `pdf` package for building brand-new PDFs (Images → PDF); `pdfx` for rasterizing pages to bitmaps (thumbnails, PDF → Images, preview). See §9 for the license note on Syncfusion.
- Every method runs the actual byte-crunching inside `compute()` (a background isolate) — see §11 — and reports progress via a `Stream<ProgressEvent>` variant where the operation can take >2 seconds (compression, multi-page render), matching `DESIGN.md` §2.5.

### `ImageService` (abstract)
```dart
abstract class ImageService {
  Future<List<String>> pickImages();                 // gallery, via image_picker
  Future<String?> captureImage();                     // camera, via image_picker
  Future<String> compressImage(String path, int quality);
  Future<Size> imageDimensions(String path);
}
```
- Implementation: `image_picker` for selection/capture, `flutter_image_compress` for downscaling before embedding into a PDF.

### `FileService` (abstract)
```dart
abstract class FileService {
  Future<String?> pickDocument({List<String> extensions});  // SAF, via file_picker
  Future<String?> pickMultipleDocuments({List<String> extensions});
  Future<String> saveToOutputFolder(String tempFilePath, String suggestedName); // SAF create-document
  Future<void> shareFile(String path);                        // share_plus
  Future<void> openFile(String path);                          // open_filex
  Future<Directory> tempWorkingDir();
  Future<void> clearTempWorkingDir();
  Future<int> cacheSizeBytes();
}
```
- Owns **all** filesystem/SAF interaction. No feature ever calls `dart:io` or `path_provider` directly.

**Rule of thumb**: if a `pubspec.yaml` package is a PDF/image/file/permission plugin, exactly one service wraps it, and that service is the only importer of that package in the whole codebase (enforced by convention/code review, not tooling, to keep this beginner-simple).

---

## 6. Local File / Storage Strategy

Three distinct storage concerns, kept deliberately separate:

1. **Working/temp files** (`FileService.tempWorkingDir()`): `path_provider`'s `getTemporaryDirectory()`. Used while a job is running (intermediate pages, downscaled images). Cleared automatically at app start and via the Settings "Clear Cache" button. Never shown to the user as a "file".
2. **User-visible outputs**: written via Android **Storage Access Framework** (`ACTION_CREATE_DOCUMENT` through `file_picker`'s `FilePicker.platform.saveFile` or `saf_util`/`saf_stream` if finer control is needed) into the folder the user picked in Settings (defaulting to `Documents/PDF_Toolkit/` per `DESIGN.md` Screen 13). This is the **only** place files the user cares about are written — the app never silently writes into app-private storage for a final result.
3. **App metadata** (settings + recent-files list): `shared_preferences`. Recent files are stored as a JSON-encoded list of lightweight records (`{path, name, sizeBytes, pageCount, createdAt, category}`) — **not** the files themselves, just pointers + a cached thumbnail path (thumbnail bitmap cached in temp dir, regenerated if missing). If the recent-files list ever needs querying/filtering beyond simple JSON list scanning (it won't at this scale — a few hundred entries max), that's the trigger to introduce `sqflite`/`Hive`, not before.

No database is included at project start — this is a deliberate "don't add a dependency without a clear reason" call given §9.

---

## 7. Error Handling

**Typed exceptions**, defined in `core/errors/app_exceptions.dart`:

```dart
sealed class AppException implements Exception { final String message; }
class CorruptedPdfException extends AppException { ... }
class PasswordProtectedPdfException extends AppException { ... }
class InsufficientStorageException extends AppException { ... }
class FileAccessDeniedException extends AppException { ... }   // SAF/permission denial
class UnsupportedFileTypeException extends AppException { ... }
class OperationCancelledException extends AppException { ... } // user tapped Cancel
```

- **Services throw**, they never show UI. A service that hits a package-specific error catches it and re-throws the closest `AppException`.
- **Controllers catch**, set `step = ToolStep.error` and store the exception; they don't format user copy.
- **`core/errors/error_translator.dart`** maps each `AppException` to the exact title/body/actions text specified in `DESIGN.md` Screen 14 (e.g. `PasswordProtectedPdfException` → "Password-protected PDFs require unlocking before merging" + "Unlock" action). This keeps copywriting in one place instead of scattered across features.
- **Cancellation**: long-running `PdfService` operations accept a `CancellationToken` (a simple `bool` flag class checked between isolate work chunks) so the Screen 12 "Cancel" button can abort safely without killing the isolate abruptly mid-write (avoids corrupt partial output files — always write to a temp file first, then move/rename into place on success).
- **Uncaught errors**: `runZonedGuarded` in `main.dart` catches anything that slips through and routes it to a generic Screen 14 error view rather than a red screen of death. **No crash reporting SDK** is wired up (Firebase Crashlytics, Sentry, etc.) — per the offline/zero-telemetry tenet, errors are logged to console only in debug builds.
- **`Result<T>`** (`core/utils/result.dart`) is an optional lightweight sealed-class wrapper (`Success<T>` / `Failure`) available for service methods where a controller wants to branch without a `try/catch` at the call site. It's a convenience, not a mandate — plain `try/catch` is equally acceptable and often clearer for a beginner; use whichever reads better per call site.

---

## 8. Navigation Approach

**Choice: Flutter's built-in `Navigator` (imperative, named routes via `onGenerateRoute`) — no routing package.**

- Root shell = 3-tab **bottom navigation** (`Home`, `Recent Files`, `Settings`) via an `IndexedStack` so each tab preserves scroll/filter state when switching, per `DESIGN.md` §5.2.
- Each of the 6 tools is a **single full-screen route** pushed from Home's tool grid (`Navigator.pushNamed(context, AppRoutes.mergePdf)`). The multi-step flow *within* a tool (selection → config → processing → success) is **not** separate routes — it's internal state in that screen's controller (`ToolStep` enum, §4), matching how `DESIGN.md` describes each tool screen as one continuous workflow with sheets/overlays rather than five distinct pages. This avoids a deep, fragile back-stack and keeps predictive-back behavior simple (Flutter's `Navigator` supports Android 14+ predictive back automatically as of recent Flutter versions — no extra package needed).
- **Unsaved-changes confirmation** (`DESIGN.md` §5.1, "Discard changes?"): implemented with `PopScope` (`canPop: controller.canDiscard`) on `Manage Pages` and `Merge PDF` screens, showing the confirmation dialog before allowing pop.
- **Why not `go_router`**: this app has no deep links, no web URL requirements, and a shallow, mostly-linear navigation graph. `go_router` is a fine future upgrade if the graph grows, but today it would be a dependency solving a problem the app doesn't have.

Route table lives in one file, `core/routing/app_router.dart`, as a simple `Map<String, WidgetBuilder>` — easy for a beginner to scan and extend when adding feature #7 onward.

---

## 9. Dependency / Package Recommendations

Every dependency below has a one-line "why", and every choice notes the rejected alternative(s) so future-you (or the implementation AI) doesn't re-litigate this.

| Package | Purpose | Why this one | Alternative considered & rejected |
|---|---|---|---|
| `provider` | State management | Official Flutter-team package, minimal boilerplate, no codegen. §4 | `flutter_riverpod` (steeper learning curve, optional codegen); `flutter_bloc` (disproportionate boilerplate for this app's complexity) |
| `syncfusion_flutter_pdf` | Read/mutate existing PDFs: merge, split, delete/rotate/reorder pages, strip metadata | Most complete free Dart-native PDF manipulation API; **free "Community License"** for individuals/small companies (<$1M USD annual revenue) with no watermark — must be verified against the developer's situation before shipping; does not require network access at runtime | `pdf_manipulator`/hand-rolled byte manipulation (far more fragile, high maintenance burden for a beginner); paid alternatives (unnecessary cost) |
| `pdf` (dart.dev-adjacent, `package:pdf`) | Build brand-new PDFs from images (Images → PDF) | Pure-Dart, no native deps, permissive license, widely used, no network | Using Syncfusion for creation too (works, but `pdf` is lighter for pure "assemble images into pages" and has zero licensing ambiguity) |
| `pdfx` | Render PDF pages to bitmaps (thumbnails, PDF → Images export, full-page preview/zoom) | Actively maintained, wraps native PDF renderers (PDFium/PDFKit), good performance on low-end Android, supports page-by-page rendering without loading the whole doc | `flutter_pdfview` (viewer-only, can't export raw page images cleanly); Syncfusion's own renderer (would concentrate all PDF logic + licensing risk in one vendor) |
| `image_picker` | Pick/capture images for Images → PDF | Official Flutter-team plugin, handles camera/gallery permissions internally | `file_picker` for images too (works, but `image_picker`'s camera capture UX is purpose-built) |
| `flutter_image_compress` | Downscale/compress images before embedding or exporting | Native-backed, fast, de-facto standard | Pure-Dart `image` package compression (much slower on large photos, blocks isolate longer) |
| `file_picker` | SAF document selection (PDF import) and SAF "create document" for saving PDFs/zips | De-facto standard, actively maintained, wraps SAF correctly so no legacy broad storage permission is needed on Android 11+ | Hand-rolled platform channel to `Intent.ACTION_OPEN_DOCUMENT` (reinventing a well-solved wheel) |
| `path_provider` | Locate temp/app-private directories | Official Flutter-team plugin | n/a — no real alternative |
| `permission_handler` | Request legacy storage permission only on API 26–28 (pre-scoped-storage) | Standard, well-maintained | Manual `MethodChannel` (unnecessary for a solved problem) |
| `shared_preferences` | Persist settings + recent-files JSON list | Official Flutter-team plugin, zero-config, sufficient at this data scale (§6) | `hive`/`sqflite` (real databases — deferred until/unless recent-files scale demands it, to avoid an unjustified dependency) |
| `share_plus` | Android share sheet for output files | De-facto standard, actively maintained by Flutter community (flutter.dev packages federation) | Native `Intent.ACTION_SEND` platform channel (reinventing) |
| `open_filex` | "Open Document" action launching the default viewer | Small, focused, actively maintained | `open_file` (older, less maintained fork) |
| `archive` | Bundle exported images into a `.zip` (PDF → Images "Bundle into ZIP" option) | Pure-Dart, no native deps, does exactly one thing | Shelling out to a native zip binary (fragile, platform-dependent) |
| `flutter_lints` (dev) | Static analysis defaults | Official, catches beginner mistakes early | n/a |
| `mocktail` (dev) | Mocking services in unit tests | No code generation needed (unlike `mockito`'s build_runner step), simpler for a beginner test setup | `mockito` (requires `build_runner`, extra build step) |

**Explicitly excluded** (matches the "avoid unnecessary APIs/backend/cloud services" instruction): any HTTP client, any analytics/crash-reporting SDK, any cloud storage SDK, any ads SDK, `go_router`, `riverpod`, `bloc`, `sqflite`/`hive` (deferred), `dio`/`http`.

---

## 10. Testing Strategy

Kept deliberately proportionate — enough confidence to refactor safely, not an enterprise test pyramid.

1. **Unit tests — `services/`** (highest priority): each `*ServiceImpl` gets tests covering the "boring but critical" edge cases: empty page list, single-page PDF, password-protected PDF (should throw `PasswordProtectedPdfException`), corrupted file bytes (should throw `CorruptedPdfException`), very large page count (mock, not literally huge in test fixtures). These are the functions most likely to have a real bug and cheapest to test in isolation.
2. **Unit tests — `features/*/application` controllers**: verify state transitions (`selecting → configuring → processing → success/error`), that cancellation sets the right state, that a successful job calls `RecentFilesService.add(...)` exactly once. Services are mocked via `mocktail`.
3. **Widget tests**: one per shared widget (`ProcessingSheet`, `SuccessScreen`, `ErrorStateView`, `PageThumbnailGrid` drag-reorder behavior) plus a smoke test per tool screen ("renders selection state initially", "shows error view when controller.step == error"). Full pixel/golden testing is **not** required at this project's maturity level — skip goldens unless a specific regression justifies adding one later.
4. **Integration test (single, high-value)**: one `integration_test/` flow exercising Images → PDF → Compress end-to-end on a real device/emulator, since this chain touches the most services at once (image pick → compress → assemble → save → share). Add more integration tests opportunistically, not as a mandate.
5. **No CI requirement specified yet** — if/when this project gets a CI pipeline, `flutter test` + `flutter analyze` is sufficient; that's a TASKS.md item for the final-polish phase, not before.

---

## 11. Performance Considerations for Large PDFs/Images

- **Never load a whole PDF into memory as one `Uint8List` unless it's small.** Both Syncfusion's PDF APIs and `pdfx` support page-indexed access — always operate page-by-page or via streaming where the API allows it.
- **Every operation over ~2 seconds runs inside `compute()`** (a background isolate), matching the deterministic-progress requirement in `DESIGN.md` §2.5/Screen 12. Progress is reported back via a `SendPort`/`Stream` so the UI thread never blocks.
- **Thumbnail grids use an LRU bitmap cache** (a small in-memory `LinkedHashMap`-based cache inside `PdfService`, capped e.g. at ~40 rendered thumbnails) so scrolling a 300-page "Manage Pages" grid doesn't re-render or retain every page bitmap simultaneously. Off-screen thumbnails are evicted first.
- **Write outputs to a temp file, then rename into place** — avoids partially-written corrupt output if the app is killed mid-job, and avoids holding the full output bytes in memory just to write them at the end.
- **Image downscaling happens before PDF assembly**, not after — resize/compress each photo via `flutter_image_compress` at pick-time (respecting the user's quality setting) rather than embedding full-resolution camera photos and compressing the whole PDF afterward.
- **Batch operations (Split into N files, PDF→Images export) process and flush one output at a time**, reporting incremental progress ("Exporting page 18 of 34"), rather than holding N outputs in memory until the end.
- **Low-storage check before starting a job**: `FileService` checks available space against a conservative estimate before kicking off compression/export, surfacing the Screen 14 "Device low on storage" warning proactively instead of failing mid-job.

---

## 12. Privacy / Offline Constraints

These are hard constraints, not preferences — violating any of them is a regression:

1. **No `android.permission.INTERNET` in `AndroidManifest.xml`**, ever. This is the single strongest guarantee of the "100% offline" promise and should be treated as a CI/manual-check item before every release.
2. **No analytics, crash reporting, or telemetry SDK** of any kind (no Firebase, no Sentry, no Mixpanel, etc.).
3. **No cloud storage integration** — all file I/O is local device storage via SAF (§6). "Save To Specific Folder…" (Screen 13) means a local folder picker, never a cloud picker.
4. **Every third-party package is vetted for zero network calls at runtime** before being added — this is why the Syncfusion license note in §9 flags "must be verified": license *activation*, if any, must not require a network round-trip at runtime (Syncfusion's Flutter community license is a static key, not a network check, but this should be double-checked against the current package version/ToS before shipping).
5. **The Settings screen's "Privacy Guarantee" card and per-job "Running locally on device — no data leaves your phone" footnote (Screen 12) are not just copy** — they're a standing product commitment that every future feature must uphold. Any new dependency proposal should be checked against this list before it's added to `pubspec.yaml`.

---

## 13. Open Decisions for the Implementation AI

These are intentionally left flexible and should be resolved during Phase 1 (Project Foundation), not before:

- Exact Syncfusion Community License eligibility should be confirmed for the actual publishing entity before Phase 4 (Merge) begins, since that's the first feature depending on it.
- Minimum SDK is stated as 26 in `DESIGN.md`; confirm whether `permission_handler`'s legacy-storage-permission branch is actually needed for the target audience, or whether minSdk can be raised to 29+ to drop that code path entirely (simpler, fewer permission edge cases) — a legitimate simplification if the beginner maintainer agrees.
- Package version pinning (exact version ranges in `pubspec.yaml`) is left to the implementation AI at scaffold time, using latest stable versions of everything in §9.

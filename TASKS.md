# TASKS.md — PDF Toolkit

> Granular task checklist, phase-aligned with `IMPLEMENTATION_PLAN.md`. Check items off as completed. Add new tasks discovered mid-phase to that phase's list rather than silently doing extra work — keep this file the single source of truth for "what's left."
>
> No prior `TASKS.md` existed in the workspace — this is the initial version, created alongside `ARCHITECTURE.md` and `IMPLEMENTATION_PLAN.md`.

---

## Phase 1 — Project Foundation + Navigation
- [ ] `flutter create` project scaffold, Android-only config, minSdk/targetSdk per `DESIGN.md`
- [ ] Add `provider`, `shared_preferences` to `pubspec.yaml`
- [ ] Add dev deps: `flutter_lints`, `mocktail`; configure `analysis_options.yaml`
- [ ] `core/theme/app_colors.dart` — transcribe full token table (`DESIGN.md` §1.1, light + dark)
- [ ] `core/theme/app_typography.dart` — transcribe type scale (`DESIGN.md` §1.2)
- [ ] `core/theme/app_theme.dart` — assemble M3 `ThemeData` (light + dark)
- [ ] `core/constants/spacing.dart` — 8dp grid constants
- [ ] `core/errors/app_exceptions.dart` — all exception classes from `ARCHITECTURE.md` §7
- [ ] `core/errors/error_translator.dart` — map each exception to Screen 14 copy
- [ ] `core/routing/app_router.dart` — route table + placeholder screens for 6 tools, Recent Files, Settings
- [ ] `services/*` — write all 6 abstract service interfaces (no implementations yet)
- [ ] `shared/widgets/error_state_view.dart` (Screen 14 error state)
- [ ] `shared/widgets/empty_state_view.dart` (Screen 14 empty state)
- [ ] Root shell: 3-tab bottom nav with `IndexedStack`
- [ ] `app.dart`: `MaterialApp` + root `MultiProvider` (stub `SettingsController`, `RecentFilesController`)
- [ ] `features/home/`: static tool grid (Screen 1), tapping a card navigates to placeholder route
- [ ] Verify `AndroidManifest.xml` has no `INTERNET` permission
- [ ] Smoke test proving `flutter test` harness runs
- [ ] `flutter analyze` clean
- [ ] Update `AI_HANDOFF.md` for Phase 2 handoff

## Phase 2 — Images → PDF
- [ ] Add `image_picker`, `flutter_image_compress`, `file_picker`, `path_provider`, `permission_handler`, `share_plus`, `open_filex`, `pdf`
- [ ] `services/image_service_impl.dart` (pick, capture, compress, dimensions)
- [ ] `services/file_service_impl.dart` (temp dir, SAF pick/save, share, open, cache size)
- [ ] `services/permission_service_impl.dart` (conditional legacy storage permission for API 26–28)
- [ ] `services/pdf_service_impl.dart`: implement `imagesToPdf` only (other methods `UnimplementedError`)
- [ ] `features/images_to_pdf/application/images_to_pdf_controller.dart` (`ToolStep` state machine)
- [ ] `features/images_to_pdf/presentation/images_to_pdf_screen.dart` (Screen 4: reorderable grid, config sheet, bottom CTA with live estimate)
- [ ] Real `shared/widgets/processing_sheet.dart` (Screen 12)
- [ ] Real `shared/widgets/success_screen.dart` (Screen 13)
- [ ] Give `RecentFilesService` a minimal real (shared_preferences-backed) implementation
- [ ] Wire success path: write Recent Files entry
- [ ] Wire error paths: unsupported file type, low storage
- [ ] Unit tests: `ImageServiceImpl` compression behavior
- [ ] Unit tests: `ImagesToPdfController` state transitions
- [ ] Widget test: screen renders correctly per `ToolStep`
- [ ] Update `AI_HANDOFF.md` for Phase 3 handoff

## Phase 3 — Manage PDF Pages
- [ ] Add `syncfusion_flutter_pdf`, `pdfx`
- [ ] Confirm Syncfusion Community License eligibility for the publishing entity (flagged open decision, `ARCHITECTURE.md` §13)
- [ ] `pdf_service_impl.dart`: implement `loadInfo`, `reorderRotateDeletePages`
- [ ] `pdf_service_impl.dart`: implement `renderPageThumbnail` + LRU bitmap cache
- [ ] `shared/widgets/page_thumbnail_grid.dart` (drag-reorder, rotate/delete icons, multi-select — Screen 2.4)
- [ ] `features/manage_pages/application/manage_pages_controller.dart`
- [ ] `features/manage_pages/presentation/manage_pages_screen.dart` (Screen 9: batch toolbar, Select All/Deselect/Revert, Save CTA)
- [ ] `PopScope` "Discard changes?" dialog wiring
- [ ] Error path: password-protected/corrupted PDF on load
- [ ] Unit tests: page-op edge cases (empty selection, delete-all guard, rotate accumulation)
- [ ] Widget test: thumbnail grid drag-reorder
- [ ] Update `AI_HANDOFF.md` for Phase 4 handoff

## Phase 4 — Merge PDF
- [ ] `pdf_service_impl.dart`: implement `mergePdfs` (bookmark retention, page-number stamping)
- [ ] `services/file_service_impl.dart`: implement `pickMultipleDocuments`
- [ ] `features/merge_pdf/application/merge_pdf_controller.dart`
- [ ] `features/merge_pdf/presentation/merge_pdf_screen.dart` (Screen 5: reorderable source list, thumbnail stack, options toggles)
- [ ] Decide: reuse `page_thumbnail_grid.dart` reorder logic vs. extract `ReorderableSourceList` — document decision in `ARCHITECTURE.md` if it diverges
- [ ] Pre-merge validation: detect password-protected input before starting job
- [ ] Unit tests: merge order correctness, page-count sum, bookmark-retention toggle
- [ ] Update `AI_HANDOFF.md` for Phase 5 handoff

## Phase 5 — Split PDF
- [ ] `pdf_service_impl.dart`: implement `splitPdf` — by-range mode
- [ ] `pdf_service_impl.dart`: implement `splitPdf` — fixed-chunk mode
- [ ] `pdf_service_impl.dart`: implement `splitPdf` — extract-individual-pages mode
- [ ] `pdf_service_impl.dart`: implement `splitPdf` — visual-selection mode
- [ ] `features/split_pdf/application/split_pdf_controller.dart`
- [ ] `features/split_pdf/presentation/split_pdf_screen.dart` (Screen 6: `SegmentedButton` modes, range validation, live output-count summary)
- [ ] Incremental output flushing + per-file progress text
- [ ] Unit tests: range parser (valid/invalid/overlap/out-of-bounds), chunk math, visual-split conversion
- [ ] Update `AI_HANDOFF.md` for Phase 6 handoff

## Phase 6 — PDF → Images
- [ ] Add `archive`
- [ ] `pdf_service_impl.dart`: implement `pdfToImages` (PNG/JPEG, quality slider, DPI selector, page range)
- [ ] ZIP bundling via `archive`
- [ ] `features/pdf_to_images/application/pdf_to_images_controller.dart`
- [ ] `features/pdf_to_images/presentation/pdf_to_images_screen.dart` (Screen 7)
- [ ] Evaluate reusing Split PDF's page-range input widget
- [ ] Verify large-document export stays within memory budget (manual profiling note)
- [ ] Unit tests: DPI/quality → size-estimate formula, ZIP correctness
- [ ] Update `AI_HANDOFF.md` for Phase 7 handoff

## Phase 7 — Compress PDF
- [ ] `pdf_service_impl.dart`: implement `compressPdf` — 3 presets (Extreme/Recommended/Low)
- [ ] `pdf_service_impl.dart`: implement Advanced manual controls (downsample slider, remove-metadata, flatten-annotations)
- [ ] Isolate-based batch recompression with granular progress
- [ ] `features/compress_pdf/application/compress_pdf_controller.dart`
- [ ] `features/compress_pdf/presentation/compress_pdf_screen.dart` (Screen 8: 3 preset cards, Advanced toggle)
- [ ] Document estimated-size computation approach (sampling pass vs. static formula) in `ARCHITECTURE.md`
- [ ] Manual profiling pass: large (50+ MB) image-heavy PDF on low-end emulator profile
- [ ] Unit tests: preset-to-parameter mapping, metadata-strip toggle, annotation-flatten toggle
- [ ] Update `AI_HANDOFF.md` for Phase 8 handoff

## Phase 8 — Recent Files
- [ ] `features/recent_files/presentation/recent_files_screen.dart` (Screen 2: filter chips, search, swipe actions, multi-select batch bar, overflow menu)
- [ ] `RecentFilesService`: handle missing/deleted underlying file gracefully
- [ ] Verify every tool from Phases 2–7 writes the correct `category` for filtering
- [ ] Widget tests: filter-chip logic, swipe-action callbacks, missing-file state
- [ ] Update `AI_HANDOFF.md` for Phase 9 handoff

## Phase 9 — Settings
- [ ] `features/settings/presentation/settings_screen.dart` (Screen 3: theme, defaults, output folder, clear cache, privacy card, about)
- [ ] `services/settings_service_impl.dart` — full real implementation (shared_preferences-backed)
- [ ] Retrofit check: `images_to_pdf` reads defaults from `SettingsController`
- [ ] Retrofit check: `manage_pages` / `merge_pdf` / `split_pdf` / `pdf_to_images` / `compress_pdf` read relevant defaults
- [ ] Clear Cache button: verify it reduces displayed size and frees temp dir
- [ ] Decide on Material You / dynamic color toggle — implement or explicitly defer with a note
- [ ] Update `AI_HANDOFF.md` for Phase 10 handoff

## Phase 10 — Final Polish / Testing
- [ ] Full `flutter analyze` clean pass
- [ ] Full `flutter test` clean pass; close any test gaps flagged in Phases 1–9
- [ ] Integration test: Images→PDF→Compress end-to-end
- [ ] Accessibility pass: 48dp touch targets, WCAG AA contrast spot-check, `Semantics` labels on icon-only buttons
- [ ] Manual predictive-back gesture verification (Android 14+)
- [ ] Low-end device/emulator profiling: Compress + Manage Pages memory footprint
- [ ] Manifest/permission audit: confirm no `INTERNET`, no unused permissions
- [ ] App icon + splash screen
- [ ] Version number set
- [ ] Write repo-root `README.md` (setup + test instructions)
- [ ] Final `AI_HANDOFF.md` update marking project feature-complete

# IMPLEMENTATION_PLAN.md — PDF Toolkit

> Companion to `ARCHITECTURE.md`. This document sequences *how* the architecture gets built, phase by phase, in the exact feature order specified for this project. It does not re-explain architecture decisions — read `ARCHITECTURE.md` first.
>
> Each phase lists: **Goal**, **What gets built**, **New dependencies introduced this phase**, **Depends on**, and **Definition of Done**. Detailed checklists live in `TASKS.md`.

---

## Phase 1 — Project Foundation + Navigation

**Goal**: A running, empty-but-correct app shell that every later phase builds inside, so no future phase re-touches project setup, theming, or navigation scaffolding.

**What gets built**:
- Flutter project scaffold (`flutter create`, Android-only target per `DESIGN.md`, minSdk/targetSdk as specified).
- `core/theme/*`: color tokens, typography scale, and `ThemeData` (light + dark) transcribed exactly from `DESIGN.md` §1.1–1.3 — no interpretation, direct token mapping.
- `core/routing/app_router.dart`: route table with placeholder screens for all 6 tools + Recent Files + Settings.
- Root shell: 3-tab bottom navigation (`Home`, `Recent Files`, `Settings`) using `IndexedStack`.
- `app.dart`: `MaterialApp` + root `MultiProvider` wiring for `SettingsController` and `RecentFilesController` (stubbed with empty/default data — real persistence lands with their own phase below).
- `services/` interfaces (abstract classes) for `PdfService`, `ImageService`, `FileService`, `SettingsService`, `RecentFilesService`, `PermissionService` — **interfaces only**, concrete implementations are added incrementally as each phase needs them, so this phase stays fast and unblocked by PDF-library integration work.
- `core/errors/*`: exception classes + translator, wired to a working `shared/widgets/error_state_view.dart` and `shared/widgets/empty_state_view.dart` (Screen 14) even though nothing throws real errors yet.
- Home screen with the static 2×3 tool grid (Screen 1) navigating to placeholder tool screens.
- `AndroidManifest.xml` reviewed: **no** `INTERNET` permission present; base permissions only.
- Project-level lint config (`flutter_lints`), `analysis_options.yaml`.
- Test harness set up (`flutter_test`, `mocktail` added as dev deps) with one trivial smoke test to prove the harness works.

**New dependencies**: `provider`, `shared_preferences`, `flutter_lints` (dev), `mocktail` (dev).

**Depends on**: nothing (first phase).

**Definition of Done**:
- App builds and runs on an Android emulator/device.
- Bottom nav switches between 3 tabs and preserves each tab's scroll/state.
- Home tool grid renders all 6 tools with correct icons/labels/colors from `DESIGN.md`.
- Tapping a tool card pushes a (placeholder) full-screen route.
- Dark mode toggle (even if Settings UI is a stub) visibly switches the app theme.
- `flutter analyze` and `flutter test` both pass clean.

---

## Phase 2 — Images → PDF

**Goal**: First real, end-to-end working feature — validates the entire pipeline (pick → configure → process in isolate → save via SAF → success/share) that every later tool reuses.

**What gets built**:
- `ImageService` concrete implementation (`image_picker` + `flutter_image_compress`).
- `FileService` concrete implementation: temp dir management, SAF save (`file_picker`'s save-file flow), `share_plus`, `open_filex` wiring.
- `PdfService.imagesToPdf` implementation using `package:pdf` (this is the only `PdfService` method needed this phase — the rest stay unimplemented `UnimplementedError()` stubs until their own phase).
- `features/images_to_pdf/`: controller (`ToolStep` state machine) + screen matching Screen 4 spec (reorderable image grid, config sheet: orientation/margin/page size/quality, sticky bottom CTA with live size estimate).
- Wire-up of `shared/widgets/processing_sheet.dart` and `success_screen.dart` for real (first real consumer).
- On success: write an entry via `RecentFilesService` (first real consumer of that service too — give it a minimal working implementation now, backed by `shared_preferences`, ahead of its own "polish" pass in Phase 8).
- Real error paths: unsupported file type, low storage.

**New dependencies**: `image_picker`, `flutter_image_compress`, `file_picker`, `path_provider`, `permission_handler`, `share_plus`, `open_filex`, `pdf`.

**Depends on**: Phase 1 (shell, theme, routing, error views, service interfaces).

**Definition of Done**:
- User can pick 1+ images (gallery or camera), reorder/rotate/delete them, configure orientation/margin/page size/quality, and generate a real PDF saved to the user-chosen output folder.
- Progress sheet shows during generation for a large (10+ image) batch; Cancel works cleanly.
- Success screen shows correct before/after size, opens correctly in an external viewer, and shares correctly.
- New PDF appears in Recent Files.
- Unit tests: `ImageServiceImpl` compression, `ImagesToPdfController` state transitions. Widget test: screen renders each `ToolStep`.

---

## Phase 3 — Manage PDF Pages

**Goal**: Introduce PDF *mutation* (as opposed to PDF *creation*) via Syncfusion, and the reorderable/rotatable page-thumbnail grid pattern reused by Merge PDF next.

**What gets built**:
- `syncfusion_flutter_pdf` added; `PdfService.loadInfo`, `reorderRotateDeletePages` implemented.
- `pdfx` added; `PdfService.renderPageThumbnail` implemented with the LRU thumbnail cache (`ARCHITECTURE.md` §11).
- `shared/widgets/page_thumbnail_grid.dart` built for real (drag-reorder, rotate/delete icons, multi-select, Screen 2.4 spec) — this becomes a shared component Merge PDF also uses in Phase 4.
- `features/manage_pages/`: controller + screen per Screen 9 spec (sticky batch action toolbar, Select All/Deselect/Revert, "Save New PDF" CTA).
- `PopScope` "Discard changes?" confirmation wired (first real consumer of that pattern from `ARCHITECTURE.md` §8).
- Error path: password-protected / corrupted PDF on load.

**New dependencies**: `syncfusion_flutter_pdf`, `pdfx`.

**Depends on**: Phase 2 (processing/success/error UI plumbing, FileService, RecentFilesService already working).

**Definition of Done**:
- User can open a PDF, see all pages in a 3-column grid with correct page numbers, multi-select, rotate/delete/duplicate/extract via the batch toolbar, reorder by drag, and save the result as a new PDF.
- Leaving the screen with unsaved edits shows the discard-changes dialog; confirming discards, cancelling stays.
- Password-protected/corrupted file shows the correct Screen 14 error with the right copy.
- Unit tests: `PdfServiceImpl` page-op edge cases (empty selection, delete-all-pages guard, rotate accumulation). Widget test: thumbnail grid drag-reorder.

---

## Phase 4 — Merge PDF

**Goal**: Multi-document workflow on top of the now-proven single-document mutation pipeline.

**What gets built**:
- `PdfService.mergePdfs` implementation (Syncfusion — concatenate documents, optional bookmark/outline retention, optional page-number stamping).
- `features/merge_pdf/`: controller + screen per Screen 5 spec (reorderable source-document list, per-file thumbnail stack, "Add PDF Document" dashed button, options toggles, bottom summary).
- Reuses `page_thumbnail_grid.dart`'s drag-reorder logic at the document level (extract a small shared `ReorderableSourceList` if the two diverge enough to warrant it — implementation AI's call, keep it simple).
- Multi-file SAF picking (`FileService.pickMultipleDocuments`).

**New dependencies**: none beyond Phase 3.

**Depends on**: Phase 3 (`PdfService` Syncfusion integration, thumbnail rendering, shared processing/success/error UI).

**Definition of Done**:
- User can add 2+ PDFs, reorder them, toggle bookmark retention and page-number stamping, and merge into one output PDF with the correct combined page count.
- Handles at least one input being password-protected by surfacing the correct per-file error state (Screen 10, State 3) before merge starts, not mid-job.
- Unit tests: merge order correctness, page-count sum correctness, bookmark-retention toggle behavior (mocked).

---

## Phase 5 — Split PDF

**Goal**: The inverse operation of Merge — one input, many outputs — plus the four distinct split-mode UX from the spec.

**What gets built**:
- `PdfService.splitPdf` implementation supporting all four modes: by range, fixed chunk size, extract-individual-pages, visual selection (tap thumbnails to mark split points).
- `features/split_pdf/`: controller + screen per Screen 6 spec (`SegmentedButton` mode switch, range-input validation, live "Will create N output documents" summary).
- Batch output writing: each split output flushed to disk incrementally (per `ARCHITECTURE.md` §11), with progress text ("Creating document 2 of 4").

**New dependencies**: none beyond Phase 3.

**Depends on**: Phase 3.

**Definition of Done**:
- All four split modes produce correct, independently-openable output PDFs with correct page counts.
- Invalid range input (e.g. "1-5, 99") is caught with inline validation before the CTA is enabled, not as a runtime error.
- All outputs appear in Recent Files as separate entries.
- Unit tests: range parser (valid/invalid/overlapping/out-of-bounds inputs), chunk splitter math, visual-split-point-to-ranges conversion.

---

## Phase 6 — PDF → Images

**Goal**: PDF-to-raster export, exercising `pdfx` rendering at export quality (distinct from the lightweight thumbnail rendering already built) plus the ZIP bundling option.

**What gets built**:
- `PdfService.pdfToImages` implementation (format PNG/JPEG, quality slider for JPEG, DPI selector 72/150/300, page range).
- `archive` package integration for the "Bundle into single .ZIP" checkbox.
- `features/pdf_to_images/`: controller + screen per Screen 7 spec, including live file-size estimate as quality/DPI change.

**New dependencies**: `archive`.

**Depends on**: Phase 3 (rendering pipeline), Phase 5 (page-range picker UI can likely be extracted/reused from Split PDF's range input — implementation AI's call).

**Definition of Done**:
- Exports correct page count as individual image files, or as one ZIP, at the selected format/DPI/quality.
- Large (100+ page) documents export without memory spikes — verified against `ARCHITECTURE.md` §11 (page-by-page flush, not all-in-memory).
- Unit tests: DPI/quality → estimated file size formula, ZIP bundling correctness (file count, names).

---

## Phase 7 — Compress PDF

**Goal**: The most performance-sensitive feature (recompresses every embedded image across every page) — deliberately sequenced after the rendering/export pipeline is proven, and second-to-last before polish so real device profiling can happen against a feature-complete app.

**What gets built**:
- `PdfService.compressPdf` implementation: the 3 presets (Extreme/Recommended/Low) mapped to concrete DPI-downsample + quality values, plus the "Advanced" manual controls (manual downsample slider, remove-metadata checkbox, flatten-annotations checkbox).
- `features/compress_pdf/`: controller + screen per Screen 8 spec, including the estimated-size-per-preset display (computed from a quick sampling pass before committing to full compression, or from static preset formulas — implementation AI's call, document whichever is chosen).
- Isolate-based batch image recompression per `ARCHITECTURE.md` §11, with granular progress ("Downscaling image 18 of 34").

**New dependencies**: none beyond Phase 2/3 (`flutter_image_compress`, Syncfusion already present).

**Depends on**: Phase 2 (`flutter_image_compress`), Phase 3 (Syncfusion page access).

**Definition of Done**:
- All 3 presets produce correctly-scaled output size reductions in the right direction/order (Extreme < Recommended < Low in output size).
- Advanced manual controls override the preset correctly.
- Compressing a large (50+ MB, image-heavy) PDF stays responsive (progress updates visible, UI thread not blocked) and completes without OOM on a low-end test device/emulator profile.
- Unit tests: preset-to-parameter mapping, metadata-strip toggle, annotation-flatten toggle (mocked at the service boundary).

---

## Phase 8 — Recent Files

**Goal**: Elevate the minimal `RecentFilesService` used internally since Phase 2 into the full user-facing feature — filtering, search, batch actions, swipe gestures.

**What gets built**:
- `features/recent_files/`: full screen per Screen 2 spec — filter chips (All/Merged/Converted/Compressed — derived from the `category` field every tool already writes on save), search bar, swipe-to-delete/swipe-to-share, multi-select batch bar, overflow menu (Share/Rename/Delete/Open externally).
- Robustness pass on `RecentFilesService`: handle the case where a recorded file's underlying path no longer exists (user deleted it externally) — show it as a broken/missing entry with a "Remove from list" action rather than crashing.

**New dependencies**: none.

**Depends on**: Phases 2–7 (needs real entries from every tool to be meaningfully testable).

**Definition of Done**:
- Every completed tool job from Phases 2–7 appears correctly categorized in Recent Files.
- Filtering, search, swipe actions, and batch multi-select all work against real data.
- Deleting a file externally (simulated in test) doesn't crash the list.
- Widget tests: filter-chip logic, swipe-action callbacks, missing-file graceful state.

---

## Phase 9 — Settings

**Goal**: Make the previously-stubbed `SettingsController`/`SettingsService` fully real and wire its values into every tool that reads defaults (DPI, quality, output folder).

**What gets built**:
- `features/settings/`: full screen per Screen 3 spec (theme selector, default compression/format/DPI, output-folder SAF picker, clear-cache button with live MB display, Privacy Guarantee card, About section).
- Retrofit pass: confirm every tool screen actually reads its defaults from `SettingsService` rather than hardcoded values (this is a cross-cutting check across Phases 2–7's code, tracked as explicit tasks in `TASKS.md`).
- Material You / dynamic color toggle (Android 12+), if the implementation AI confirms a low-risk package/approach exists at build time — otherwise deferred with a note, not a blocker.

**New dependencies**: none required; `dynamic_color` only if the Material You toggle is pursued (optional, document the decision either way).

**Depends on**: Phases 2–7 (retrofitting their default-reading behavior).

**Definition of Done**:
- Changing any setting (theme, default DPI/quality/format, output folder) visibly affects the next run of the relevant tool.
- Clear Cache button reduces the displayed cache size and actually frees temp-dir space.
- Privacy Guarantee card copy matches the standing commitments in `ARCHITECTURE.md` §12.

---

## Phase 10 — Final Polish / Testing

**Goal**: Cross-cutting hardening pass — not new features.

**What gets built**:
- Full `flutter analyze` + `flutter test` clean pass; fill any test gaps identified across Phases 1–9 (see `TASKS.md` for a running gap list to be maintained per-phase).
- The single high-value integration test (`ARCHITECTURE.md` §10 item 4): Images→PDF→Compress end-to-end.
- Accessibility pass: 48dp touch targets verified, WCAG AA contrast spot-checked against the token table, `Semantics` labels added where icons-only buttons exist.
- Predictive-back gesture manual verification on Android 14+.
- Low-end device/emulator profiling pass (older API level, constrained RAM) focused on Compress and Manage Pages (largest memory footprints per `ARCHITECTURE.md` §11).
- Final manifest/permission audit: confirm no `INTERNET` permission, no unused permissions requested.
- App icon, splash screen, version number, `README.md` for the repo itself (setup instructions, how to run tests) — this is the first point a human-facing project README is needed, deliberately deferred to avoid churn while structure was still settling.
- Play Store listing prep is **out of scope** unless explicitly requested later.

**New dependencies**: none expected; any last-mile dependency (e.g. an app-icon-generation dev tool) should be added with the same one-line justification convention as §9 of `ARCHITECTURE.md`.

**Depends on**: all prior phases complete.

**Definition of Done**: app is feature-complete per `DESIGN.md`, all automated tests pass, manual QA checklist in `TASKS.md` Phase 10 is fully checked off.

---

## Cross-Phase Notes

- **Recent Files and Settings are used (minimally) starting in Phase 2**, even though their own dedicated phases are #8 and #9. This is intentional — every tool needs to write to Recent Files and read defaults from Settings from day one; phases 8–9 are about building out their *own* full-featured screens, not about first wiring the data flow.
- **No phase should require reopening `ARCHITECTURE.md`'s structural decisions.** If a phase's implementer finds the folder structure, state pattern, or service boundaries don't fit reality, stop and update `ARCHITECTURE.md` explicitly (with reasoning) rather than quietly diverging — keep the docs and the code honest with each other.
- **Each phase ends with an `AI_HANDOFF.md` update** (see that file's own template) so the next phase's implementer — human or AI — has a clean, current starting point without needing to re-derive context from the whole conversation history.

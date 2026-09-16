# AI_HANDOFF.md — PDF Toolkit

> Read this file first, every session. It's the single source of truth for "where things stand" — update it at the end of every phase (see `IMPLEMENTATION_PLAN.md` Cross-Phase Notes).

---

## What was done in this session (Architecture pass)

No Flutter repository existed yet — only `DESIGN.md` (UI/UX spec) was present, with no README or prior `AI_HANDOFF.md`. This session did **not** touch UI/UX and did **not** implement any features. It produced the architecture layer the implementation AI builds from:

1. **`ARCHITECTURE.md`** — folder structure, feature/module boundaries, state management choice, PDF/image service boundaries, storage strategy, permission strategy, error handling, navigation approach, dependency recommendations (with rejected alternatives), testing strategy, performance considerations, and privacy/offline constraints.
2. **`IMPLEMENTATION_PLAN.md`** — the 10-phase build sequence (fixed order, as specified), each phase with Goal / What gets built / New dependencies / Depends on / Definition of Done.
3. **`TASKS.md`** — granular checklist per phase, mirroring `IMPLEMENTATION_PLAN.md`.
4. **`AI_HANDOFF.md`** (this file) — created for the first time.

## Important decisions

- **Feature-first folder structure** (`lib/features/<tool>/application|presentation`), not layer-first — see `ARCHITECTURE.md` §2.
- **State management: `provider` + `ChangeNotifier`**, not Riverpod/BLoC — chosen for minimal boilerplate and beginner debuggability (§4).
- **Navigation: built-in `Navigator` with named routes**, no `go_router` — the nav graph is shallow and linear (§8).
- **PDF library split**: `syncfusion_flutter_pdf` for mutating existing PDFs (merge/split/rotate/delete pages), `package:pdf` for building new PDFs (Images → PDF), `pdfx` for rasterizing pages to bitmaps (thumbnails/export/preview). Rationale and rejected alternatives in §9.
- **⚠️ Syncfusion Community License must be verified** against the actual publishing entity's revenue before Phase 4 (Merge PDF) begins — flagged as an open decision in `ARCHITECTURE.md` §13.
- **Storage**: three separate concerns — temp working dir (`path_provider`), user-visible outputs via SAF only, app metadata (settings + recent-files pointers, not files) via `shared_preferences`. No database at project start (§6).
- **All file/PDF/image third-party packages are wrapped behind one service interface each** — features never import a plugin directly (§5).
- **Zero network permission, zero analytics/telemetry, zero cloud** — treated as hard constraints, not preferences (§12).

## Dependencies (see `ARCHITECTURE.md` §9 for full justification table)

`provider`, `shared_preferences`, `syncfusion_flutter_pdf`, `pdf`, `pdfx`, `image_picker`, `flutter_image_compress`, `file_picker`, `path_provider`, `permission_handler`, `share_plus`, `open_filex`, `archive`; dev: `flutter_lints`, `mocktail`.

Explicitly excluded: any HTTP client, analytics/crash SDK, cloud storage SDK, ads SDK, `go_router`, `riverpod`, `bloc`, `sqflite`/`hive` (deferred), `dio`/`http`.

## Next task

**Phase 1 — Project Foundation + Navigation** (see `IMPLEMENTATION_PLAN.md` and `TASKS.md`, both top section). Nothing has been scaffolded yet — this is a true greenfield start. Definition of Done for Phase 1 is listed in `IMPLEMENTATION_PLAN.md`.

## Files the implementation AI must read, in order

1. `AI_HANDOFF.md` (this file) — current status.
2. `DESIGN.md` — the UI/UX spec. Source of truth for anything visual; never redesign it.
3. `ARCHITECTURE.md` — the technical contract. Don't diverge from its structural decisions without updating it explicitly (see `IMPLEMENTATION_PLAN.md` Cross-Phase Notes).
4. `IMPLEMENTATION_PLAN.md` — find the current phase's section for Goal/scope/Definition of Done.
5. `TASKS.md` — the actual checklist to work through and check off for the current phase.

## Handoff protocol

At the end of each phase, update this file's "What was done," "Next task," and "Important decisions" (append, don't erase history that's still relevant) before ending the session — so the next phase starts without needing to re-derive context.

# DESIGN.md — PDF Toolkit (Android-First UI/UX Specification)

> **Document Purpose**: Complete architectural UI/UX, Design System, and Screen Specification for the multi-AI Flutter Android application **PDF Toolkit**.  
> **Target Platform**: Android (Material 3 Expressive, phone-optimized, min SDK 26+, target SDK 34+).  
> **Core Tenet**: 100% offline & local execution, privacy-first, zero telemetry, fast utility-grade workflows.

---

## 1. Design System & Design Tokens

### 1.1 Color Foundations & Tokens

The palette is rooted in a refined Material 3 "Crimson Sheet" theme. Crimson anchors the universal "PDF" document identity while neutral slate surfaces ensure high data density, readability, and battery efficiency in Dark Mode.

| Token Name | Light Mode Hex | Dark Mode Hex | Usage / Semantic Role |
| :--- | :--- | :--- | :--- |
| `md.sys.color.primary` | `#BA1A1A` | `#FFB4AB` | Key CTAs, primary active state, brand touchpoints |
| `md.sys.color.on-primary` | `#FFFFFF` | `#690005` | Text/icons on primary button |
| `md.sys.color.primary-container` | `#FFDAD6` | `#93000A` | Tonal badge backgrounds, selected tool card tint |
| `md.sys.color.on-primary-container`| `#410002` | `#FFDAD6` | Text/icons on primary container |
| `md.sys.color.secondary` | `#775653` | `#E7BDB8` | Secondary chips, subtle badges, filters |
| `md.sys.color.on-secondary` | `#FFFFFF` | `#442927` | Text/icons on secondary elements |
| `md.sys.color.secondary-container`| `#FFDAD6` | `#5D3F3C` | Inactive tool card surfaces, secondary pills |
| `md.sys.color.surface` | `#FCF8F8` | `#1A1110` | Main canvas / scaffold background |
| `md.sys.color.on-surface` | `#201A1A` | `#F1DFDD` | Primary text, titles, prominent icons |
| `md.sys.color.on-surface-variant`| `#534341` | `#D8C2BF` | Secondary body text, timestamps, file sizes |
| `md.sys.color.surface-container-lowest` | `#FFFFFF` | `#140C0B` | Deep cards (elevated in light mode, pure deep in dark) |
| `md.sys.color.surface-container-low`    | `#F6F2F2` | `#231918` | Standard tool cards, inactive drop zones |
| `md.sys.color.surface-container`        | `#F1ECEC` | `#271D1C` | Bottom navigation bar, bottom sheets |
| `md.sys.color.surface-container-high`   | `#EBE6E6` | `#322827` | Dialogs, elevated sheets, input fields |
| `md.sys.color.surface-container-highest`| `#E5E1E1` | `#3D3231` | Pill active backgrounds, subtle dividers |
| `md.sys.color.outline` | `#857371` | `#A08C8A` | Outlined button borders, inactive card outlines |
| `md.sys.color.outline-variant` | `#D8C2BF` | `#534341` | Hairline dividers (0.5dp/1dp), thumbnail outlines |
| `md.sys.color.error` | `#BA1A1A` | `#FFB4AB` | Error badges, destructive delete action |
| `md.sys.color.success` | `#1E8E3E` | `#81C995` | Success state checkmarks, batch completion badge |
| `md.sys.color.surface-privacy` | `#0D652D` | `#81C995` | "100% Offline / Local" badge accent |

---

### 1.2 Typography System (Material 3 Scale)

Default font family: **Roboto** (system native on Android) or **Inter** fallback.

| Style Role | Font Weight | Size (sp) | Line Height (sp) | Tracking | Use Case |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `displaySmall` | Bold (700) | 36 | 44 | 0 | Hero metric / result summary |
| `headlineMedium`| SemiBold (600) | 28 | 36 | 0 | Top-level screen title (Home, Success) |
| `headlineSmall` | SemiBold (600) | 24 | 32 | 0 | Modal sheet titles, Section titles |
| `titleLarge` | Medium (500) | 22 | 28 | 0 | TopAppBar screen title |
| `titleMedium` | Medium (500) | 16 | 24 | +0.15 | Tool card titles, dialog titles |
| `titleSmall` | Medium (500) | 14 | 20 | +0.1 | Card subheaders, list item headers |
| `bodyLarge` | Regular (400) | 16 | 24 | +0.5 | Detailed descriptions, settings items |
| `bodyMedium` | Regular (400) | 14 | 20 | +0.25 | Subtitles, file metadata (size, date) |
| `bodySmall` | Regular (400) | 12 | 16 | +0.4 | Footnotes, path hints, offline pill label |
| `labelLarge` | Medium (500) | 14 | 20 | +0.1 | Primary button text, tab labels |
| `labelMedium` | Medium (500) | 12 | 16 | +0.5 | Chip text, badge text, page numbers |
| `labelSmall` | Medium (500) | 11 | 16 | +0.5 | Micro timestamps, badge counts |

---

### 1.3 Spacing, Grid & Shape Foundations

- **8dp Base Grid**: All margins, paddings, and component sizes snap to an 8dp cadence (4dp, 8dp, 12dp, 16dp, 24dp, 32dp, 48dp).
- **Page Horizontal Margin**: Standard `16dp` padding on mobile edges.
- **Section Spacing**: `24dp` between distinct card groups.
- **Item Gap**: `12dp` between cards in grid/list.
- **Touch Target Rule**: **Minimum 48dp × 48dp** interactive touch target on all clickable components (buttons, icon buttons, checkboxes, drag handles).
- **Corner Radii (Material 3)**:
  - Small elements (chips, text inputs): `8dp` (`rounded-lg`)
  - Tool cards, file cards: `16dp` (`rounded-2xl`)
  - Modal sheets, preview dialogs: `24dp` top corners (`rounded-t-3xl`)
  - Primary FAB / CTA pill: `16dp` or `28dp` (full capsule)

---

## 2. Component System & Interaction Rules

### 2.1 Top App Bar (M3 CenterAligned / Small)
- Leading: Navigation icon (Back arrow `arrow_back` for tool flows, or Drawer/Search on Home).
- Title: Clean `titleLarge` with optional subtitle (`bodySmall`) for page counts or step indicators (e.g., "Merge PDF • 3 files").
- Trailing actions: Contextual action icon (e.g., Select All, Clear, Overflow menu `more_vert`).
- Elevation: `0dp` flat on rest; elevates with subtle container color when scrolling content passes underneath.

### 2.2 Tool Grid Cards
- Dimensions: 2-column responsive grid on phone screen.
- Anatomy:
  - Squircle icon container (48dp × 48dp) tinted in `primary-container` with `primary` glyph.
  - Tool name (`titleMedium`).
  - Short 1-line helper text (`bodySmall`, on-surface-variant, e.g., "Combine 2+ documents").
- Ripple effect: Standard M3 state layer ripple with bounded radius `16dp`.

### 2.3 Primary Bottom Action Bar (Persistent Sticky CTA)
- Fixed at the bottom above Android system navigation gesture bar.
- Container: `surface` with top hairline border (`outline-variant`) or floating capsule with `elevation-3`.
- Primary CTA: Height `52dp`, full width (minus 32dp margin), `FilledButton` style with clear verb (e.g., "Merge 3 PDFs", "Compress Now (Estimated -45%)", "Convert to Images").
- Secondary dismiss/cancel or settings icon sits alongside when applicable.

### 2.4 Reorderable Page Thumbnail Grid
- Used in *Manage PDF Pages* and *Merge PDF*.
- Card: Aspect ratio 1:1.414 (standard ISO A4 proportions).
- Page Number: Circular badge (`labelSmall`) positioned bottom-center or top-left.
- Drag & Drop affordance: Subtle grip indicator icon `drag_indicator` on card header or long-press vibration feedback (Haptic `HapticFeedbackType.mediumImpact`).
- Selection Checkbox: Circular 24dp checkmark pill in top-right corner with high contrast white-on-primary fill.
- Action Buttons per item: Rotate 90° (`rotate_right`), Delete (`delete_outline`).

### 2.5 Progress & Loading Component (Deterministic & Indeterminate)
- Circular M3 indicator (48dp diameter, stroke width 4dp) or Linear Progress Bar with smooth transitions.
- Must display current stage text (`bodyMedium`): e.g., "Reading page 14 of 42…", "Downscaling images (DCT 75%)…".
- Explicit percentage label (`titleMedium` bold).
- "Cancel" outlined button always present during long jobs.

---

## 3. Information Architecture & Navigation Structure

```
[PDF Toolkit]
│
├── [Tab 1: Home / Tools] ─── (Default Screen)
│     ├── Privacy & Offline Status Header ("100% Offline • Private")
│     ├── Quick Actions (Recent tool shortcuts)
│     ├── Tool Grid (6 Core utilities: Images→PDF, Merge, Split, PDF→Images, Compress, Manage Pages)
│     └── Storage / Cache Quick Indicator
│
├── [Tab 2: Recent Files]
│     ├── Filter Chips (All, Generated, Compressed, Merged)
│     ├── File List Item (Thumbnail preview, Name, Size, Date, Action menu)
│     └── Search & Batch Select Bar
│
├── [Tab 3: Settings]
│     ├── Theme Mode (System, Light, Dark)
│     ├── Storage & Output Folder (Scoped storage paths)
│     ├── Image Quality & Default DPI (150 DPI, 300 DPI)
│     ├── Privacy Statement (Explicit confirmation: Zero tracking, no network permission)
│     └── App Info & Version
│
└── [Utility Workflows] (Launched from Home)
      ├── 1. File Selection / Import Modal
      ├── 2. Tool Configuration & Preview Workspace
      ├── 3. Processing Sheet (Deterministic Progress)
      ├── 4. Success Screen (Share, Open, Save To)
      └── 5. Error & Fallback States
```

---

## 4. Comprehensive Screen-by-Screen Specification

### Screen 1: Home (Main Dashboard)
- **Header**:
  - App wordmark "PDF Toolkit" with red doc emblem.
  - "Offline • Secure" pill badge (green dot + lock icon `verified_user`).
  - Trailing buttons: Quick Search icon and Settings cog.
- **Hero Card**:
  - "Local & Instant Document Engine" banner with prominent "Pick a Document" quick import button.
- **Grid of Tools (2 Columns × 3 Rows)**:
  1. **Images → PDF**: "Convert photos & scans to document" (Icon: `photo_library`).
  2. **Merge PDF**: "Combine multiple PDFs into one" (Icon: `call_merge`).
  3. **Split PDF**: "Extract pages or split into parts" (Icon: `call_split`).
  4. **PDF → Images**: "Export pages as PNG/JPG" (Icon: `image`).
  5. **Compress PDF**: "Reduce file size with smart quality" (Icon: `compress`).
  6. **Manage Pages**: "Reorder, rotate, or delete pages" (Icon: `view_module`).
- **Recent Activity Quick Peek**:
  - Horizontal carousel or top 2 recent files with relative timestamps ("10m ago", "Yesterday").
- **Navigation Bar**: Bottom 3 tabs [Tools (Home), Recent, Settings].

---

### Screen 2: Recent Files
- **App Bar**: Title "Recent Files", Search bar input, multi-select check icon.
- **Filter Row**: Horizontal scrollable FilterChips: `[ All ]`, `[ Merged ]`, `[ Converted ]`, `[ Compressed ]`.
- **List Items**:
  - Left: PDF page 1 thumbnail preview (48dp × 64dp, rounded-md, bordered).
  - Center: File name (`titleSmall`, truncated), File size + Page count + Date (`bodySmall`).
  - Right: `more_vert` overflow button (Share, Rename, Delete, Open in External Viewer).
- **Swipe Actions**: Swipe left to Delete, Swipe right to Share.

---

### Screen 3: Settings
- **App Bar**: Title "Settings", Back button to Home.
- **Sections**:
  1. **Appearance**:
     - Theme selector: Radio items or SegmentedButton: [ System Default | Light | Dark ].
  2. **Defaults & Performance**:
     - Default PDF Compression level: Slider/Dropdown (Low 70%, Recommended 50%, High 30%).
     - Image Export Format: [ PNG (Lossless) | JPG (Compressed) ].
     - Default Render Resolution: [ 150 DPI (Fast) | 300 DPI (Print Quality) ].
  3. **Storage & Privacy**:
     - Output Folder path selector (Android SAF - Storage Access Framework).
     - Clear Cache button (displays current MB used).
     - "Privacy Guarantee" Card: Explains local processing, zero network calls, zero analytics.
  4. **About**:
     - Version, Open Source Licenses, Offline verification checklist.

---

### Screen 4: Images → PDF
- **Step 1: Selection Preview**:
  - Top: Reorderable grid of selected images.
  - "+ Add More Images" floating or inline card.
  - Thumbnail overlays: Drag handle, delete badge, rotate button.
- **Step 2: Configuration Sheet (Bottom/Collapsible)**:
  - Page Orientation: [ Portrait | Landscape | Auto ].
  - Margin: [ None | Small (8mm) | Normal (15mm) ].
  - Page Size: [ Match Image | A4 | US Letter ].
  - Compression / Quality: [ High | Medium | Compact ].
- **Bottom Bar**:
  - Summary: "8 images selected • Est. 4.2 MB".
  - CTA Button: `FilledButton` "Generate PDF".

---

### Screen 5: Merge PDF
- **Source List**:
  - Vertical list of PDF documents with drag handle `drag_handle` on the left for reordering sequence.
  - Document tile shows: File title, total pages, file size, thumbnail stack.
  - "Add PDF Document" prominent dashed button at list end.
- **Options**:
  - Retain bookmarks/outline toggle (`Switch`).
  - Add page number stamp toggle.
- **Bottom Bar**:
  - Summary: "3 files • 48 total pages".
  - CTA Button: "Merge into Single PDF".

---

### Screen 6: Split PDF
- **Document Header**:
  - Active file name, total pages (e.g., "Report_Q3.pdf • 34 Pages").
- **Split Modes (SegmentedButton)**:
  - **Option A: By Range** (e.g., "1-5, 8, 12-20" text input with validation hint).
  - **Option B: Fixed Chunks** ("Split every `[ 5 ]` pages").
  - **Option C: Extract Individual Pages** (creates single-page PDFs).
  - **Option D: Visual Selection** (tap thumbnails to select split points).
- **Bottom Bar**:
  - Summary: "Will create 4 output documents".
  - CTA Button: "Split Document".

---

### Screen 7: PDF → Images
- **Source File Card**: Preview of document with page counter.
- **Export Configuration**:
  - Format: SegmentedButton `[ PNG ]` vs `[ JPEG ]`.
  - Quality Slider (when JPEG selected): 50% - 100% with live file size estimate.
  - DPI Selector: `[ 72 DPI (Screen) | 150 DPI (Standard) | 300 DPI (High Res) ]`.
  - Page Range: `[ All Pages (12) | Custom Range ]`.
- **Packaging Option**:
  - Checkbox: "Bundle into single .ZIP file".
- **Bottom Bar**:
  - CTA Button: "Export 12 Images".

---

### Screen 8: Compress PDF
- **Source File Card**:
  - File name, original file size (e.g., "Contract_Signed.pdf • 18.4 MB").
- **Compression Presets (3 Selectable Cards)**:
  1. **Extreme Compression**: Lowest quality (72 DPI, heavy compression), best for email limits. Estimated ~3.2 MB (-82%).
  2. **Recommended (Balanced)**: Good clarity (150 DPI, medium compression), ideal for viewing. Estimated ~7.1 MB (-61%).
  3. **Low Compression**: High fidelity (200+ DPI, light compression), best for printing. Estimated ~12.5 MB (-32%).
- **Advanced Toggle**:
  - Manual image downsampling slider, remove metadata checkbox, flatten annotations checkbox.
- **Bottom Bar**:
  - CTA Button: "Compress Document".

---

### Screen 9: Manage PDF Pages
- **Interactive Full Grid**:
  - 3-column scrollable grid of all document pages.
  - Each thumbnail shows: Page number label, rotate icon, delete icon.
  - Multi-select mode: Tap to toggle selection badge.
- **Sticky Batch Action Toolbar**:
  - Displays when 1+ pages selected:
  - `[ Rotate 90° ]` `[ Extract ]` `[ Duplicate ]` `[ Delete (Red) ]`.
- **Top Bar Actions**: "Select All", "Deselect", "Revert Changes".
- **Bottom Bar**:
  - Summary: "24 of 28 pages kept".
  - CTA Button: "Save New PDF".

---

### Screen 10: File Selection / Import States
- **State 1: Empty Drop Target / SAF Picker Launcher**:
  - Clean container with dashed outline (`outline-variant`).
  - Red doc import icon, "Tap to browse files" label, "Supported: PDF, JPG, PNG".
  - "100% on-device file access (Storage Access Framework)".
- **State 2: Multi-File Selection State**:
  - Horizontal chip list of selected files with remove `(×)` icon.
  - File size counter & total count.
- **State 3: Invalid File Warning**:
  - Inline error banner: "Password-protected PDFs require unlocking before merging" with "Unlock" action.

---

### Screen 11: PDF / Page Preview States
- **Full-Screen Single Page Reader / Inspector**:
  - Clean black or neutral background.
  - Pinch-to-zoom support indicator.
  - Bottom scrubber bar: Page slider (e.g., "Page 7 of 42").
  - Top action bar: Fit to Width, Fit to Page, Rotate.
- **Multi-Page Overview Mode**:
  - Toggle between single continuous scroll and grid overview.

---

### Screen 12: Processing / Progress State
- **Modal Overlay / Centered Full Sheet**:
  - App keeps screen awake during long multi-page renders.
  - Large circular M3 indicator with pulsing center icon.
  - Title: "Compressing Document…".
  - Subtitle / Stage: "Downscaling image 18 of 34 (48% complete)".
  - Real-time LinearProgressIndicator bar with smooth animation.
  - "Running locally on device — No data leaves your phone" privacy footnote.
  - Outlined "Cancel" button with safe thread abort.

---

### Screen 13: Success State
- **Centered Celebration & Action Sheet**:
  - Animated checkmark badge (`success` green circle with check `check_circle`).
  - Title: "PDF Generated Successfully!".
  - Stat Comparison Badge: "Original: 18.4 MB → New: 5.2 MB (Saved 71%)".
  - Output File Name and local directory link ("Saved to: Documents/PDF_Toolkit/").
- **Primary Actions (Stacked Vertical)**:
  1. Primary Filled Button: "Open Document" (Launches Android Intent default viewer).
  2. Secondary Tonal Button: "Share File" (Standard Android Share Sheet Intent).
  3. Outlined Button: "Save To Specific Folder…".
  4. Flat Text Button: "Done / Back to Home".

---

### Screen 14: Error & Empty States
- **Empty State (e.g., No Recent Files)**:
  - Subtle grayscale illustration / icon (`folder_open`).
  - Headline: "No recent documents yet".
  - Body: "Files created or modified using PDF Toolkit will appear here for easy access."
  - Action Button: "Start a New Task".
- **Error State (e.g., Corrupted PDF or Low Storage)**:
  - Red error pill icon (`error_outline`).
  - Title: "Unable to process document".
  - Explanation: "This PDF file has a corrupted cross-reference table or is password encrypted."
  - Action Buttons: `[ Try Another File ]` `[ Read Recovery Guide ]`.
- **Low Memory / Out of Storage Warning**:
  - Warning banner (`warning_amber`): "Device low on storage. Free up 50 MB to complete conversion."

---

## 5. Android Navigation & Gesture Architecture

1. **Back Navigation (Predictive Back Gesture)**:
   - All tool screens support standard Android 14+ Predictive Back gesture.
   - If unsaved changes exist in *Manage Pages* or *Merge PDF*, trigger a confirmation dialog:  
     *Title*: "Discard changes?"  
     *Body*: "Your page edits will be lost if you leave now."  
     *Actions*: `[ Cancel ]` `[ Discard ]` (destructive red).
2. **Bottom Navigation Behavior**:
   - 3 destinations: Home, Recent Files, Settings.
   - Preserves state when switching between tabs.
   - Hides navigation bar during active tool workflows (e.g., during Manage Pages or Preview) to maximize screen real estate.
3. **Floating Action / Sticky Bottom Bars**:
   - Always respects Android gesture inset (`MediaQuery.of(context).padding.bottom + 16dp`).

---

## 6. Light & Dark Mode Behavior

- **Contrast Ratios**: Strictly WCAG AA compliant (>4.5:1 for body text, >3:1 for large headlines and UI controls).
- **Light Theme**:
  - Crisp, paper-like surface `#FCF8F8` with subtle warm white cards `#FFFFFF`.
  - Dividers are soft `#D8C2BF` to avoid visual clutter.
- **Dark Theme (AMOLED-friendly)**:
  - Main background `#1A1110` / surface `#231918` with true black accents to save OLED battery during intensive document rendering.
  - Document thumbnail canvas renders with a 1dp subtle border to maintain visibility against dark backdrops.
- **Dynamic Color (Android Material You)**:
  - System is designed with an explicit fallback to crimson primary for PDF identity, but supports Android 12+ Monet dynamic theming toggle in Settings.

---

## 7. Crucial UX Decisions & Offline Implementation Notes

1. **Zero Network Calls & Privacy by Design**:
   - The app does not request `android.permission.INTERNET`.
   - All compression, rendering, splitting, and merging must execute via local C++/Dart bindings or Android platform APIs (e.g., `PdfRenderer`, `PdfDocument`).
2. **Storage Access Framework (SAF)**:
   - Use Android SAF (`Intent.ACTION_OPEN_DOCUMENT`, `Intent.ACTION_CREATE_DOCUMENT`) to guarantee privacy and avoid legacy broad storage permissions.
3. **Memory Safety on Low-End Devices**:
   - Avoid loading all PDF pages into RAM simultaneously.
   - Thumbnail grids must paginate or lazy-load cached bitmap previews with LRU cache.
   - Show deterministic progress bars for jobs exceeding 2 seconds so the user knows processing is progressing smoothly.
4. **Touch Ergonomics**:
   - All primary triggers reside in the bottom "thumb zone" (bottom 40% of the screen).
   - Top area is reserved for titles, page counts, and non-destructive viewing controls.

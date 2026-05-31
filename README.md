# SkipNotes — Cross-Platform POC

> **Status: POC / Work in Progress**
> This project is a proof of concept built for a client evaluation. It explores whether a single Swift/SwiftUI codebase can deliver a native experience on both iOS and Android using [Skip.tools](https://skip.tools) (Skip Fuse mode). The architecture is complete and the Swift build is clean — active blockers are documented below.

---

SkipNotes is a notes app that stores content locally as JSON, requires no backend, and enforces strict layer separation so that UI, domain logic, and persistence concerns never bleed into each other. The goal is to validate whether Skip Fuse can reduce mobile development time without sacrificing native quality.

## Architecture

### Layer Overview

```
 ╔══════════════════════════════════════════════════════════════╗
 ║  VIEWS  (SwiftUI — SkipFuseUI)                               ║
 ║                                                              ║
 ║   NoteListView          NoteRowView         NoteEditorView   ║
 ║   ┌──────────────┐      ┌───────────┐       ┌────────────┐   ║
 ║   │ @State       │      │ let note  │       │ @Binding   │   ║
 ║   │ vm: Notes    │─────▶│ :NoteData │       │ note:      │   ║
 ║   │ ViewModel    │      └───────────┘       │ NoteData   │   ║
 ║   └──────┬───────┘                          └─────┬──────┘   ║
 ╚══════════╪════════════════════════════════════+═══╪════════+═╝
            │ reads / mutates                        │ saves
            ▼                                        ▼
 ╔══════════════════════════════════════════════════════════════╗
 ║  DOMAIN                                                      ║
 ║                                                              ║
 ║   ┌─────────────────────┐     ┌──────────────────────────┐   ║
 ║   │   NotesViewModel    │────▶│  NoteRepositoryProtocol  │   ║
 ║   │   @Observable       │     │  ─────────────────────── │   ║
 ║   │ ─────────────────   │     │  fetchAll() → [NoteData] │   ║
 ║   │ notes: [NoteData]   │     │  save(_ note: NoteData)  │   ║
 ║   │ errorMessage:String?│     │  delete(id: UUID)        │   ║
 ║   │ ─────────────────   │     └──────────────────────────┘   ║
 ║   │ loadNotes()         │                  ▲                 ║
 ║   │ saveNote(_:)        │                  │ conforms        ║
 ║   │ deleteNote(id:)     │                  │                 ║
 ║   │ newNote()           │     ┌────────────┴───────────-──┐  ║
 ║   └─────────────────────┘     │        NoteData           │  ║
 ║                               │  ───────────────────────- │  ║
 ║                               │  id: UUID                 │  ║
 ║                               │  content: String          │  ║
 ║                               │  createdAt / updatedAt    │  ║
 ║                               │  ───────────────────────  │  ║
 ║                               │  title: String  (computed)│  ║
 ║                               │  body: String   (computed)│  ║
 ║                               │  previewBody: String      │  ║
 ║                               └─────────────────────────-─┘  ║
 ╚══════════════════════════════════════════════════════════════╝
            │ conforms to NoteRepositoryProtocol
            ▼
 ╔══════════════════════════════════════════════════════════════╗
 ║  DATA                                                        ║
 ║                                                              ║
 ║   ┌──────────────────────────┐    ┌─────────────────────-──┐ ║
 ║   │  LocalNoteRepository     │    │      NoteEntity        │ ║
 ║   │  ──────────────────────  │    │  ───────────────────── │ ║
 ║   │  fetchAll() → [NoteData] │───▶│  id: UUID              │ ║
 ║   │  save(_ note: NoteData)  │    │  content: String       │ ║
 ║   │  delete(id: UUID)        │    │  createdAt: Date       │ ║
 ║   │  ──────────────────────  │    │  updatedAt: Date       │ ║
 ║   │  loadEntities() private  │    │  ───────────────────── │ ║
 ║   │  persist(_:)   private   │    │  Codable ✓             │ ║
 ║   └────────────┬─────────────┘    │  NoteRepresentable ✓   │ ║
 ║                │ maps             └─────────────────────-──┘ ║
 ║                │ NoteEntity ↔ NoteData                       ║
 ║                ▼                                             ║
 ║         FileManager.default                                  ║
 ║         documents/notes.json  (atomic write)                 ║
 ╚══════════════════════════════════════════════════════════════╝
            ▲ all layers import
 ╔══════════════════════════════════════════════════════════════╗
 ║  SHARED  (Foundation only)                                   ║
 ║                                                              ║
 ║   ┌──────────────────────────────────────────────────────-┐  ║
 ║   │               NoteRepresentable                       │  ║
 ║   │  ──────────────────────────────────────────────────   │  ║
 ║   │  id: UUID  ·  content: String                         │  ║
 ║   │  createdAt: Date  ·  updatedAt: Date                  │  ║
 ║   │                                                       │  ║
 ║   │  Adopted by:  NoteData (Domain)  ·  NoteEntity (Data) │  ║
 ║   │  No Codable · No UI · No persistence                  │  ║
 ║   └──────────────────────────────────────────────────────-┘  ║
 ╚══════════════════════════════════════════════════════════════╝
```

### Data flow — creating / editing a note

```
  User types in NoteEditorView
          │
          │  @Binding<NoteData>  (two-way, live)
          ▼
  NoteListView.bindingFor(_:)
          │
          │  vm.saveNote(note: NoteData)
          ▼
  NotesViewModel.saveNote(_:)          ← Domain, no I/O knowledge
          │
          │  repository.save(note)     ← crosses into Data layer
          ▼
  LocalNoteRepository.save(_:)
          │  NoteEntity(from: note)    ← maps NoteData → NoteEntity
          │  JSONEncoder().encode(entities)
          │  Data.write(to: fileURL, options: .atomic)
          ▼
       notes.json  on disk
          │
          │  repository.fetchAll()     ← re-read after every write
          ▼
  NotesViewModel.notes: [NoteData]     ← @Observable triggers UI refresh
          │
          ▼
  NoteListView / NoteRowView re-render
```

### Import rules (enforced by layer)

| Layer | Allowed imports |
|---|---|
| Shared | `Foundation` |
| Domain | `Foundation` · `SkipFuseUI` · `Shared` |
| Data | `Foundation` · `Shared` · `Domain` |
| Views | `SwiftUI` · `Domain` · `Shared` |

The Data layer is **never** imported by Domain or Views. `NoteEntity` and `LocalNoteRepository` are invisible above the Data boundary.

- **Views** depend only on Domain types (`NoteData`, `NotesViewModel`). They never import the Data layer.
- **Domain** defines the model (`NoteData`), the persistence contract (`NoteRepositoryProtocol`), and the observable orchestrator (`NotesViewModel`). No serialization knowledge here.
- **Data** owns all `FileManager`, `JSONEncoder`/`JSONDecoder`, and `NoteEntity` logic. It is invisible above the layer boundary.
- **Shared** holds `NoteRepresentable` — a pure identity protocol with no Codable or UI concerns, importable by all layers.

Zero `#if os(Android)` or `#if SKIP` blocks exist in Views, Domain, or Shared. Platform differences are absorbed by SkipFuseUI transparently.

## Known Blockers

This POC surfaced a platform declaration mismatch inside the Skip package ecosystem itself:

| Package | Declared iOS minimum | Actual requirement |
|---|---|---|
| `skip-android-bridge` 0.6.1 | iOS 16 | iOS 17 (via `swift-android-native`) |
| `swift-android-native` 1.4.x | iOS 17 | iOS 17 |

Xcode validates transitive package platform requirements even when the dependency is conditioned to Android-only builds (`.when(platforms: [.android])`), which surfaces this mismatch as a package resolution error.

An issue has been filed with the Skip team: [skiptools/skip-android-bridge](https://github.com/skiptools/skip-android-bridge/issues/26)).

## Setup

**Prerequisites**

- macOS 14+
- Xcode 16+ with Swift 6.0
- Swift 6.1+ toolchain (install via `swiftly` — see note below)
- Homebrew

**Install the Skip toolchain**

```bash
brew install skiptools/skip/skip
```

> **Note on Swift version:** `skip init` requires Swift 6.1+. Xcode 16 ships with Swift 6.0. Install a newer toolchain with `swiftly install latest` and ensure it is on your PATH before running Skip commands. Xcode itself can continue using Swift 6.0 for building.

**Open in Xcode**

```bash
# Always open the workspace, not Package.swift or the xcodeproj directly
open Project.xcworkspace
```

## Run on iOS

Skip Fuse requires **iOS 17+**. Options:

- Download an iOS 17, 18, or newer simulator runtime in **Xcode → Settings → Platforms**
- Or run directly on a physical device running iOS 17+

Select the target in Xcode and press **Cmd+R**.

## Run on Android

**No Android Studio or local Android tooling required.**
The CI pipeline (GitHub Actions) spins up an Android emulator, builds the APK, installs it, and uploads a screenshot as proof of run. To validate Android behaviour, simply push to `main` and check the artifacts in the Actions tab.

For local Android development if needed:

```bash
# Create a virtual device (one-time)
skip android emulator create

# Launch the emulator
skip android emulator launch

# Back in Xcode, select the Android target and press Cmd+R
```

## CI

![Android CI](https://github.com/YOUR_USERNAME/SkipNotes/actions/workflows/android.yml/badge.svg)

The GitHub Actions workflow (`.github/workflows/android.yml`) runs on `macos-14` (Apple Silicon) — required by the Swift Android SDK. It builds the iOS target with `swift build`, produces a release APK with `skip android build`, installs it on an Android emulator, and uploads both the APK and a screenshot as artifacts.

## POC Findings

| Area | Status |
|---|---|
| Architecture & layer separation | Complete |
| Swift build (`swift build`) | Clean |
| Domain / Data / View code | Complete, no platform guards |
| Xcode package resolution | Blocked by `skip-android-bridge` platform mismatch |
| iOS device run | Pending package fix |
| Android build | Pending unblocking Xcode |

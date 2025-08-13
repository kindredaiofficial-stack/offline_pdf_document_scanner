# Offline PDF Document Scanner

Production-ready Flutter app scaffold (Android & iOS) with CI, strict lints, and file-by-file skeletons.
Flutter **3.32.8**, Dart **3.8.1**.

> Works offline by design. No internet permission.

## Quick Start
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
See `docs/CODEX_PLAYBOOK.md` for the full “from scratch → production” checklist (identical to the canvas playbook).

## Branches
- default: `main` (protected)
- feature: `feat/<scope>`
- fix: `fix/<scope>`

## Modules
- Capture (camera/gallery, edge detect, crop, filters)
- Annotate (pen, highlighter, text)
- OCR (optional, offline, ML Kit)
- PDF build & export (A4/Letter, metadata, quality presets)

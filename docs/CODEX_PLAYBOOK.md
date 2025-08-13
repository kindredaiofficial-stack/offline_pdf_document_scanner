# Codex Playbook — Offline PDF Document Scanner (from scratch → production)

**Tooling**
- Flutter 3.32.8, Dart 3.8.1
- Android minSdk 24, targetSdk 35
- iOS: iOS 13+

**Golden rule**: deterministic, no network features.

## Tasks (high level)
1) Apply directory layout from `lib/` skeleton.
2) Add/lock deps (`pubspec.yaml`) and run `flutter pub get`.
3) Implement flows: capture → crop → filter → reorder → annotate → OCR (opt) → PDF export → list/share.
4) Tests (unit, widget, golden, integration).
5) CI must pass: `analyze`, `test --coverage`.
6) Release via Codemagic (AAB/IPA) with signing.
7) Store listings + privacy (“No data leaves device”).

## State (Riverpod)
- `documentController`, `captureController`, `ocrProvider` (feature flag)
- All APIs return `Result<T>` (no thrown errors past boundaries).

## DoD
- CI green, 0 analyzer warnings, core logic ≥95% coverage
- Signed AAB/IPA built by CI, tag `v1.0.0`

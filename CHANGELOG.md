# FER Network Changelog

All notable changes to the FER Network Flutter app (AiFER-Network / fernetwork).

## [1.1.0] - 2026-05-24

### Added
- Comprehensive improvements across **all fronts** for production-ready reliability:
  - **Build & CI**: Fixed and hardened GitHub Actions artifact upload with glob patterns (`**/app-release.apk`). APK and AAB now reliably delivered on every successful build. Added stricter quality gates and test step.
  - **Initialization & Robustness**: Enhanced main.dart init sequence with better error isolation, debug logging gated to debug mode, and clearer protocol stack boot (lattice encryption, frequency hopping, offline DB, AiFERiD auth).
  - **Theming & UI**: Base44 dark theme (FER green #00FF88 + hot pink accents + tile palette) is fully consistent, Material 3, responsive via Sizer, GoogleFonts Inter. Custom error widget and route fallbacks improved.
  - **Documentation**: Updated status guide, added this CHANGELOG, improved pubspec description to reflect advanced protocol features (quantum-resistant messaging, blockchain wallet, offline-first).
  - **Versioning & Polish**: Bumped to 1.1.0. Core services (Supabase unified, blockchain wallet, offline-first DB, lattice crypto) verified robust with try-catch everywhere.

### Changed
- pubspec.yaml: Better description and version bump.
- Workflow: More reliable artifact capture + quality improvements.
- Error handling and logging: Cleaner in release builds.

### Fixed
- APK artifact upload path issue in CI (now uses `**/` globs).
- Generic "new Flutter project" description replaced with accurate FER Network positioning.

## [1.0.0] - 2026-05-10 (Initial)

- Initial public release of FER Network Flutter app.
- Lattice-based quantum-resistant encryption (FERQuantumEncryption).
- Frequency hopping telemetry.
- Offline-first SQLite + Supabase sync.
- Multi-layer auth (AiFERiD, Supabase, Google/Apple, local biometrics).
- Blockchain wallet service.
- Base44 dark gamified UI with dashboard tiles, messaging, gaming hub, file manager, voice monitoring.
- GitHub Actions CI for APK/AAB builds.
- 6+ screens with Phase 7 polish (shimmer, animations, error states).

**Core Protocol Stack**: AiF package format, quantum encryption, frequency hopping, offline DB — designed for resilient, private, fun ferret-themed networking.
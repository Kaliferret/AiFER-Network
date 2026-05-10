# FER Network — Install & Test

A Flutter app with lattice-crypto messaging, offline-first storage, frequency-hopping radio telemetry, blockchain wallet, file manager, gaming hub, and voice calls — all in a base44 dark UI.

## Requirements

- **Flutter 3.27+ / Dart 3.6+** — https://docs.flutter.dev/get-started/install
- **Android Studio** or **Xcode** (for device emulator) — or a real phone in developer mode
- A writable home directory (the offline DB creates a `.sqlite` in app-documents)

Verify Flutter:
```bash
flutter --version
flutter doctor
```

## Install

```bash
unzip fernetwork.zip
cd fernetwork-main
flutter pub get
```

If you're on Flutter < 3.27 (e.g. 3.24), relax the SDK constraint in `pubspec.yaml`:
```yaml
environment:
  sdk: ">=3.5.0 <4.0.0"
```
The `Color.withValues` polyfill in `lib/core/color_polyfill.dart` handles the API gap automatically.

## Run

```bash
# List connected devices
flutter devices

# Run on the first available device
flutter run

# Or target a specific device
flutter run -d <device-id>

# Release build
flutter build apk --release          # Android
flutter build ios --release          # iOS (Xcode required)
```

## Test walkthrough

1. **Login screen** — AiFERiD authentication framework. Create a new ID or restore from seed.
2. **Dashboard** — tap any of the 4 tiles:
   - **Blue (FER Chat)** → messaging_interface — 2 tabs (Conversations / Active). Shimmer loads, then empty or real data. Send a message → lattice-encrypted + `.aif`-packaged into offline DB.
   - **Pink (FER Wallet)** → blockchain wallet — 3 tabs (Overview / New / Verify). Aggregate FER balance, shimmer list of wallets.
   - **Green (FER Explorer)** → file manager — import a file, watch it encrypt + package. Share dialog shows live hop frequency.
   - **Purple (Gaming Hub)** → 3 tabs (My Sessions / Catalog / Stats). Start a game → writes a real `FERGamingSession`. Complete it → +100 score, +7 min playtime.
3. **Balance card / unread card** — tap them (they scale down 96% — Phase 7 polish).
4. **Voice call** — from messaging, tap the call icon. Peer is resolved from most-recent FERMessage counterparty. Live telemetry ticks every 2 s. Hang up → call log persisted as `FERMessage(audio)`.

## What's in each folder

```
fernetwork-main/
├── lib/                    ← the shipping app (what flutter builds)
│   ├── core/               ← quantum encryption, frequency hopping, DB, polyfills
│   ├── services/           ← auth, wallet, contacts
│   ├── presentation/       ← 14 screens (5 fully wired in Phase 6)
│   ├── widgets/            ← shared UI + polish.dart (Phase 7 primitives)
│   ├── theme/              ← AppTheme with base44 palette
│   └── routes/             ← AppRoutes
├── lib_official/           ← reference: original Claude backend (don't modify)
├── android/                ← Android project config
├── ios/                    ← iOS project config
├── assets/                 ← images + fonts
├── supabase/               ← optional remote-sync schemas (not required)
├── pubspec.yaml            ← dependencies (169 resolved clean)
└── INSTALL_AND_TEST.md     ← this file
```

## Dependency notes

- `google_sign_in` is pinned to v6 API (`.signIn()` not `.authenticate()`). If pub resolves v7, either downgrade or update `lib/services/google_auth_service.dart`.
- `sqflite` needs platform plugins — it's already wired for Android/iOS. For desktop, add `sqflite_common_ffi`.
- `sizer` provides the `2.w`, `3.h`, `12.sp` units used everywhere.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `Color.withValues isn't defined` | Already handled by `lib/core/color_polyfill.dart` — make sure `app_export.dart` is imported in the affected file |
| `sqflite: databaseFactory not initialized` | On desktop platforms add `databaseFactoryFfi` in `main()` |
| Login succeeds but dashboard crashes | `FERFrequencyHopping.initialize(nodeId)` needs a non-null node ID from `AiFERiDAuthService.getCurrentUser()` — confirm login completed before navigating |
| Build warns about `withOpacity` deprecated | Cosmetic — both old and new APIs work via polyfill |

## Analyzer baseline

Last run (Flutter 3.24.5 / Dart 3.5.4 in CI sandbox):
```
dart analyze lib/
→ 0 errors, 39 warnings, 28 infos
```
All warnings are cosmetic (unused imports, redundant awaits). Zero blocking issues.

## Physics / protocol reference

- **Radio-channel physics:** signal × congestion × interference → frequency selection (`core/frequency_hopping.dart`, 2.4–5.8 GHz, 100 ms hop interval, 256-hop sequences)
- **Lattice cryptography:** LWE-like, n=512, q=4096, Gaussian error bound=3 (`core/fer_quantum_encryption.dart`)
- **Packaging:** `AIF\0` + 128 B header + compressed body + encrypted body + 64 B footer
- **No thermal radiation** (Stefan-Boltzmann is *not* part of this stack)

## Roadmap status

See `ROADMAP.md` in the repo root — all 7 phases ✅ complete. Ready for device testing.

Preview of UI: https://sites.super.myninja.ai/f30f6a23-27f3-49f1-a54a-efcad925a85d/d4772410/index.html

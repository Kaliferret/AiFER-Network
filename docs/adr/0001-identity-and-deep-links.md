# ADR-0001: Identity Primitive & Deep Link Grammar

- **Status:** Accepted — 2026-06-26
- **Date:** 2026-06-26
- **Deciders:** AiFER core
- **Supersedes:** —

## Context

AiFER-Network is a privacy-first, offline-first mobile client. Before building onboarding, capsules, Whisper messaging, or sync, we must lock:

1. How a user is identified (cryptographically, without a server account).
2. How the app is addressed from the outside world (deep links, capsule sharing, future web ↔ app handoff via aifer.org).

These two decisions are foundational — every later subsystem depends on them, and changing them post-launch breaks every existing identity and link.

## Decision

### 2.1 Identity Primitive

- **Algorithm:** Ed25519 (signing) + X25519 (key agreement, derived later).
- **Generation:** On first launch, locally, in-process. No network call.
- **Storage:** Private key bytes stored via `flutter_secure_storage` (Android Keystore-backed; iOS Keychain when applicable). Never logged, never exported in plaintext, never leaves the device.
- **Public identifier:** `aifer:id:<base32(pubkey)>` — lowercase, no padding, 52 chars. This is the user's stable, shareable handle.
- **Storage namespace:** `aifer.identity.v1`
- **Versioning:** The `v1` suffix in `aifer.identity.v1` and the `aifer:id:` prefix are versioned independently; bumping one does not require bumping the other.

### 2.2 Deep Link Scheme

- **Scheme:** `aifer://`
- **Grammar:** `aifer://<action>/<primary>[?<params>]`
- **Reserved actions (v1):**
  | Action      | URI shape                                      | Purpose                         |
  |-------------|------------------------------------------------|---------------------------------|
  | `capsule`   | `aifer://capsule/<sha256>?k=<wrapped-key>`     | Open an encrypted capsule       |
  | `whisper`   | `aifer://whisper/<aifer-id>`                   | Start a 1:1 secure conversation |
  | `id`        | `aifer://id/<aifer-id>`                        | View a public identity card     |
  | `onboard`   | `aifer://onboard?ref=<source>`                 | Resume onboarding from web      |

- **Parser:** Single source of truth in `lib/deep_links/router.dart`.
  Unknown actions → no-op + telemetry event (never crash).
- **Web handoff:** `https://aifer.org/open?u=<url-encoded-aifer-uri>` redirects to the `aifer://` URI; if the app is not installed, falls back to the install page.

### 2.3 Capsule URI Grammar

- **Form:** `aifer://capsule/<content-sha256>?k=<wrapped-content-key>`
- `<content-sha256>` — hex, lowercase, 64 chars. Address of the ciphertext blob (content-addressed; same content ⇒ same URI).
- `<wrapped-content-key>` — base64url, no padding. The symmetric content key (ChaCha20-Poly1305) wrapped to the recipient's X25519 public key via HPKE-style sealed box.
- **Invariant:** A capsule URI is safe to share over insecure channels. Possession of the URI alone is sufficient to decrypt — therefore URIs must be treated as secrets by the sharer.

## Consequences

**Positive:**
- No server account required; identity works fully offline.
- Capsule URIs are self-contained, portable, and verifiable.
- Deep link grammar is stable and forward-compatible (new actions add, never break old ones).

**Negative / risks:**
- Losing the device = losing the identity (until rotation ADR lands).
- URI-as-secret model requires user education in UI.
- Ed25519 → X25519 derivation must be done consistently (documented in a follow-up ADR).

## Non-goals (Out of scope for this ADR)

- Key rotation UX (deferred to ADR-0003)
- Multi-device identity sync (deferred to ADR-0004)
- Recovery phrases / social recovery (deferred; explicitly out of v1)

## Threat model

Private keys never leave the Android Keystore TEE. A device compromise with root access is out of scope for v1; an attacker with physical device access but without the unlock credential cannot extract the key.

## Test contract

The test suite must enforce:
- `loadOrCreate` creates a key when none exists
- `loadOrCreate` is idempotent (same public key across calls)
- Recovery from corrupted secure-storage entry (delete + regenerate + log once)
- Public key round-trips through `aifer:id:<base32>` format
- Private key never appears in return values or logs
- Storage namespace is `aifer.identity.v1`

## Alternatives Considered

- **DID (did:key, did:web):** Overkill for v1; adds spec surface without user-visible benefit. Revisit when federation lands.
- **Server-issued account IDs:** Violates offline-first and privacy-first vision. Rejected.
- **Custom URI scheme per feature:** Fragments the brand and OS-level link handling. Rejected.

## References

- `lib/identity/keystore.dart` — implementation of 2.1
- `lib/deep_links/router.dart` — implementation of 2.2
- aifer.org `/open` endpoint — implementation of web handoff

## Reviewer checklist
- [ ] Scheme literal is `aifer://` (lowercase, no trailing slash)
- [ ] ID format is `aifer:id:<base32-no-padding>` of 32-byte Ed25519 public key
- [ ] minSdkVersion 23 cited as Keystore floor
- [ ] Versioning line present
- [ ] Test contract subsection lists all 6 required tests by name
- [ ] Out of scope section present

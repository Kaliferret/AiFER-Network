import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AiFER identity keystore.
///
/// Owns the device's Ed25519 signing keypair. The private key is generated
/// on first launch, persisted in the platform secure store (Android
/// Keystore / iOS Keychain via `flutter_secure_storage`), and never
/// leaves the device in plaintext.
///
/// Public identifier format: `aifer:id:<base32(pubkey)>`
///
/// See ADR-0001 for the identity primitive specification.
class IdentityKeystore {
  IdentityKeystore({FlutterSecureStorage? storage, Ed25519? algorithm})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            ),
        _algo = algorithm ?? Ed25519();

  static const _kPrivKey = 'aifer.identity.ed25519.sk.v1';
  static const _kPubKey = 'aifer.identity.ed25519.pk.v1';

  final FlutterSecureStorage _storage;
  final Ed25519 _algo;

  SimpleKeyPair? _cached;

  /// Generates a fresh Ed25519 keypair and persists it.
  Future<SimpleKeyPair> generate() async {
    final kp = await _algo.newKeyPair();
    final sk = await kp.extractPrivateKeyBytes();
    final pk = (await kp.extractPublicKey()).bytes;

    await _storage.write(key: _kPrivKey, value: base64Url.encode(sk));
    await _storage.write(key: _kPubKey, value: base64Url.encode(pk));

    _cached = kp;
    return kp;
  }

  /// Returns the existing identity, or creates one on first run.
  Future<SimpleKeyPair> loadOrCreate() async {
    if (_cached != null) return _cached!;

    final skB64 = await _storage.read(key: _kPrivKey);
    final pkB64 = await _storage.read(key: _kPubKey);

    if (skB64 == null || pkB64 == null) {
      return generate();
    }

    final sk = base64Url.decode(skB64);
    final pk = base64Url.decode(pkB64);
    _cached = SimpleKeyPairData(
      sk,
      publicKey: SimplePublicKey(pk, type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
    return _cached!;
  }

  /// Returns the public key as raw bytes.
  Future<List<int>> publicKeyBytes() async {
    final kp = await loadOrCreate();
    return (await kp.extractPublicKey()).bytes;
  }

  /// Returns the shareable AiFER identity handle.
  Future<String> aiferId() async {
    final pk = await publicKeyBytes();
    return 'aifer:id:${_base32NoPad(pk)}';
  }

  /// Signs an arbitrary byte payload.
  Future<Signature> sign(List<int> bytes) async {
    final kp = await loadOrCreate();
    return _algo.sign(bytes, keyPair: kp);
  }

  /// Verifies a signature against this device's public key.
  Future<bool> verifyOwn(List<int> bytes, Signature signature) async {
    return _algo.verify(bytes, signature: signature);
  }

  /// DESTRUCTIVE. Wipes the identity.
  Future<void> wipe() async {
    await _storage.delete(key: _kPrivKey);
    await _storage.delete(key: _kPubKey);
    _cached = null;
  }

  // RFC 4648 base32, lowercase, no padding.
  static const _alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  static String _base32NoPad(List<int> bytes) {
    final out = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final b in bytes) {
      buffer = (buffer << 8) | (b & 0xff);
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        out.write(_alphabet[(buffer >> bits) & 0x1f]);
      }
    }
    if (bits > 0) {
      out.write(_alphabet[(buffer << (5 - bits)) & 0x1f]);
    }
    return out.toString();
  }
}
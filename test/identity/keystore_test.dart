import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../lib/identity/keystore.dart';

// Simple in-memory fake for testing
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value != null) _store[key] = value;
  }

  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    return _store[key];
  }

  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _store.remove(key);
  }

  // Other methods can be left as no-op for this test
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('IdentityKeystore', () {
    test('generate, persist, reload and sign/verify round-trip', () async {
      final storage = FakeSecureStorage();
      final ks1 = IdentityKeystore(storage: storage);

      final id1 = await ks1.aiferId();
      expect(id1, startsWith('aifer:id:'));

      // Reload with new instance (simulates app restart)
      final ks2 = IdentityKeystore(storage: storage);
      final id2 = await ks2.aiferId();
      expect(id2, id1); // same identity persisted

      final message = utf8.encode('hello ai ferret');
      final sig = await ks1.sign(message);
      final valid = await ks1.verifyOwn(message, sig);
      expect(valid, isTrue);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../identity/keystore.dart';

final identityKeystoreProvider = Provider<IdentityKeystore>((ref) {
  return IdentityKeystore();
});

/// Resolves to the device's aifer:id:... handle, creating the
/// identity on first access. Cache this — do not re-await per build.
final aiferIdProvider = FutureProvider<String>((ref) async {
  return ref.read(identityKeystoreProvider).aiferId();
});

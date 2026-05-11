import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Social Authentication Service for AIFER v11
/// Supports Google, Apple sign-in, and biometric authentication
/// Inspired by zkLogin from AIFER v11 (zero-knowledge login)
class SocialAuthService {
  static SocialAuthService? _instance;
  static SocialAuthService get instance => _instance ??= SocialAuthService._();
  SocialAuthService._();

  GoogleSignIn? _googleSignIn;
  LocalAuthentication? _localAuth;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  StreamController<SocialAuthEvent>? _authEventController;

  /// Initialize authentication service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize Google Sign-In
      _googleSignIn = GoogleSignIn(
        signInOption: SignInOption.standard,
        scopes: ['email', 'profile'],
      );

      // Initialize Local Authentication
      _localAuth = LocalAuthentication();

      _setupAuthEventStream();
      _isInitialized = true;

      debugPrint('✅ Social Auth Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Social Auth Service: $e');
      rethrow;
    }
  }

  /// Set up authentication event stream
  void _setupAuthEventStream() {
    _authEventController = StreamController<SocialAuthEvent>.broadcast();
  }

  /// Emit authentication event
  void _emitAuthEvent(SocialAuthEvent event) {
    _authEventController?.add(event);
    debugPrint('🔐 Auth Event: ${event.toString()}');
  }

  /// Stream of authentication events
  Stream<SocialAuthEvent> get authEvents => 
      _authEventController?.stream ?? const Stream.empty();

  /// Sign in with Google
  Future<SocialAuthResult> signInWithGoogle() async {
    try {
      _emitAuthEvent(SocialAuthEvent.googleSignInStarted);

      final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();
      
      if (googleUser == null) {
        _emitAuthEvent(SocialAuthEvent.googleSignInCancelled);
        return SocialAuthResult(
          success: false,
          error: 'Google sign-in cancelled',
          authType: SocialAuthType.google,
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Store user information
      final userProfile = SocialUserProfile(
        id: generateUserId(),
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        authType: SocialAuthType.google,
        token: googleAuth.idToken,
      );

      await _storeUserProfile(userProfile);

      _emitAuthEvent(SocialAuthEvent.googleSignInSuccess);

      return SocialAuthResult(
        success: true,
        user: userProfile,
        authType: SocialAuthType.google,
      );

    } catch (e) {
      debugPrint('❌ Google sign-in failed: $e');
      _emitAuthEvent(SocialAuthEvent.googleSignInFailed);
      return SocialAuthResult(
        success: false,
        error: 'Google sign-in failed: $e',
        authType: SocialAuthType.google,
      );
    }
  }

  /// Sign in with Apple (iOS only)
  Future<SocialAuthResult> signInWithApple() async {
    try {
      _emitAuthEvent(SocialAuthEvent.appleSignInStarted);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        _emitAuthEvent(SocialAuthEvent.appleSignInFailed);
        return SocialAuthResult(
          success: false,
          error: 'Apple sign-in failed: no identity token',
          authType: SocialAuthType.apple,
        );
      }

      final givenName = credential.givenName;
      final familyName = credential.familyName;
      final displayName = [givenName, familyName]
          .where((name) => name != null && name!.isNotEmpty)
          .join(' ');

      final userProfile = SocialUserProfile(
        id: generateUserId(),
        email: credential.email,
        displayName: displayName,
        authType: SocialAuthType.apple,
        token: credential.identityToken,
        authorizationCode: credential.authorizationCode,
      );

      await _storeUserProfile(userProfile);

      _emitAuthEvent(SocialAuthEvent.appleSignInSuccess);

      return SocialAuthResult(
        success: true,
        user: userProfile,
        authType: SocialAuthType.apple,
      );

    } catch (e) {
      debugPrint('❌ Apple sign-in failed: $e');
      _emitAuthEvent(SocialAuthEvent.appleSignInFailed);
      return SocialAuthResult(
        success: false,
        error: 'Apple sign-in failed: $e',
        authType: SocialAuthType.apple,
      );
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth?.canCheckBiometrics ?? false;
      final isDeviceSupported = await _localAuth?.isDeviceSupported() ?? false;
      return isAvailable && isDeviceSupported;
    } catch (e) {
      debugPrint('❌ Failed to check biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth?.getAvailableBiometrics() ?? [];
    } catch (e) {
      debugPrint('❌ Failed to get available biometrics: $e');
      return [];
    }
  }

  /// Authenticate with biometrics (fingerprint, face, etc.)
  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Authenticate to access AiFER OS',
  }) async {
    try {
      _emitAuthEvent(SocialAuthEvent.biometricAuthStarted);

      final didAuthenticate = await _localAuth?.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      ) ?? false;

      if (didAuthenticate) {
        _emitAuthEvent(SocialAuthEvent.biometricAuthSuccess);
      } else {
        _emitAuthEvent(SocialAuthEvent.biometricAuthFailed);
      }

      return didAuthenticate;

    } catch (e) {
      debugPrint('❌ Biometric authentication failed: $e');
      _emitAuthEvent(SocialAuthEvent.biometricAuthFailed);
      return false;
    }
  }

  /// Sign out from all social providers
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn?.signOut();

      // Clear local stored profile
      await _clearUserProfile();

      _emitAuthEvent(SocialAuthEvent.signedOut);
      debugPrint('✅ Signed out successfully');

    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
    }
  }

  /// Sign out from specific provider
  Future<void> signOutFrom(SocialAuthType authType) async {
    try {
      if (authType == SocialAuthType.google) {
        await _googleSignIn?.signOut();
      }

      await _clearUserProfile();

      _emitAuthEvent(SocialAuthEvent.signedOut);
      debugPrint('✅ Signed out from $authType');

    } catch (e) {
      debugPrint('❌ Sign out from $authType failed: $e');
    }
  }

  /// Get current user profile
  Future<SocialUserProfile?> getCurrentUser() async {
    try {
      final userProfileJson = _prefs?.getString('current_user_profile');
      if (userProfileJson == null) return null;

      final userProfileMap = jsonDecode(userProfileJson) as Map<String, dynamic>;
      return SocialUserProfile.fromJson(userProfileMap);

    } catch (e) {
      debugPrint('❌ Failed to get current user: $e');
      return null;
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  /// Store user profile locally
  Future<void> _storeUserProfile(SocialUserProfile userProfile) async {
    try {
      final userProfileJson = jsonEncode(userProfile.toJson());
      await _prefs?.setString('current_user_profile', userProfileJson);
      debugPrint('✅ User profile stored');
    } catch (e) {
      debugPrint('❌ Failed to store user profile: $e');
    }
  }

  /// Clear stored user profile
  Future<void> _clearUserProfile() async {
    try {
      await _prefs?.remove('current_user_profile');
      debugPrint('✅ User profile cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear user profile: $e');
    }
  }

  /// Generate unique user ID
  String generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(10000);
    final hash = sha256.convert(utf8.encode('user_$timestamp$random'));
    return hash.toString().substring(0, 16);
  }

  /// Generate zero-knowledge proof placeholder
  /// This is a placeholder for zkLogin functionality
  /// Full implementation would integrate with Sui blockchain
  Future<Map<String, dynamic>> generateZKProof(
    String authType,
    String identityToken,
  ) async {
    // Placeholder: In full implementation, this would:
    // 1. Generate ZK proof using Sui's zkLogin prover
    // 2. Derive Sui blockchain address from the proof
    // 3. Return cryptographic proof and address
    
    debugPrint('⚠️  ZK proof generation (placeholder)');
    
    return {
      'proof': 'placeholder_zk_proof',
      'address': 'placeholder_sui_address',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _authEventController?.close();
    _googleSignIn = null;
    _localAuth = null;
  }
}

/// Authentication result data class
class SocialAuthResult {
  final bool success;
  final SocialUserProfile? user;
  final String? error;
  final SocialAuthType authType;
  final DateTime? expiresAt;

  SocialAuthResult({
    required this.success,
    this.user,
    this.error,
    required this.authType,
    this.expiresAt,
  });
}

/// User profile data class
class SocialUserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final SocialAuthType authType;
  final String? token;
  final String? authorizationCode;
  final DateTime? createdAt;

  SocialUserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.authType,
    this.token,
    this.authorizationCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SocialUserProfile.fromJson(Map<String, dynamic> json) {
    return SocialUserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      authType: SocialAuthType.values.firstWhere(
        (e) => e.toString() == 'SocialAuthType.${json['authType']}',
        orElse: () => SocialAuthType.google,
      ),
      token: json['token'] as String?,
      authorizationCode: json['authorizationCode'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'authType': authType.toString().split('.').last,
      'token': token,
      'authorizationCode': authorizationCode,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

/// Authentication type enum
enum SocialAuthType {
  google,
  apple,
  wallet,
  biometric,
  anonymous,
}

/// Authentication events
enum SocialAuthEvent {
  googleSignInStarted,
  googleSignInSuccess,
  googleSignInCancelled,
  googleSignInFailed,
  appleSignInStarted,
  appleSignInSuccess,
  appleSignInFailed,
  biometricAuthStarted,
  biometricAuthSuccess,
  biometricAuthFailed,
  signedOut,
}
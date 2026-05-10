import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class GoogleAuthService {
  static GoogleAuthService? _instance;
  static GoogleAuthService get instance => _instance ??= GoogleAuthService._();
  GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void initialize() {
    // Google Sign-In is already initialized in constructor
    debugPrint('✅ Google Auth service initialized');
  }

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      final AuthResponse response = await SupabaseService.instance.client.auth
          .signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );

      // Check if user is admin after successful login
      if (response.user != null) {
        await _checkAndSetAdminPrivileges(response.user!);
      }

      return response;
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      rethrow;
    }
  }

  Future<void> _checkAndSetAdminPrivileges(User user) async {
    try {
      // Check if this is the admin account
      if (user.email == 'bouncingferretofficial@gmail.com') {
        debugPrint('✅ Admin account detected: ${user.email}');

        // Update user metadata to mark as admin
        await SupabaseService.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'role': 'admin',
              'is_admin': true,
              'admin_level': 'super_admin',
            },
          ),
        );

        // Update user profile in database if it exists
        try {
          await SupabaseService.instance.from('user_profiles').upsert({
            'id': user.id,
            'email': user.email,
            'role': 'admin',
            'display_name': user.userMetadata?['full_name'] ?? 'Admin',
            'avatar_url': user.userMetadata?['avatar_url'],
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');
        } catch (dbError) {
          debugPrint('Database update failed (non-critical): $dbError');
        }
      } else {
        // Regular user
        await SupabaseService.instance.from('user_profiles').upsert({
          'id': user.id,
          'email': user.email,
          'role': 'user',
          'display_name': user.userMetadata?['full_name'] ?? 'User',
          'avatar_url': user.userMetadata?['avatar_url'],
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
      }
    } catch (e) {
      debugPrint('Admin privilege check failed: $e');
    }
  }

  bool isAdmin() {
    try {
      final user = SupabaseService.instance.getCurrentUser();
      if (user == null) return false;

      // Check by email first (primary method)
      if (user.email == 'bouncingferretofficial@gmail.com') return true;

      // Check user metadata
      final metadata = user.userMetadata ?? {};
      return metadata['is_admin'] == true || metadata['role'] == 'admin';
    } catch (e) {
      debugPrint('Admin check failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await SupabaseService.instance.signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return SupabaseService.instance.getCurrentUser();
  }

  bool isSignedIn() {
    return getCurrentUser() != null;
  }

  GoogleSignInAccount? getCurrentGoogleUser() {
    return null;
  }

  /// Get comprehensive user profile information
  Map<String, dynamic>? getUserProfile() {
    final user = getCurrentUser();
    final googleUser = getCurrentGoogleUser();
    if (user == null) return null;

    return {
      'id': user.id,
      'email': user.email,
      'displayName': user.userMetadata?['full_name'] ?? googleUser?.displayName,
      'photoUrl': user.userMetadata?['avatar_url'] ?? googleUser?.photoUrl,
      'isAdmin': isAdmin(),
      'provider': 'google',
      'lastSignIn': user.lastSignInAt,
    };
  }

  /// Enhanced authentication state check
  Future<bool> checkAuthenticationState() async {
    try {
      final supabaseUser = getCurrentUser();
      return supabaseUser != null;
    } catch (error) {
      debugPrint('❌ Authentication state check error: $error');
      return false;
    }
  }
}
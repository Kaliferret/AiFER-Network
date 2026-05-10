import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './enhanced_supabase_service.dart';
import './aiferid_auth_service.dart';

/// Renewed Authentication Service - Enhanced login procedures with modern security
class RenewedAuthService {
  static RenewedAuthService? _instance;
  static RenewedAuthService get instance =>
      _instance ??= RenewedAuthService._();
  RenewedAuthService._();

  final _supabaseService = EnhancedSupabaseService.instance;
  final _aiferidService = AiFERiDAuthService.instance;
  SharedPreferences? _prefs;

  // Enhanced session management keys
  static const String _renewedSessionKey = 'renewed_auth_session';
  static const String _biometricEnabledKey = 'biometric_auth_enabled';
  static const String _quickLoginEnabledKey = 'quick_login_enabled';
  static const String _lastLoginMethodKey = 'last_login_method';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _lastLoginAttemptKey = 'last_login_attempt';

  // Session security constants
  static const int _maxLoginAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  static const int _sessionDurationDays = 30;

  /// Initialize the renewed authentication service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _aiferidService.initialize();

      // Clean up expired sessions
      await _cleanupExpiredSessions();

      debugPrint('✅ Renewed Authentication Service initialized');
    } catch (e) {
      debugPrint('❌ Renewed auth service initialization failed: $e');
      rethrow;
    }
  }

  /// Enhanced login with multiple authentication methods
  Future<AuthResult> login({
    String? aiFERiD,
    String? email,
    String? password,
    String? biometricData,
    AuthMethod method = AuthMethod.aiferid,
  }) async {
    try {
      // Check if account is locked
      if (await _isAccountLocked()) {
        return AuthResult.failure(
          error: 'Account temporarily locked due to multiple failed attempts',
          errorCode: 'ACCOUNT_LOCKED',
        );
      }

      AuthResult result;

      switch (method) {
        case AuthMethod.aiferid:
          result = await _loginWithAiFERiD(aiFERiD!);
          break;
        case AuthMethod.email:
          result = await _loginWithEmail(email!, password!);
          break;
        case AuthMethod.biometric:
          result = await _loginWithBiometric(biometricData!);
          break;
        case AuthMethod.quickLogin:
          result = await _quickLogin();
          break;
      }

      if (result.success) {
        await _handleSuccessfulLogin(method, result);
      } else {
        await _handleFailedLogin();
      }

      return result;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      await _handleFailedLogin();
      return AuthResult.failure(
        error: 'Login failed: ${e.toString()}',
        errorCode: 'LOGIN_ERROR',
      );
    }
  }

  /// Enhanced AiFERiD login with improved security
  Future<AuthResult> _loginWithAiFERiD(String aiFERiD) async {
    try {
      // Validate AiFERiD format
      if (!_aiferidService.isValidAiFERiDFormat(aiFERiD)) {
        return AuthResult.failure(
          error: 'Invalid AiFERiD format',
          errorCode: 'INVALID_AIFERID',
        );
      }

      // Generate enhanced challenge for security
      final challenge = _generateSecurityChallenge();

      // Authenticate with AiFERiD service
      final authResponse = await _aiferidService.authenticateWithAiFERiD(
        aiFERiD: aiFERiD,
        signatureProof: challenge,
      );

      if (authResponse['success'] == true) {
        final userData = await _enrichUserData(authResponse);

        return AuthResult.success(
          user: AuthUser(
            id: authResponse['user_id'],
            aiFERiD: aiFERiD,
            email: userData?['email'],
            fullName: userData?['full_name'],
            avatarUrl: userData?['avatar_url'],
            walletData: authResponse['wallet_data'],
            authMethod: AuthMethod.aiferid,
          ),
          sessionToken: await _createEnhancedSession(authResponse),
        );
      }

      return AuthResult.failure(
        error: authResponse['error'] ?? 'AiFERiD authentication failed',
        errorCode: 'AIFERID_AUTH_FAILED',
      );
    } catch (e) {
      debugPrint('❌ AiFERiD login error: $e');
      return AuthResult.failure(
        error: 'AiFERiD login failed: ${e.toString()}',
        errorCode: 'AIFERID_LOGIN_ERROR',
      );
    }
  }

  /// Email/password login with Supabase
  Future<AuthResult> _loginWithEmail(String email, String password) async {
    try {
      final authResponse = await _supabaseService.client.auth
          .signInWithPassword(email: email, password: password);

      if (authResponse.user != null) {
        final userData = await _getUserProfileData(authResponse.user!.id);

        return AuthResult.success(
          user: AuthUser(
            id: authResponse.user!.id,
            email: email,
            fullName: userData?['full_name'],
            avatarUrl: userData?['avatar_url'],
            aiFERiD: userData?['primary_aiferid'],
            authMethod: AuthMethod.email,
          ),
          sessionToken: authResponse.session?.accessToken,
        );
      }

      return AuthResult.failure(
        error: 'Invalid email or password',
        errorCode: 'INVALID_CREDENTIALS',
      );
    } catch (e) {
      debugPrint('❌ Email login error: $e');
      return AuthResult.failure(
        error: 'Email login failed: ${e.toString()}',
        errorCode: 'EMAIL_LOGIN_ERROR',
      );
    }
  }

  /// Biometric authentication (placeholder for future implementation)
  Future<AuthResult> _loginWithBiometric(String biometricData) async {
    try {
      // For now, check if biometric is enabled and validate against stored data
      final isBiometricEnabled = await _isBiometricEnabled();
      if (!isBiometricEnabled) {
        return AuthResult.failure(
          error: 'Biometric authentication not enabled',
          errorCode: 'BIOMETRIC_NOT_ENABLED',
        );
      }

      // Simulate biometric verification (implement actual biometric logic)
      final lastSession = await _getLastSession();
      if (lastSession != null &&
          lastSession['biometric_hash'] == biometricData) {
        return await _restoreSessionLogin(lastSession);
      }

      return AuthResult.failure(
        error: 'Biometric verification failed',
        errorCode: 'BIOMETRIC_FAILED',
      );
    } catch (e) {
      return AuthResult.failure(
        error: 'Biometric login failed: ${e.toString()}',
        errorCode: 'BIOMETRIC_ERROR',
      );
    }
  }

  /// Quick login using stored session
  Future<AuthResult> _quickLogin() async {
    try {
      final isQuickLoginEnabled = await _isQuickLoginEnabled();
      if (!isQuickLoginEnabled) {
        return AuthResult.failure(
          error: 'Quick login not enabled',
          errorCode: 'QUICK_LOGIN_DISABLED',
        );
      }

      final lastSession = await _getLastSession();
      if (lastSession != null && !_isSessionExpired(lastSession)) {
        return await _restoreSessionLogin(lastSession);
      }

      return AuthResult.failure(
        error: 'No valid session found',
        errorCode: 'NO_VALID_SESSION',
      );
    } catch (e) {
      return AuthResult.failure(
        error: 'Quick login failed: ${e.toString()}',
        errorCode: 'QUICK_LOGIN_ERROR',
      );
    }
  }

  /// Create enhanced session with additional security
  Future<String> _createEnhancedSession(Map<String, dynamic> authData) async {
    try {
      final sessionId = _generateSessionId();
      final sessionData = {
        'session_id': sessionId,
        'user_id': authData['user_id'],
        'aiferid': authData['aiferid'],
        'created_at': DateTime.now().toIso8601String(),
        'expires_at':
            DateTime.now()
                .add(Duration(days: _sessionDurationDays))
                .toIso8601String(),
        'device_fingerprint': await _generateDeviceFingerprint(),
        'security_hash': _generateSecurityHash(authData),
        'wallet_data': authData['wallet_data'],
      };

      await _storeSession(sessionData);
      return sessionId;
    } catch (e) {
      debugPrint('❌ Failed to create enhanced session: $e');
      rethrow;
    }
  }

  /// Get current authenticated user
  Future<AuthUser?> getCurrentUser() async {
    try {
      final session = await _getLastSession();
      if (session == null || _isSessionExpired(session)) {
        return null;
      }

      return AuthUser(
        id: session['user_id'],
        aiFERiD: session['aiferid'],
        email: session['email'],
        fullName: session['full_name'],
        avatarUrl: session['avatar_url'],
        walletData: session['wallet_data'],
        authMethod: AuthMethod.values.firstWhere(
          (method) => method.name == session['auth_method'],
          orElse: () => AuthMethod.aiferid,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to get current user: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// Enhanced logout with cleanup
  Future<void> logout() async {
    try {
      // Clear Supabase session
      await _supabaseService.client.auth.signOut();

      // Clear AiFERiD session
      await _aiferidService.signOut();

      // Clear renewed auth session
      await _clearSession();

      // Reset login attempts
      await _resetLoginAttempts();

      debugPrint('✅ Enhanced logout completed');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      rethrow;
    }
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_biometricEnabledKey, enabled);

      if (enabled) {
        // Store biometric hash for current session
        final session = await _getLastSession();
        if (session != null) {
          session['biometric_hash'] = _generateBiometricHash();
          await _storeSession(session);
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to set biometric enabled: $e');
    }
  }

  /// Enable/disable quick login
  Future<void> setQuickLoginEnabled(bool enabled) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_quickLoginEnabledKey, enabled);
    } catch (e) {
      debugPrint('❌ Failed to set quick login enabled: $e');
    }
  }

  /// Get authentication statistics
  Future<Map<String, dynamic>> getAuthStats() async {
    try {
      final session = await _getLastSession();
      final loginAttempts = await _getLoginAttempts();

      return {
        'is_authenticated': await isAuthenticated(),
        'current_method': session?['auth_method'] ?? 'none',
        'session_expires_at': session?['expires_at'],
        'biometric_enabled': await _isBiometricEnabled(),
        'quick_login_enabled': await _isQuickLoginEnabled(),
        'failed_attempts': loginAttempts,
        'account_locked': await _isAccountLocked(),
        'last_login': session?['created_at'],
      };
    } catch (e) {
      debugPrint('❌ Failed to get auth stats: $e');
      return {};
    }
  }

  // Private helper methods

  Future<void> _handleSuccessfulLogin(
    AuthMethod method,
    AuthResult result,
  ) async {
    try {
      await _resetLoginAttempts();
      await _setLastLoginMethod(method);

      // Store enhanced session data
      if (result.user != null) {
        final sessionData = {
          'user_id': result.user!.id,
          'aiferid': result.user!.aiFERiD ?? '',
          'email': result.user!.email ?? '',
          'full_name': result.user!.fullName ?? '',
          'avatar_url': result.user!.avatarUrl ?? '',
          'auth_method': method.name,
          'wallet_data': result.user!.walletData,
          'created_at': DateTime.now().toIso8601String(),
          'expires_at':
              DateTime.now()
                  .add(Duration(days: _sessionDurationDays))
                  .toIso8601String(),
          'device_fingerprint': await _generateDeviceFingerprint(),
        };

        await _storeSession(sessionData);
      }
    } catch (e) {
      debugPrint('❌ Failed to handle successful login: $e');
    }
  }

  Future<void> _handleFailedLogin() async {
    try {
      final attempts = await _getLoginAttempts();
      await _setLoginAttempts(attempts + 1);
      await _setLastLoginAttempt(DateTime.now());
    } catch (e) {
      debugPrint('❌ Failed to handle failed login: $e');
    }
  }

  Future<bool> _isAccountLocked() async {
    try {
      final attempts = await _getLoginAttempts();
      if (attempts < _maxLoginAttempts) return false;

      final lastAttempt = await _getLastLoginAttempt();
      if (lastAttempt == null) return false;

      final lockoutEnd = lastAttempt.add(
        Duration(minutes: _lockoutDurationMinutes),
      );
      return DateTime.now().isBefore(lockoutEnd);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> _enrichUserData(
    Map<String, dynamic> authResponse,
  ) async {
    try {
      final userId = authResponse['user_id'];
      if (userId == null) return null;

      final userData = await _supabaseService.selectFromTable(
        'user_profiles',
        filters: {'id': userId},
        limit: 1,
      );

      return userData.isNotEmpty ? userData.first : null;
    } catch (e) {
      debugPrint('❌ Failed to enrich user data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getUserProfileData(String userId) async {
    try {
      final userData = await _supabaseService.selectFromTable(
        'user_profiles',
        filters: {'id': userId},
        limit: 1,
      );

      return userData.isNotEmpty ? userData.first : null;
    } catch (e) {
      debugPrint('❌ Failed to get user profile data: $e');
      return null;
    }
  }

  Future<AuthResult> _restoreSessionLogin(Map<String, dynamic> session) async {
    try {
      return AuthResult.success(
        user: AuthUser(
          id: session['user_id'],
          aiFERiD: session['aiferid'],
          email: session['email'],
          fullName: session['full_name'],
          avatarUrl: session['avatar_url'],
          walletData: session['wallet_data'],
          authMethod: AuthMethod.values.firstWhere(
            (method) => method.name == session['auth_method'],
            orElse: () => AuthMethod.aiferid,
          ),
        ),
        sessionToken: session['session_id'],
      );
    } catch (e) {
      return AuthResult.failure(
        error: 'Failed to restore session: ${e.toString()}',
        errorCode: 'SESSION_RESTORE_ERROR',
      );
    }
  }

  String _generateSecurityChallenge() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    final challenge = '$timestamp:$random';
    final bytes = utf8.encode(challenge);
    return sha256.convert(bytes).toString();
  }

  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999999);
    final sessionData = 'session:$timestamp:$random';
    final bytes = utf8.encode(sessionData);
    return sha256.convert(bytes).toString().substring(0, 32);
  }

  Future<String> _generateDeviceFingerprint() async {
    // Create a device fingerprint based on available information
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final platform = defaultTargetPlatform.name;
    final random = Random().nextInt(999999);
    final fingerprint = 'device:$platform:$timestamp:$random';
    final bytes = utf8.encode(fingerprint);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  String _generateSecurityHash(Map<String, dynamic> authData) {
    final dataString = json.encode(authData);
    final bytes = utf8.encode(dataString);
    return sha256.convert(bytes).toString();
  }

  String _generateBiometricHash() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    final biometricData = 'biometric:$timestamp:$random';
    final bytes = utf8.encode(biometricData);
    return sha256.convert(bytes).toString().substring(0, 24);
  }

  Future<void> _storeSession(Map<String, dynamic> sessionData) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final sessionJson = json.encode(sessionData);
      await _prefs?.setString(_renewedSessionKey, sessionJson);
    } catch (e) {
      debugPrint('❌ Failed to store session: $e');
    }
  }

  Future<Map<String, dynamic>?> _getLastSession() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final sessionJson = _prefs?.getString(_renewedSessionKey);
      if (sessionJson != null) {
        return Map<String, dynamic>.from(json.decode(sessionJson));
      }
    } catch (e) {
      debugPrint('❌ Failed to get last session: $e');
    }
    return null;
  }

  Future<void> _clearSession() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove(_renewedSessionKey);
    } catch (e) {
      debugPrint('❌ Failed to clear session: $e');
    }
  }

  bool _isSessionExpired(Map<String, dynamic> session) {
    try {
      final expiresAt = DateTime.parse(session['expires_at']);
      return DateTime.now().isAfter(expiresAt);
    } catch (e) {
      return true;
    }
  }

  Future<void> _cleanupExpiredSessions() async {
    try {
      final session = await _getLastSession();
      if (session != null && _isSessionExpired(session)) {
        await _clearSession();
      }
    } catch (e) {
      debugPrint('❌ Failed to cleanup expired sessions: $e');
    }
  }

  Future<bool> _isBiometricEnabled() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs?.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isQuickLoginEnabled() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs?.getBool(_quickLoginEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _setLastLoginMethod(AuthMethod method) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_lastLoginMethodKey, method.name);
    } catch (e) {
      debugPrint('❌ Failed to set last login method: $e');
    }
  }

  Future<int> _getLoginAttempts() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs?.getInt(_loginAttemptsKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _setLoginAttempts(int attempts) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setInt(_loginAttemptsKey, attempts);
    } catch (e) {
      debugPrint('❌ Failed to set login attempts: $e');
    }
  }

  Future<void> _resetLoginAttempts() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove(_loginAttemptsKey);
      await _prefs?.remove(_lastLoginAttemptKey);
    } catch (e) {
      debugPrint('❌ Failed to reset login attempts: $e');
    }
  }

  Future<DateTime?> _getLastLoginAttempt() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final timestamp = _prefs?.getInt(_lastLoginAttemptKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      debugPrint('❌ Failed to get last login attempt: $e');
    }
    return null;
  }

  Future<void> _setLastLoginAttempt(DateTime dateTime) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setInt(
        _lastLoginAttemptKey,
        dateTime.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('❌ Failed to set last login attempt: $e');
    }
  }
}

// Enhanced data models for renewed authentication

enum AuthMethod { aiferid, email, biometric, quickLogin }

class AuthUser {
  final String id;
  final String? aiFERiD;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final Map<String, dynamic>? walletData;
  final AuthMethod authMethod;

  AuthUser({
    required this.id,
    this.aiFERiD,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.walletData,
    required this.authMethod,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'aiferid': aiFERiD,
    'email': email,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'wallet_data': walletData,
    'auth_method': authMethod.name,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'],
    aiFERiD: json['aiferid'],
    email: json['email'],
    fullName: json['full_name'],
    avatarUrl: json['avatar_url'],
    walletData: json['wallet_data'],
    authMethod: AuthMethod.values.firstWhere(
      (method) => method.name == json['auth_method'],
      orElse: () => AuthMethod.aiferid,
    ),
  );
}

class AuthResult {
  final bool success;
  final AuthUser? user;
  final String? sessionToken;
  final String? error;
  final String? errorCode;

  AuthResult._({
    required this.success,
    this.user,
    this.sessionToken,
    this.error,
    this.errorCode,
  });

  factory AuthResult.success({required AuthUser user, String? sessionToken}) =>
      AuthResult._(success: true, user: user, sessionToken: sessionToken);

  factory AuthResult.failure({required String error, String? errorCode}) =>
      AuthResult._(success: false, error: error, errorCode: errorCode);
}
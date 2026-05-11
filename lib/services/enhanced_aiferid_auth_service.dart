import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'social_auth_service.dart';
import '../core/fer_quantum_encryption.dart';
import '../core/frequency_hopping.dart';

/// Enhanced AiFERiD Authentication Service for AIFER v11
/// Integrates social auth, biometric auth, and Sui blockchain support
/// Supports zkLogin-inspired zero-knowledge authentication
class EnhancedAiFERiDAuthService {
  static EnhancedAiFERiDAuthService? _instance;
  static EnhancedAiFERiDAuthService get instance => 
      _instance ??= EnhancedAiFERiDAuthService._();
  EnhancedAiFERiDAuthService._();

  final SocialAuthService _socialAuth = SocialAuthService.instance;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Active sessions
  Map<String, EnhancedSession> _activeSessions = {};
  StreamController<EnhancedAuthEvent>? _authEventController;

  /// Initialize authentication service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _socialAuth.initialize();
      await _loadLocalSessions();
      await _initializeSecurityModule();
      _setupAuthEventStream();
      _isInitialized = true;

      debugPrint('✅ Enhanced AiFERiD Authentication Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Enhanced AiFERiD Service: $e');
      rethrow;
    }
  }

  /// Set up authentication event stream
  void _setupAuthEventStream() {
    _authEventController = StreamController<EnhancedAuthEvent>.broadcast();
  }

  /// Emit authentication event
  void _emitAuthEvent(EnhancedAuthEvent event) {
    _authEventController?.add(event);
    debugPrint('🔐 Enhanced Auth Event: ${event.toString()}');
  }

  /// Stream of authentication events
  Stream<EnhancedAuthEvent> get authEvents => 
      _authEventController?.stream ?? const Stream.empty();

  /// Initialize security module
  Future<void> _initializeSecurityModule() async {
    // Initialize quantum encryption
    await FERQuantumEncryption.instance;
    
    // Initialize frequency hopping
    final nodeId = generateNodeId();
    await FERFrequencyHopping.instance.initialize(nodeId);
  }

  /// Authenticate with social provider
  Future<EnhancedAuthResult> authenticateWithSocial(
    SocialAuthType authType,
  ) async {
    try {
      _emitAuthEvent(EnhancedAuthEvent.socialAuthStarted);

      SocialAuthResult socialResult;

      switch (authType) {
        case SocialAuthType.google:
          socialResult = await _socialAuth.signInWithGoogle();
          break;
        case SocialAuthType.apple:
          socialResult = await _socialAuth.signInWithApple();
          break;
        default:
          return EnhancedAuthResult(
            success: false,
            error: 'Unsupported social auth type: $authType',
            authType: EnhancedAuthType.social,
          );
      }

      if (!socialResult.success || socialResult.user == null) {
        _emitAuthEvent(EnhancedAuthEvent.socialAuthFailed);
        return EnhancedAuthResult(
          success: false,
          error: socialResult.error ?? 'Social authentication failed',
          authType: EnhancedAuthType.social,
        );
      }

      // Generate or retrieve Sui blockchain address
      final suiAddress = await _generateSuiAddress(
        socialResult.user!,
      );

      // Create enhanced session
      final session = await _createSession(
        socialResult.user!,
        EnhancedAuthType.social,
        suiAddress: suiAddress,
      );

      // Store session
      await _storeSession(session);

      _emitAuthEvent(EnhancedAuthEvent.socialAuthSuccess);

      return EnhancedAuthResult(
        success: true,
        userId: socialResult.user!.id,
        sessionId: session.id,
        authType: EnhancedAuthType.social,
        suiAddress: suiAddress,
        expiresAt: session.expiresAt,
      );

    } catch (e) {
      debugPrint('❌ Social authentication failed: $e');
      _emitAuthEvent(EnhancedAuthEvent.socialAuthFailed);
      return EnhancedAuthResult(
        success: false,
        error: 'Social authentication failed: $e',
        authType: EnhancedAuthType.social,
      );
    }
  }

  /// Authenticate with biometrics
  Future<EnhancedAuthResult> authenticateWithBiometrics({
    String localizedReason = 'Authenticate to access AiFER OS',
  }) async {
    try {
      _emitAuthEvent(EnhancedAuthEvent.biometricAuthStarted);

      final isAvailable = await _socialAuth.isBiometricAvailable();
      if (!isAvailable) {
        return EnhancedAuthResult(
          success: false,
          error: 'Biometric authentication is not available',
          authType: EnhancedAuthType.biometric,
        );
      }

      final didAuthenticate = await _socialAuth.authenticateWithBiometrics(
        localizedReason: localizedReason,
      );

      if (!didAuthenticate) {
        _emitAuthEvent(EnhancedAuthEvent.biometricAuthFailed);
        return EnhancedAuthResult(
          success: false,
          error: 'Biometric authentication failed',
          authType: EnhancedAuthType.biometric,
        );
      }

      // Get existing user or create new one
      final existingUser = await _socialAuth.getCurrentUser();
      if (existingUser == null) {
        return EnhancedAuthResult(
          success: false,
          error: 'No existing session found. Please sign in first.',
          authType: EnhancedAuthType.biometric,
        );
      }

      // Create biometric session
      final session = await _createSession(
        existingUser,
        EnhancedAuthType.biometric,
      );

      // Store session
      await _storeSession(session);

      _emitAuthEvent(EnhancedAuthEvent.biometricAuthSuccess);

      return EnhancedAuthResult(
        success: true,
        userId: existingUser.id,
        sessionId: session.id,
        authType: EnhancedAuthType.biometric,
        expiresAt: session.expiresAt,
      );

    } catch (e) {
      debugPrint('❌ Biometric authentication failed: $e');
      _emitAuthEvent(EnhancedAuthEvent.biometricAuthFailed);
      return EnhancedAuthResult(
        success: false,
        error: 'Biometric authentication failed: $e',
        authType: EnhancedAuthType.biometric,
      );
    }
  }

  /// Authenticate with blockchain wallet
  Future<EnhancedAuthResult> authenticateWithWallet(
    String walletAddress,
    String signature,
    Map<String, dynamic> walletMetadata,
  ) async {
    try {
      _emitAuthEvent(EnhancedAuthEvent.walletAuthStarted);

      // Verify signature
      final isValidSignature = await _verifyBlockchainSignature(
        walletAddress,
        signature,
      );

      if (!isValidSignature) {
        _emitAuthEvent(EnhancedAuthEvent.walletAuthFailed);
        return EnhancedAuthResult(
          success: false,
          error: 'Invalid blockchain signature',
          authType: EnhancedAuthType.wallet,
        );
      }

      // Generate Sui address from wallet
      final suiAddress = await _generateSuiAddress(
        SocialUserProfile(
          id: generateUserId(),
          email: null,
          displayName: 'Wallet User',
          authType: SocialAuthType.wallet,
        ),
      );

      // Create session
      final session = await _createSession(
        SocialUserProfile(
          id: generateUserId(),
          email: null,
          displayName: 'Wallet User',
          authType: SocialAuthType.wallet,
        ),
        EnhancedAuthType.wallet,
        suiAddress: suiAddress,
      );

      // Store session
      await _storeSession(session);

      _emitAuthEvent(EnhancedAuthEvent.walletAuthSuccess);

      return EnhancedAuthResult(
        success: true,
        userId: session.userId,
        sessionId: session.id,
        authType: EnhancedAuthType.wallet,
        suiAddress: suiAddress,
        expiresAt: session.expiresAt,
      );

    } catch (e) {
      debugPrint('❌ Wallet authentication failed: $e');
      _emitAuthEvent(EnhancedAuthEvent.walletAuthFailed);
      return EnhancedAuthResult(
        success: false,
        error: 'Wallet authentication failed: $e',
        authType: EnhancedAuthType.wallet,
      );
    }
  }

  /// Generate Sui blockchain address
  /// This is a placeholder implementation
  /// Full implementation would use zkLogin prover and derive address
  Future<String> _generateSuiAddress(SocialUserProfile user) async {
    // Placeholder: Derive address from user ID
    // In full implementation, this would:
    // 1. Generate ZK proof using Sui's zkLogin prover
    // 2. Derive Sui address from the proof
    
    final hash = sha256.convert(utf8.encode('sui_${user.id}_${user.authType}'));
    final addressBytes = hash.bytes.take(20).toList();
    final address = addressBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    
    return '0x$address';
  }

  /// Create authentication session
  Future<EnhancedSession> _createSession(
    SocialUserProfile user,
    EnhancedAuthType authType, {
    String? suiAddress,
  }) async {
    final sessionId = generateSessionId();
    final expiresAt = DateTime.now().add(const Duration(days: 30));

    final session = EnhancedSession(
      id: sessionId,
      userId: user.id,
      authType: authType,
      expiresAt: expiresAt,
      suiAddress: suiAddress,
      userProfile: user,
      createdAt: DateTime.now(),
    );

    _activeSessions[sessionId] = session;
    return session;
  }

  /// Store session locally
  Future<void> _storeSession(EnhancedSession session) async {
    try {
      final sessionJson = jsonEncode(session.toJson());
      await _prefs?.setString('current_session', sessionJson);
      debugPrint('✅ Session stored: ${session.id}');
    } catch (e) {
      debugPrint('❌ Failed to store session: $e');
    }
  }

  /// Load local sessions
  Future<void> _loadLocalSessions() async {
    try {
      final sessionJson = _prefs?.getString('current_session');
      if (sessionJson != null) {
        final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
        final session = EnhancedSession.fromJson(sessionMap);
        
        // Check if session is still valid
        if (session.expiresAt.isAfter(DateTime.now())) {
          _activeSessions[session.id] = session;
          debugPrint('✅ Session loaded: ${session.id}');
        } else {
          debugPrint('⚠️  Session expired: ${session.id}');
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load sessions: $e');
    }
  }

  /// Get current session
  Future<EnhancedSession?> getCurrentSession() async {
    try {
      final sessionJson = _prefs?.getString('current_session');
      if (sessionJson == null) return null;

      final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
      final session = EnhancedSession.fromJson(sessionMap);

      if (session.expiresAt.isBefore(DateTime.now())) {
        await logout();
        return null;
      }

      return session;

    } catch (e) {
      debugPrint('❌ Failed to get current session: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final session = await getCurrentSession();
    return session != null;
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await _socialAuth.signOut();
      await _prefs?.remove('current_session');
      _activeSessions.clear();
      _emitAuthEvent(EnhancedAuthEvent.signedOut);
      debugPrint('✅ Signed out');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
    }
  }

  /// Verify blockchain signature
  Future<bool> _verifyBlockchainSignature(
    String walletAddress,
    String signature,
  ) async {
    // Placeholder implementation
    // In full implementation, this would verify the signature on the blockchain
    debugPrint('⚠️  Signature verification (placeholder)');
    return true;
  }

  /// Generate unique node ID
  String generateNodeId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(10000);
    final hash = sha256.convert(utf8.encode('node_$timestamp$random'));
    return hash.toString().substring(0, 16);
  }

  /// Generate unique user ID
  String generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(10000);
    final hash = sha256.convert(utf8.encode('user_$timestamp$random'));
    return hash.toString().substring(0, 16);
  }

  /// Generate unique session ID
  String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(10000);
    final hash = sha256.convert(utf8.encode('session_$timestamp$random'));
    return hash.toString().substring(0, 16);
  }

  /// Dispose resources
  void dispose() {
    _authEventController?.close();
    _socialAuth.dispose();
  }
}

/// Enhanced authentication result
class EnhancedAuthResult {
  final bool success;
  final String? userId;
  final String? sessionId;
  final String? suiAddress;
  final String? error;
  final EnhancedAuthType authType;
  final DateTime? expiresAt;

  EnhancedAuthResult({
    required this.success,
    this.userId,
    this.sessionId,
    this.suiAddress,
    this.error,
    required this.authType,
    this.expiresAt,
  });
}

/// Enhanced session data class
class EnhancedSession {
  final String id;
  final String userId;
  final EnhancedAuthType authType;
  final DateTime expiresAt;
  final String? suiAddress;
  final SocialUserProfile? userProfile;
  final DateTime createdAt;

  EnhancedSession({
    required this.id,
    required this.userId,
    required this.authType,
    required this.expiresAt,
    this.suiAddress,
    this.userProfile,
    required this.createdAt,
  });

  factory EnhancedSession.fromJson(Map<String, dynamic> json) {
    return EnhancedSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      authType: EnhancedAuthType.values.firstWhere(
        (e) => e.toString() == 'EnhancedAuthType.${json['authType']}',
        orElse: () => EnhancedAuthType.social,
      ),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      suiAddress: json['suiAddress'] as String?,
      userProfile: json['userProfile'] != null
          ? SocialUserProfile.fromJson(json['userProfile'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'authType': authType.toString().split('.').last,
      'expiresAt': expiresAt.toIso8601String(),
      'suiAddress': suiAddress,
      'userProfile': userProfile?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Enhanced authentication type enum
enum EnhancedAuthType {
  social,
  biometric,
  wallet,
  anonymous,
}

/// Enhanced authentication events
enum EnhancedAuthEvent {
  socialAuthStarted,
  socialAuthSuccess,
  socialAuthFailed,
  biometricAuthStarted,
  biometricAuthSuccess,
  biometricAuthFailed,
  walletAuthStarted,
  walletAuthSuccess,
  walletAuthFailed,
  signedOut,
}
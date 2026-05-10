<![CDATA[import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/fer_quantum_encryption.dart';
import '../core/frequency_hopping.dart';

/// AiFERiD Authentication Service
/// Combines blockchain wallet authentication with privacy-focused anonymous access
class AiFERiDAuthService {
  static AiFERiDAuthService? _instance;
  static AiFERiDAuthService get instance => _instance ??= AiFERiDAuthService._();
  AiFERiDAuthService._();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  Map<String, AiFERiDSession> _activeSessions = {};
  StreamController<AiFERiDAuthEvent>? _authEventController;
  
  /// Initialize authentication service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadLocalSessions();
      await _initializeSecurityModule();
      _setupAuthEventStream();
      _isInitialized = true;
      
      debugPrint('✅ AiFERiD Authentication Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize AiFERiD Service: $e');
      rethrow;
    }
  }
  
  /// Authenticate with blockchain wallet
  Future<AiFERiDAuthResult> authenticateWithWallet(
    String walletAddress,
    String signature,
    Map<String, dynamic> walletMetadata,
  ) async {
    try {
      _emitAuthEvent(AiFERiDAuthEvent.walletAuthenticationStarted);
      
      // Verify signature on blockchain
      final isValidSignature = await _verifyBlockchainSignature(
        walletAddress,
        signature,
      );
      
      if (!isValidSignature) {
        _emitAuthEvent(AiFERiDAuthEvent.walletAuthenticationFailed);
        return AiFERiDAuthResult(
          success: false,
          error: 'Invalid blockchain signature',
          authType: AiFERiDAuthType.wallet,
        );
      }
      
      // Create or retrieve user profile
      final userProfile = await _getOrCreateUserProfile(
        walletAddress,
        walletMetadata,
      );
      
      // Generate authentication session
      final session = await _createAuthenticationSession(
        userProfile,
        AiFERiDAuthType.wallet,
        walletMetadata: walletMetadata,
      );
      
      // Store session locally
      await _storeLocalSession(session);
      
      _emitAuthEvent(AiFERiDAuthEvent.walletAuthenticationSuccess);
      
      return AiFERiDAuthResult(
        success: true,
        userId: userProfile.id,
        sessionId: session.id,
        authType: AiFERiDAuthType.wallet,
        expiresAt: session.expiresAt,
      );
      
    } catch (e) {
      _emitAuthEvent(AiFERiDAuthEvent.walletAuthenticationFailed);
      return AiFERiDAuthResult(
        success: false,
        error: 'Wallet authentication failed: $e',
        authType: AiFERiDAuthType.wallet,
      );
    }
  }
  
  /// Create anonymous access session
  Future<AiFERiDAuthResult> createAnonymousSession({
    Duration duration = const Duration(hours: 24),
    Map<String, dynamic> preferences = const {},
    String ferretName = '',
  }) async {
    try {
      _emitAuthEvent(AiFERiDAuthEvent.anonymousAccessRequested);
      
      // Generate anonymous ferret identity
      final anonymousProfile = await _createAnonymousFerretProfile(
        duration,
        preferences,
        ferretName,
      );
      
      // Create anonymous session
      final session = await _createAuthenticationSession(
        anonymousProfile,
        AiFERiDAuthType.anonymousFerret,
        metadata: preferences,
      );
      
      // Store session in memory only (no persistent storage)
      _activeSessions[session.id] = session;
      
      _emitAuthEvent(AiFERiDAuthEvent.anonymousAccessGranted);
      
      return AiFERiDAuthResult(
        success: true,
        userId: anonymousProfile.id,
        sessionId: session.id,
        authType: AiFERiDAuthType.anonymousFerret,
        expiresAt: session.expiresAt,
        ferretId: anonymousProfile.ferretId,
      );
      
    } catch (e) {
      _emitAuthEvent(AiFERiDAuthEvent.anonymousAccessFailed);
      return AiFERiDAuthResult(
        success: false,
        error: 'Failed to create anonymous session: $e',
        authType: AiFERiDAuthType.anonymousFerret,
      );
    }
  }
  
  /// Multi-factor authentication
  Future<AiFERiDAuthResult> authenticateMultiFactor({
    required String walletAddress,
    required String signature,
    required Map<String, dynamic> walletMetadata,
    bool requireBiometric = false,
  }) async {
    try {
      _emitAuthEvent(AiFERiDAuthEvent.multiFactorAuthStarted);
      
      // Step 1: Wallet authentication
      final walletResult = await authenticateWithWallet(
        walletAddress,
        signature,
        walletMetadata,
      );
      
      if (!walletResult.success) {
        return walletResult;
      }
      
      // Step 2: Biometric verification (if required)
      if (requireBiometric) {
        final biometricResult = await _verifyBiometricAuthentication();
        if (!biometricResult) {
          _emitAuthEvent(AiFERiDAuthEvent.multiFactorAuthFailed);
          return AiFERiDAuthResult(
            success: false,
            error: 'Biometric verification failed',
            authType: AiFERiDAuthType.multiFactor,
          );
        }
      }
      
      // Step 3: Session verification
      final session = _activeSessions[walletResult.sessionId];
      if (session == null) {
        return AiFERiDAuthResult(
          success: false,
          error: 'Session not found',
          authType: AiFERiDAuthType.multiFactor,
        );
      }
      
      // Upgrade session to multi-factor
      final upgradedSession = session.copyWith(
        authType: AiFERiDAuthType.multiFactor,
        metadata: {...session.metadata, 'multiFactorVerified': true},
      );
      
      _activeSessions[walletResult.sessionId!] = upgradedSession;
      await _storeLocalSession(upgradedSession);
      
      _emitAuthEvent(AiFERiDAuthEvent.multiFactorAuthSuccess);
      
      return AiFERiDAuthResult(
        success: true,
        userId: walletResult.userId,
        sessionId: walletResult.sessionId,
        authType: AiFERiDAuthType.multiFactor,
        expiresAt: upgradedSession.expiresAt,
      );
      
    } catch (e) {
      _emitAuthEvent(AiFERiDAuthEvent.multiFactorAuthFailed);
      return AiFERiDAuthResult(
        success: false,
        error: 'Multi-factor authentication failed: $e',
        authType: AiFERiDAuthType.multiFactor,
      );
    }
  }
  
  /// Get current authenticated user
  AiFERiDUserProfile? getCurrentUser() {
    // Find the most recent active session
    final activeSessions = _activeSessions.values.where((s) => s.isActive).toList();
    if (activeSessions.isEmpty) return null;
    
    activeSessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final session = activeSessions.first;
    
    return _getUserProfileFromSession(session);
  }
  
  /// Logout user
  Future<void> logout(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session != null) {
      session.isActive = false;
      await _updateLocalSession(session);
      
      if (session.authType == AiFERiDAuthType.anonymousFerret) {
        // Remove anonymous sessions completely
        _activeSessions.remove(sessionId);
      }
      
      _emitAuthEvent(AiFERiDAuthEvent.sessionEnded);
      debugPrint('👋 User logged out: ${session.userId}');
    }
  }
  
  /// Logout all sessions
  Future<void> logoutAll() async {
    for (final session in _activeSessions.values) {
      session.isActive = false;
      await _updateLocalSession(session);
    }
    
    _activeSessions.clear();
    _emitAuthEvent(AiFERiDAuthEvent.allSessionsEnded);
    debugPrint('👋 All users logged out');
  }
  
  /// Refresh session
  Future<bool> refreshSession(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null) return false;
    
    // Check if session is expired
    if (DateTime.now().isAfter(session.expiresAt)) {
      await logout(sessionId);
      return false;
    }
    
    // Extend session
    final refreshedSession = session.copyWith(
      expiresAt: DateTime.now().add(Duration(hours: 24)),
      lastActivity: DateTime.now(),
    );
    
    _activeSessions[sessionId] = refreshedSession;
    await _updateLocalSession(refreshedSession);
    
    return true;
  }
  
  /// Create or retrieve user profile from blockchain
  Future<AiFERiDUserProfile> _getOrCreateUserProfile(
    String walletAddress,
    Map<String, dynamic> metadata,
  ) async {
    try {
      // Check if profile exists locally first
      final localProfile = await _getLocalUserProfile(walletAddress);
      if (localProfile != null) {
        return localProfile;
      }
      
      // Query blockchain for existing profile (simulated)
      final blockchainProfile = await _queryBlockchainProfile(walletAddress);
      if (blockchainProfile != null) {
        await _storeLocalUserProfile(blockchainProfile);
        return blockchainProfile;
      }
      
      // Create new profile
      final newProfile = AiFERiDUserProfile(
        id: _generateUserId(),
        walletAddress: walletAddress,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        authType: AiFERiDAuthType.wallet,
        metadata: metadata,
        isActive: true,
      );
      
      // Store on blockchain (simulated)
      await _storeBlockchainProfile(newProfile);
      
      // Store locally
      await _storeLocalUserProfile(newProfile);
      
      return newProfile;
      
    } catch (e) {
      throw AiFERiDAuthException('Failed to create/retrieve user profile: $e');
    }
  }
  
  /// Create anonymous ferret profile
  Future<AiFERiDUserProfile> _createAnonymousFerretProfile(
    Duration duration,
    Map<String, dynamic> preferences,
    String ferretName,
  ) async {
    final ferretId = ferretName.isEmpty ? _generateFerretId() : ferretName;
    
    return AiFERiDUserProfile(
      id: _generateUserId(),
      walletAddress: '',
      ferretId: ferretId,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      authType: AiFERiDAuthType.anonymousFerret,
      metadata: {
        ...preferences,
        'isAnonymous': true,
        'duration': duration.inHours.toString(),
      },
      isActive: true,
      expiresAt: DateTime.now().add(duration),
    );
  }
  
  /// Create authentication session
  Future<AiFERiDSession> _createAuthenticationSession(
    AiFERiDUserProfile userProfile,
    AiFERiDAuthType authType, {
    Map<String, dynamic>? walletMetadata,
    Map<String, dynamic>? metadata,
  }) async {
    final sessionId = _generateSecureSessionId();
    final sessionToken = await _generateSessionToken(userProfile, sessionId);
    final expiresAt = DateTime.now().add(Duration(hours: 24));
    
    final session = AiFERiDSession(
      id: sessionId,
      userId: userProfile.id,
      token: sessionToken,
      authType: authType,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      lastActivity: DateTime.now(),
      isActive: true,
      metadata: {...?walletMetadata, ...?metadata ?? {}},
    );
    
    _activeSessions[sessionId] = session;
    return session;
  }
  
  /// Verify blockchain signature
  Future<bool> _verifyBlockchainSignature(
    String walletAddress,
    String signature,
  ) async {
    try {
      // Simulate blockchain signature verification
      final message = 'FER_Auth_${DateTime.now().millisecondsSinceEpoch}';
      final expectedAddress = await _recoverAddressFromSignature(message, signature);
      
      return expectedAddress.toLowerCase() == walletAddress.toLowerCase();
    } catch (e) {
      debugPrint('Signature verification failed: $e');
      return false;
    }
  }
  
  /// Generate secure session ID
  String _generateSecureSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = _generateRandomBytes(32);
    final combined = '$timestamp$randomBytes';
    
    return sha256.convert(utf8.encode(combined)).toString();
  }
  
  /// Generate session token
  Future<String> _generateSessionToken(
    AiFERiDUserProfile userProfile,
    String sessionId,
  ) async {
    final tokenData = {
      'userId': userProfile.id,
      'sessionId': sessionId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expires': DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
    };
    
    final tokenString = json.encode(tokenData);
    final encryptedToken = await _encryptToken(tokenString);
    
    return base64.encode(encryptedToken);
  }
  
  /// Generate user ID
  String _generateUserId() {
    return 'fer_user_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }
  
  /// Generate ferret ID for anonymous users
  String _generateFerretId() {
    final adjectives = [
      'Silent', 'Shadow', 'Quick', 'Clever', 'Brave', 'Swift', 'Stealth',
      'Phantom', 'Ninja', 'Ghost', 'Eagle', 'Wolf', 'Lynx', 'Fox',
    ];
    final animals = [
      'Ferret', 'Weasel', 'Marten', 'Stoat', 'Mink', 'Otter', 'Badger',
      'Wolverine', 'Fisher', 'Polecat', 'Ermine', 'Sable',
    ];
    final random = Random();
    
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final animal = animals[random.nextInt(animals.length)];
    final number = random.nextInt(9999) + 1;
    
    return '${adjective}${animal}$number';
  }
  
  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  
  /// Generate random bytes (simulated)
  String _generateRandomBytes(int length) {
    final random = Random();
    final bytes = List.generate(length, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
  
  /// Initialize security module
  Future<void> _initializeSecurityModule() async {
    // Initialize quantum encryption for secure session management
    await FERQuantumEncryption.instance.generateKeyPair();
    
    // Initialize frequency hopping for secure communication
    await FERFrequencyHopping.instance.initialize('auth_service');
    
    debugPrint('🔐 Security module initialized');
  }
  
  /// Setup authentication event stream
  void _setupAuthEventStream() {
    _authEventController = StreamController<AiFERiDAuthEvent>.broadcast();
  }
  
  /// Emit authentication event
  void _emitAuthEvent(AiFERiDAuthEvent event) {
    _authEventController?.add(event);
    debugPrint('🔐 Auth event: ${event.toString()}');
  }
  
  /// Get authentication event stream
  Stream<AiFERiDAuthEvent> get authEvents => 
      _authEventController?.stream ?? Stream.empty();
  
  /// Store local session
  Future<void> _storeLocalSession(AiFERiDSession session) async {
    if (session.authType == AiFERiDAuthType.anonymousFerret) {
      // Don't store anonymous sessions persistently
      return;
    }
    
    final sessionsJson = _prefs?.getString('active_sessions') ?? '{}';
    final sessions = Map<String, dynamic>.from(json.decode(sessionsJson));
    
    sessions[session.id] = session.toJson();
    await _prefs?.setString('active_sessions', json.encode(sessions));
  }
  
  /// Update local session
  Future<void> _updateLocalSession(AiFERiDSession session) async {
    if (session.authType == AiFERiDAuthType.anonymousFerret) {
      return;
    }
    
    await _storeLocalSession(session);
  }
  
  /// Load local sessions
  Future<void> _loadLocalSessions() async {
    try {
      final sessionsJson = _prefs?.getString('active_sessions') ?? '{}';
      final sessions = Map<String, dynamic>.from(json.decode(sessionsJson));
      
      for (final entry in sessions.entries) {
        final session = AiFERiDSession.fromJson(entry.value);
        
        // Only load non-expired sessions
        if (DateTime.now().isBefore(session.expiresAt)) {
          _activeSessions[entry.key] = session;
        }
      }
      
      debugPrint('📦 Loaded ${_activeSessions.length} local sessions');
    } catch (e) {
      debugPrint('❌ Failed to load local sessions: $e');
    }
  }
  
  /// Get local user profile
  Future<AiFERiDUserProfile?> _getLocalUserProfile(String walletAddress) async {
    try {
      final profilesJson = _prefs?.getString('user_profiles') ?? '{}';
      final profiles = Map<String, dynamic>.from(json.decode(profilesJson));
      
      final profileData = profiles[walletAddress];
      if (profileData != null) {
        return AiFERiDUserProfile.fromJson(profileData);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get local user profile: $e');
      return null;
    }
  }
  
  /// Store local user profile
  Future<void> _storeLocalUserProfile(AiFERiDUserProfile profile) async {
    final profilesJson = _prefs?.getString('user_profiles') ?? '{}';
    final profiles = Map<String, dynamic>.from(json.decode(profilesJson));
    
    profiles[profile.walletAddress] = profile.toJson();
    await _prefs?.setString('user_profiles', json.encode(profiles));
  }
  
  /// Query blockchain profile (simulated)
  Future<AiFERiDUserProfile?> _queryBlockchainProfile(String walletAddress) async {
    // Simulate blockchain query
    await Future.delayed(Duration(milliseconds: 500));
    return null; // Return null for new users
  }
  
  /// Store blockchain profile (simulated)
  Future<void> _storeBlockchainProfile(AiFERiDUserProfile profile) async {
    // Simulate blockchain storage
    await Future.delayed(Duration(milliseconds: 1000));
    debugPrint('⛓️ Profile stored on blockchain: ${profile.walletAddress}');
  }
  
  /// Recover address from signature (simulated)
  Future<String> _recoverAddressFromSignature(String message, String signature) async {
    // Simulate address recovery
    await Future.delayed(Duration(milliseconds: 200));
    return '0x${signature.substring(0, 40)}';
  }
  
  /// Encrypt token
  Future<List<int>> _encryptToken(String token) async {
    // Simple encryption simulation
    return utf8.encode(token).map((byte) => byte ^ 0x55).toList();
  }
  
  /// Verify biometric authentication
  Future<bool> _verifyBiometricAuthentication() async {
    // Simulate biometric verification
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }
  
  /// Get user profile from session
  AiFERiDUserProfile _getUserProfileFromSession(AiFERiDSession session) {
    if (session.authType == AiFERiDAuthType.anonymousFerret) {
      return AiFERiDUserProfile(
        id: session.userId,
        walletAddress: '',
        ferretId: session.metadata['ferretId'] ?? 'AnonymousFerret',
        createdAt: session.createdAt,
        lastLogin: session.lastActivity,
        authType: session.authType,
        metadata: session.metadata,
        isActive: session.isActive,
        expiresAt: session.expiresAt,
      );
    } else {
      return AiFERiDUserProfile(
        id: session.userId,
        walletAddress: session.metadata['walletAddress'] ?? '',
        createdAt: session.createdAt,
        lastLogin: session.lastActivity,
        authType: session.authType,
        metadata: session.metadata,
        isActive: session.isActive,
      );
    }
  }
  
  /// Cleanup expired sessions
  void cleanupExpiredSessions() {
    final now = DateTime.now();
    final expiredSessions = <String>[];
    
    for (final entry in _activeSessions.entries) {
      if (now.isAfter(entry.value.expiresAt)) {
        expiredSessions.add(entry.key);
      }
    }
    
    for (final sessionId in expiredSessions) {
      logout(sessionId);
    }
    
    if (expiredSessions.isNotEmpty) {
      debugPrint('🧹 Cleaned up ${expiredSessions.length} expired sessions');
    }
  }
}

/// User profile for AiFERiD authentication
class AiFERiDUserProfile {
  final String id;
  final String walletAddress;
  final String ferretId; // For anonymous users
  final DateTime createdAt;
  final DateTime lastLogin;
  final AiFERiDAuthType authType;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime? expiresAt; // For anonymous sessions
  
  AiFERiDUserProfile({
    required this.id,
    this.walletAddress = '',
    this.ferretId = '',
    required this.createdAt,
    required this.lastLogin,
    required this.authType,
    this.metadata = const {},
    this.isActive = true,
    this.expiresAt,
  });
  
  factory AiFERiDUserProfile.fromJson(Map<String, dynamic> json) {
    return AiFERiDUserProfile(
      id: json['id'] ?? '',
      walletAddress: json['walletAddress'] ?? '',
      ferretId: json['ferretId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(json['lastLogin'] ?? DateTime.now().toIso8601String()),
      authType: AiFERiDAuthType.values.firstWhere(
        (e) => e.toString() == json['authType'],
        orElse: () => AiFERiDAuthType.wallet,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isActive: json['isActive'] ?? true,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletAddress': walletAddress,
      'ferretId': ferretId,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'authType': authType.toString(),
      'metadata': metadata,
      'isActive': isActive,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

/// Authentication session
class AiFERiDSession {
  final String id;
  final String userId;
  final String token;
  final AiFERiDAuthType authType;
  final DateTime createdAt;
  final DateTime expiresAt;
  DateTime lastActivity;
  bool isActive;
  final Map<String, dynamic> metadata;
  
  AiFERiDSession({
    required this.id,
    required this.userId,
    required this.token,
    required this.authType,
    required this.createdAt,
    required this.expiresAt,
    required this.lastActivity,
    this.isActive = true,
    this.metadata = const {},
  });
  
  AiFERiDSession copyWith({
    AiFERiDAuthType? authType,
    DateTime? expiresAt,
    DateTime? lastActivity,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return AiFERiDSession(
      id: id,
      userId: userId,
      token: token,
      authType: authType ?? this.authType,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
  
  factory AiFERiDSession.fromJson(Map<String, dynamic> json) {
    return AiFERiDSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      token: json['token'] ?? '',
      authType: AiFERiDAuthType.values.firstWhere(
        (e) => e.toString() == json['authType'],
        orElse: () => AiFERiDAuthType.wallet,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'token': token,
      'authType': authType.toString(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }
}

/// Authentication result
class AiFERiDAuthResult {
  final bool success;
  final String? userId;
  final String? sessionId;
  final String? ferretId;
  final String? error;
  final AiFERiDAuthType authType;
  final DateTime? expiresAt;
  
  AiFERiDAuthResult({
    required this.success,
    this.userId,
    this.sessionId,
    this.ferretId,
    this.error,
    required this.authType,
    this.expiresAt,
  });
}

/// Authentication types
enum AiFERiDAuthType {
  wallet,
  anonymousFerret,
  biometric,
  multiFactor,
}

/// Authentication events
enum AiFERiDAuthEvent {
  walletAuthenticationStarted,
  walletAuthenticationSuccess,
  walletAuthenticationFailed,
  anonymousAccessRequested,
  anonymousAccessGranted,
  anonymousAccessFailed,
  multiFactorAuthStarted,
  multiFactorAuthSuccess,
  multiFactorAuthFailed,
  sessionEnded,
  allSessionsEnded,
}

/// Authentication exception
class AiFERiDAuthException implements Exception {
  final String message;
  AiFERiDAuthException(this.message);
  
  @override
  String toString() => 'AiFERiDAuthException: $message';
}
]]>
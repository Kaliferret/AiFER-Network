import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';
import './blockchain_wallet_service.dart';

/// Comprehensive authentication service for AiFER Network
/// Handles sign up, sign in, sign out, user management, and blockchain wallet authentication
class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Listen to authentication state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
          'avatar_url': avatarUrl ?? '',
          'role': 'user',
        },
      );

      if (response.user != null) {
        // Create initial device settings for new user
        await _createInitialDeviceSettings(response.user!.id);

        // Create Chad conversation for new user
        await _createChadConversation(response.user!.id);

        // Note: Blockchain wallet will be created during authentication setup flow
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in existing user with email/password or wallet authentication
  Future<AuthResponse> signIn({
    required String email,
    required String password,
    String? walletAddress,
    String? walletSignature,
  }) async {
    try {
      // Standard email/password authentication
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // If wallet credentials provided, verify wallet ownership
      if (response.user != null &&
          walletAddress != null &&
          walletSignature != null) {
        await _verifyWalletForUser(
          response.user!.id,
          walletAddress,
          walletSignature,
        );
      }

      return response;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Authenticate using blockchain wallet (offline-capable)
  Future<Map<String, dynamic>> signInWithWallet({
    required String walletAddress,
    required String message,
    required String signature,
  }) async {
    try {
      final _walletService = BlockchainWalletService.instance;
      // Verify wallet signature
      final isValidSignature = await _walletService.verifyWalletOwnership(
        walletAddress: walletAddress,
        message: message,
        signature: signature,
      );

      if (!isValidSignature) {
        throw Exception('Invalid wallet signature');
      }

      // Get user associated with this wallet
      final walletData =
          await _client
              .from('blockchain_wallets')
              .select('user_id, wallet_name')
              .eq('wallet_address', walletAddress)
              .eq('is_verified', true)
              .single();

      final userId = walletData['user_id'];

      // Create offline session for future offline authentication
      final sessionToken = await _walletService.createOfflineSession(
        userId: userId,
        walletAddress: walletAddress,
        signature: signature,
      );

      // Get user profile
      final userProfile =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', userId)
              .single();

      return {
        'success': true,
        'user_id': userId,
        'wallet_address': walletAddress,
        'wallet_name': walletData['wallet_name'],
        'session_token': sessionToken,
        'user_profile': userProfile,
        'offline_enabled': true,
      };
    } catch (e) {
      throw Exception('Wallet authentication failed: ${e.toString()}');
    }
  }

  /// Authenticate offline using stored session
  Future<bool> authenticateOffline({
    required String sessionToken,
    required String walletAddress,
  }) async {
    final _walletService = BlockchainWalletService.instance;
    return await _walletService.authenticateOffline(
      sessionToken: sessionToken,
      walletAddress: walletAddress,
    );
  }

  /// Sign out current user and clear offline sessions
  Future<void> signOut() async {
    try {
      final _walletService = BlockchainWalletService.instance;
      // Clear offline session data
      await _walletService.clearOfflineSession();

      // Sign out from Supabase
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _client.auth.updateUser(
        UserAttributes(data: updates),
      );

      // Also update user_profiles table
      if (currentUser != null && updates.isNotEmpty) {
        await _client
            .from('user_profiles')
            .update({
              if (fullName != null) 'full_name': fullName,
              if (avatarUrl != null) 'avatar_url': avatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', currentUser!.id);
      }

      return response;
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  /// Get user profile data including wallet information
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response =
          await _client
              .from('user_profiles')
              .select('''
            *,
            blockchain_wallets!preferred_wallet_id(
              id, wallet_address, wallet_name, wallet_type, is_verified
            )
          ''')
              .eq('id', currentUser!.id)
              .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Check if user has blockchain wallet enabled
  Future<bool> hasBlockchainWallet() async {
    if (!isAuthenticated) return false;

    try {
      final profile =
          await _client
              .from('user_profiles')
              .select('wallet_enabled')
              .eq('id', currentUser!.id)
              .single();

      return profile['wallet_enabled'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's blockchain wallets
  Future<List<Map<String, dynamic>>> getUserWallets() async {
    if (!isAuthenticated) return [];
    final _walletService = BlockchainWalletService.instance;
    return await _walletService.getUserWallets(currentUser!.id);
  }

  /// Check if offline access is available
  Future<bool> isOfflineAccessEnabled() async {
    if (!isAuthenticated) return false;
    final _walletService = BlockchainWalletService.instance;
    return await _walletService.hasOfflineAccess(currentUser!.id);
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (!isAuthenticated) throw Exception('No authenticated user');

    try {
      final _walletService = BlockchainWalletService.instance;
      // Clear offline sessions
      await _walletService.clearOfflineSession();

      // Delete user data first (cascading will handle related data)
      await _client.from('user_profiles').delete().eq('id', currentUser!.id);

      // Then delete auth user
      await _client.auth.admin.deleteUser(currentUser!.id);
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<void> _verifyWalletForUser(
    String userId,
    String walletAddress,
    String signature,
  ) async {
    try {
      final _walletService = BlockchainWalletService.instance;
      final message =
          'AiFER Network Authentication ${DateTime.now().millisecondsSinceEpoch}';

      final isValid = await _walletService.verifyWalletOwnership(
        walletAddress: walletAddress,
        message: message,
        signature: signature,
      );

      if (isValid) {
        // Update last wallet verification
        await _client
            .from('user_profiles')
            .update({
              'last_wallet_verification': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }
    } catch (e) {
      // Log error but don't fail authentication
      print('Wallet verification failed: $e');
    }
  }

  /// Create initial device settings for new user
  Future<void> _createInitialDeviceSettings(String userId) async {
    try {
      await _client.from('device_settings').insert({
        'user_id': userId,
        'device_name': 'AiFER Network Device',
        'mesh_network_enabled': true,
        'blockchain_sync_enabled': true,
        'emergency_mode_enabled': false,
        'auto_discovery_enabled': true,
        'battery_saver_mode': false,
        'quantum_encryption': true,
        'voice_commands': false,
        'biometric_auth': true,
        'selected_frequency': '2.4GHz',
        'transmission_power': 75,
        'max_connections': 10,
        'node_role': 'mesh_node',
        'gaming_mode_enabled': false,
        'low_latency_mode': false,
        'gaming_priority': 50,
        'auto_lock_enabled': true,
        'lock_timeout_minutes': 5,
        'remote_wipe_enabled': false,
      });
    } catch (e) {
      // Log error but don't fail auth process
      print('Failed to create initial device settings: $e');
    }
  }

  /// Create initial Chad conversation for new user
  Future<void> _createChadConversation(String userId) async {
    try {
      await _client.from('chad_conversations').insert({
        'user_id': userId,
        'name': 'Chad Assistant',
        'avatar_url':
            'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg',
        'avatar_semantic_label':
            'Chad AI avatar showing digital neural network pattern in cyan and blue colors representing AiFER Network',
        'last_message': 'Welcome to AiFER Network! How can I help you today?',
        'conversation_type': 'chad_assistant',
        'package_type': '.AiF',
        'is_chad_conversation': true,
      });

      // Add initial welcome message
      final conversationResponse =
          await _client
              .from('chad_conversations')
              .select('id')
              .eq('user_id', userId)
              .eq('is_chad_conversation', true)
              .single();

      await _client.from('chad_messages').insert({
        'conversation_id': conversationResponse['id'],
        'sender_id': userId,
        'content':
            'Welcome to AiFER Network! I\'m Chad, your AI assistant. Your blockchain wallet is now ready for secure FERMesh access. How can I help you optimize your network today?',
        'message_type': 'text',
        'package_type': '.AiF',
        'is_from_chad': true,
        'status': 'delivered',
        'chad_response_data': {'model': 'Chad-v1.0', 'welcome_message': true},
      });
    } catch (e) {
      // Log error but don't fail auth process
      print('Failed to create Chad conversation: $e');
    }
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    if (!isAuthenticated) return false;

    try {
      final profile = await getUserProfile();
      return profile?['full_name']?.isNotEmpty == true;
    } catch (e) {
      return false;
    }
  }

  /// Get user statistics including wallet information
  Future<Map<String, dynamic>> getUserStats() async {
    if (!isAuthenticated) return {};

    try {
      // Get gaming stats
      final gamingStatsResponse = await _client
          .from('gaming_stats')
          .select()
          .eq('user_id', currentUser!.id);

      // Get message count
      final messageCountResponse =
          await _client
              .from('chad_messages')
              .select('id')
              .eq('sender_id', currentUser!.id)
              .count();

      // Get exploration sessions
      final explorationResponse =
          await _client
              .from('exploration_sessions')
              .select()
              .eq('user_id', currentUser!.id)
              .count();

      // Get wallet information
      final wallets = await getUserWallets();

      // Calculate totals
      int totalGamesPlayed = 0;
      int totalScore = 0;
      for (var stat in gamingStatsResponse) {
        totalGamesPlayed += (stat['games_played'] as int? ?? 0);
        totalScore += (stat['total_score'] as int? ?? 0);
      }

      return {
        'total_games_played': totalGamesPlayed,
        'total_score': totalScore,
        'messages_sent': messageCountResponse.count ?? 0,
        'exploration_sessions': explorationResponse.count ?? 0,
        'member_since': currentUser!.createdAt,
        'wallet_count': wallets.length,
        'has_verified_wallet': wallets.any((w) => w['is_verified'] == true),
        'offline_access_enabled': await isOfflineAccessEnabled(),
      };
    } catch (e) {
      throw Exception('Failed to get user stats: ${e.toString()}');
    }
  }

  /// Check Supabase connection health and return status information
  Future<Map<String, dynamic>> checkConnectionHealth() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Test basic connection with a simple query
      await _client
          .from('user_profiles')
          .select('count')
          .count(CountOption.exact);

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      // Determine health status based on latency and successful connection
      String status;
      if (latency < 500) {
        status = 'healthy';
      } else if (latency < 1500) {
        status = 'degraded';
      } else {
        status = 'slow';
      }

      return {
        'status': status,
        'latency': latency,
        'timestamp': DateTime.now().toIso8601String(),
        'authenticated': isAuthenticated,
        'connection_quality': _getConnectionQuality(latency),
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'authenticated': isAuthenticated,
        'connection_quality': 'poor',
      };
    }
  }

  /// Get connection quality description based on latency
  String _getConnectionQuality(int latency) {
    if (latency < 100) return 'excellent';
    if (latency < 300) return 'good';
    if (latency < 700) return 'fair';
    if (latency < 1500) return 'poor';
    return 'very poor';
  }

  /// Check network connectivity and Supabase service availability
  Future<Map<String, dynamic>> getNetworkStatus() async {
    try {
      // Check Supabase connection health
      final healthCheck = await checkConnectionHealth();

      // Get additional network information if authenticated
      if (isAuthenticated) {
        final profile = await getUserProfile();
        final walletCount = await getUserWallets();

        return {
          ...healthCheck,
          'user_profile_loaded': profile != null,
          'wallet_count': walletCount.length,
          'features_available': {
            'messaging': true,
            'blockchain': walletCount.isNotEmpty,
            'offline_mode': await isOfflineAccessEnabled(),
          },
        };
      }

      return healthCheck;
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'authenticated': isAuthenticated,
      };
    }
  }
}

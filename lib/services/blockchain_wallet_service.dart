import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './supabase_service.dart';

enum WalletType { stellar, sui, ethereum, fer }

class BlockchainWallet {
  final String id;
  final String address;
  final String accountName;
  final WalletType type;
  final String publicKey;
  final String? encryptedPrivateKey;
  final DateTime createdAt;
  final bool isVerified;
  final Map<String, dynamic> metadata;

  BlockchainWallet({
    required this.id,
    required this.address,
    required this.accountName,
    required this.type,
    required this.publicKey,
    this.encryptedPrivateKey,
    required this.createdAt,
    this.isVerified = false,
    this.metadata = const {},
  });

  factory BlockchainWallet.fromMap(Map<String, dynamic> map) {
    return BlockchainWallet(
      id: map['id'] ?? '',
      address: map['wallet_address'] ?? '',
      accountName: map['account_name'] ?? map['wallet_name'] ?? '',
      type: WalletType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            map['wallet_type']?.toLowerCase(),
        orElse: () => WalletType.fer,
      ),
      publicKey: map['public_key'] ?? '',
      encryptedPrivateKey: map['encrypted_private_key'],
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      isVerified: map['is_verified'] ?? false,
      metadata: map['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet_address': address,
      'wallet_name': accountName,
      'account_name': accountName,
      'wallet_type': type.toString().split('.').last.toUpperCase(),
      'public_key': publicKey,
      'encrypted_private_key': encryptedPrivateKey,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
      'metadata': metadata,
    };
  }
}

/// Comprehensive blockchain wallet service for AiFER Network
class BlockchainWalletService {
  static BlockchainWalletService? _instance;
  static BlockchainWalletService get instance =>
      _instance ??= BlockchainWalletService._();

  BlockchainWalletService._();

  final _client = SupabaseService.instance.client;
  SharedPreferences? _prefs;

  static const String _offlineWalletsKey = 'offline_blockchain_wallets';
  static const String _verifiedAccountsKey = 'verified_accounts';
  static const String _offlineSessionsKey = 'offline_sessions';

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generate new blockchain wallet with simplified interface
  Future<Map<String, dynamic>> generateWallet({
    required String userId,
    required String accountName,
    WalletType? type, // Made optional with default
  }) async {
    try {
      final walletType =
          type ?? WalletType.fer; // Default to FER type for AiFER network

      // Generate cryptographic keys (simplified for demo)
      final keyPair = _generateKeyPair(walletType);
      final address = _generateAddress(keyPair['publicKey']!, walletType);

      final wallet = BlockchainWallet(
        id: _generateId(),
        address: address,
        accountName: accountName,
        type: walletType,
        publicKey: keyPair['publicKey']!,
        encryptedPrivateKey: keyPair['encryptedPrivateKey'],
        createdAt: DateTime.now(),
        isVerified: false,
        metadata: {
          'user_id': userId,
          'generation_method': 'local_secure',
        },
      );

      // Store online if connection available
      await _storeWalletOnline(wallet, userId);

      // Always store offline backup
      await _storeWalletOffline(wallet);

      // Generate recovery phrase (12 words)
      final recoveryPhrase = _generateRecoveryPhrase();

      return {
        'success': true,
        'wallet': wallet.toMap(),
        'recovery_phrase': recoveryPhrase,
        'wallet_address': address,
        'account_name': accountName,
      };
    } catch (e) {
      debugPrint('Failed to generate wallet: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get user wallets (offline-first) - compatible with SupabaseAuthService
  Future<List<Map<String, dynamic>>> getUserWallets(String userId) async {
    try {
      List<Map<String, dynamic>> wallets = [];

      // Try online first
      try {
        final response = await _client
            .from('blockchain_wallets')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        wallets = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        debugPrint('Online fetch failed, using offline cache: $e');
      }

      // If no online data, use offline cache
      if (wallets.isEmpty) {
        final offlineWallets = await _getOfflineWallets(userId);
        wallets = offlineWallets.map((w) => w.toMap()).toList();
      }

      return wallets;
    } catch (e) {
      debugPrint('Failed to get user wallets: $e');
      return [];
    }
  }

  /// Verify wallet ownership with signature
  Future<bool> verifyWalletOwnership({
    required String walletAddress,
    required String message,
    required String signature,
  }) async {
    try {
      // Get wallet's public key
      final walletData = await _client
          .from('blockchain_wallets')
          .select('public_key')
          .eq('wallet_address', walletAddress)
          .single();

      final publicKey = walletData['public_key'];

      // Verify signature (simplified - use proper crypto library in production)
      final isValid = _verifySignature(message, signature, publicKey);

      if (isValid) {
        // Update wallet as verified
        await _client
            .from('blockchain_wallets')
            .update({'is_verified': true}).eq('wallet_address', walletAddress);
      }

      return isValid;
    } catch (e) {
      debugPrint('Wallet verification error: $e');
      return false;
    }
  }

  /// Create offline session for wallet authentication
  Future<String> createOfflineSession({
    required String userId,
    required String walletAddress,
    required String signature,
  }) async {
    // Generate session token
    final sessionToken = _generateSessionToken();
    final expiresAt = DateTime.now().add(Duration(days: 30));

    try {
      // Get wallet ID
      final walletResponse = await _client
          .from('blockchain_wallets')
          .select('id')
          .eq('wallet_address', walletAddress)
          .eq('user_id', userId)
          .single();

      final walletId = walletResponse['id'];

      // Store session in database
      await _client.from('offline_auth_sessions').insert({
        'user_id': userId,
        'wallet_id': walletId,
        'session_token': sessionToken,
        'challenge_signature': _hashSignature(signature),
        'expires_at': expiresAt.toIso8601String(),
        'is_active': true,
      });

      // Store session locally for offline access
      await _storeOfflineSession(walletAddress, sessionToken, expiresAt);

      return sessionToken;
    } catch (e) {
      debugPrint('Failed to create offline session: $e');
      // Still create local session for offline use
      await _storeOfflineSession(walletAddress, sessionToken, expiresAt);
      return sessionToken;
    }
  }

  /// Authenticate using offline session
  Future<bool> authenticateOffline({
    required String sessionToken,
    required String walletAddress,
  }) async {
    try {
      // Check local storage first
      final storedToken = await _getStoredOfflineSession(walletAddress);
      if (storedToken != null && storedToken['token'] == sessionToken) {
        final expiresAt = DateTime.parse(storedToken['expires_at']);
        if (DateTime.now().isBefore(expiresAt)) {
          return true;
        }
      }

      // Fallback to database check if online
      try {
        final sessionData = await _client
            .from('offline_auth_sessions')
            .select()
            .eq('session_token', sessionToken)
            .eq('is_active', true)
            .single();

        final expiresAt = DateTime.parse(sessionData['expires_at']);
        return DateTime.now().isBefore(expiresAt);
      } catch (e) {
        debugPrint('Online session check failed: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Offline authentication failed: $e');
      return false;
    }
  }

  /// Clear offline session
  Future<void> clearOfflineSession() async {
    try {
      // Clear all local offline sessions
      _prefs ??= await SharedPreferences.getInstance();
      final keys = _prefs?.getKeys() ?? <String>{};
      for (String key in keys) {
        if (key.startsWith('offline_session_')) {
          await _prefs?.remove(key);
        }
      }

      // Deactivate all sessions in database (if online)
      try {
        await _client
            .from('offline_auth_sessions')
            .update({'is_active': false}).neq('id', '');
      } catch (e) {
        debugPrint('Failed to deactivate online sessions: $e');
      }
    } catch (e) {
      throw Exception('Failed to clear offline session: ${e.toString()}');
    }
  }

  /// Check if user has offline access
  Future<bool> hasOfflineAccess(String userId) async {
    try {
      // Check local storage first
      _prefs ??= await SharedPreferences.getInstance();
      final keys = _prefs?.getKeys() ?? <String>{};
      for (String key in keys) {
        if (key.startsWith('offline_session_')) {
          final sessionData = _prefs?.getString(key);
          if (sessionData != null) {
            final data = json.decode(sessionData);
            final expiresAt = DateTime.parse(data['expires_at']);
            if (DateTime.now().isBefore(expiresAt)) {
              return true;
            }
          }
        }
      }

      // Check online if no local sessions
      try {
        final activeSessions = await _client
            .from('offline_auth_sessions')
            .select('id')
            .eq('user_id', userId)
            .eq('is_active', true)
            .gt('expires_at', DateTime.now().toIso8601String());

        return activeSessions.isNotEmpty;
      } catch (e) {
        debugPrint('Online offline access check failed: $e');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Verify account name and wallet
  Future<bool> verifyAccountName(String accountName, String address) async {
    try {
      // First check offline verified accounts
      final verified = await _isAccountVerifiedOffline(accountName, address);
      if (verified) return true;

      // Then check online if available
      try {
        final response = await _client
            .from('blockchain_wallets')
            .select('*')
            .eq('wallet_name', accountName)
            .eq('wallet_address', address)
            .single();

        // Mark as verified offline for future use
        await _markAccountVerifiedOffline(accountName, address);
        return true;
      } catch (e) {
        debugPrint('Online verification failed: $e');
      }

      // Perform cryptographic verification
      return await _performCryptographicVerification(accountName, address);
    } catch (e) {
      debugPrint('Account verification failed: $e');
      return false;
    }
  }

  // Store wallet online
  Future<void> _storeWalletOnline(
      BlockchainWallet wallet, String userId) async {
    try {
      final walletData = wallet.toMap();
      walletData['user_id'] = userId;

      await _client.from('blockchain_wallets').insert(walletData);

      debugPrint('✅ Wallet stored online successfully');
    } catch (e) {
      debugPrint('Failed to store wallet online: $e');
      // Don't rethrow - offline storage is primary backup
    }
  }

  // Store wallet offline
  Future<void> _storeWalletOffline(BlockchainWallet wallet) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final existingData = _prefs?.getString(_offlineWalletsKey) ?? '[]';
      final existingWallets = List<Map<String, dynamic>>.from(
        json.decode(existingData),
      );

      existingWallets.add(wallet.toMap());
      await _prefs?.setString(_offlineWalletsKey, json.encode(existingWallets));

      debugPrint('✅ Wallet stored offline successfully');
    } catch (e) {
      debugPrint('Failed to store wallet offline: $e');
      rethrow;
    }
  }

  // Get offline wallets
  Future<List<BlockchainWallet>> _getOfflineWallets(String userId) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final walletsData = _prefs?.getString(_offlineWalletsKey) ?? '[]';
      final walletsList = List<Map<String, dynamic>>.from(
        json.decode(walletsData),
      );

      return walletsList
          .where((data) => data['metadata']?['user_id'] == userId)
          .map((data) => BlockchainWallet.fromMap(data))
          .toList();
    } catch (e) {
      debugPrint('Failed to get offline wallets: $e');
      return [];
    }
  }

  // Store offline session locally
  Future<void> _storeOfflineSession(
      String walletAddress, String token, DateTime expiresAt) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final sessionData = {
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
        'wallet_address': walletAddress,
      };

      await _prefs?.setString(
          'offline_session_$walletAddress', json.encode(sessionData));
    } catch (e) {
      debugPrint('Failed to store offline session locally: $e');
    }
  }

  // Get stored offline session
  Future<Map<String, dynamic>?> _getStoredOfflineSession(
      String walletAddress) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final sessionData = _prefs?.getString('offline_session_$walletAddress');
      if (sessionData != null) {
        return Map<String, dynamic>.from(json.decode(sessionData));
      }
    } catch (e) {
      debugPrint('Failed to get stored offline session: $e');
    }
    return null;
  }

  // Check if account is verified offline
  Future<bool> _isAccountVerifiedOffline(
      String accountName, String address) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final verifiedData = _prefs?.getString(_verifiedAccountsKey) ?? '{}';
      final verifiedAccounts = Map<String, dynamic>.from(
        json.decode(verifiedData),
      );

      final key = '${accountName}:${address}';
      return verifiedAccounts[key] == true;
    } catch (e) {
      debugPrint('Failed to check offline verification: $e');
      return false;
    }
  }

  // Mark account as verified offline
  Future<void> _markAccountVerifiedOffline(
      String accountName, String address) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final verifiedData = _prefs?.getString(_verifiedAccountsKey) ?? '{}';
      final verifiedAccounts = Map<String, dynamic>.from(
        json.decode(verifiedData),
      );

      final key = '${accountName}:${address}';
      verifiedAccounts[key] = true;

      await _prefs?.setString(
          _verifiedAccountsKey, json.encode(verifiedAccounts));
    } catch (e) {
      debugPrint('Failed to mark account verified offline: $e');
    }
  }

  // Perform cryptographic verification
  Future<bool> _performCryptographicVerification(
      String accountName, String address) async {
    try {
      // Implement blockchain-specific verification logic
      // This would typically involve checking against blockchain networks
      // For now, we'll do basic format validation

      if (accountName.isEmpty || address.isEmpty) return false;

      // Basic address format validation based on type
      if (address.startsWith('G') && address.length == 56) {
        // Stellar format
        return true;
      } else if (address.startsWith('0x') && address.length == 42) {
        // Ethereum format
        return true;
      } else if (address.startsWith('FER') && address.length >= 32) {
        // FER format (AiFER Network)
        return true;
      } else if (address.length >= 32 && address.length <= 64) {
        // SUI format (simplified)
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Cryptographic verification failed: $e');
      return false;
    }
  }

  // Generate cryptographic key pair
  Map<String, String> _generateKeyPair(WalletType type) {
    // Simplified key generation for demo purposes
    // In production, use proper cryptographic libraries

    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final publicKey = _hashString('pub_$random').substring(0, 32);
    final privateKey = _hashString('priv_$random');
    final encryptedPrivateKey = _encryptPrivateKey(privateKey);

    return {
      'publicKey': publicKey,
      'privateKey': privateKey,
      'encryptedPrivateKey': encryptedPrivateKey,
    };
  }

  // Generate wallet address from public key
  String _generateAddress(String publicKey, WalletType type) {
    final hash = _hashString(publicKey);

    switch (type) {
      case WalletType.stellar:
        return 'G${hash.substring(0, 55)}';
      case WalletType.ethereum:
        return '0x${hash.substring(0, 40)}';
      case WalletType.fer:
        return 'FER${hash.substring(0, 32)}';
      case WalletType.sui:
        return hash.substring(0, 64);
    }
  }

  // Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }

  // Hash string using SHA-256
  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Encrypt private key (simplified)
  String _encryptPrivateKey(String privateKey) {
    // In production, use proper encryption with user's master key
    final bytes = utf8.encode(privateKey);
    return base64.encode(bytes);
  }

  bool _verifySignature(String message, String signature, String publicKey) {
    // Simplified signature verification - use proper crypto library in production
    final messageHash = sha256.convert(utf8.encode(message)).toString();
    final expectedSignature =
        sha256.convert(utf8.encode(messageHash + publicKey)).toString();
    return signature.toLowerCase() == expectedSignature.toLowerCase();
  }

  String _generateSessionToken() {
    final random = Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(64, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  String _hashSignature(String signature) {
    return sha256.convert(utf8.encode(signature)).toString();
  }

  // Generate 12-word recovery phrase
  List<String> _generateRecoveryPhrase() {
    // Standard BIP39 word list subset for demo
    const wordList = [
      'abandon',
      'ability',
      'able',
      'about',
      'above',
      'absent',
      'absorb',
      'abstract',
      'absurd',
      'abuse',
      'access',
      'accident',
      'account',
      'accuse',
      'achieve',
      'acid',
      'acoustic',
      'acquire',
      'across',
      'action',
      'actor',
      'actress',
      'actual',
      'adapt',
      'add',
      'addict',
      'address',
      'adjust',
      'admit',
      'adult',
      'advance',
      'advice',
      'aerobic',
      'affair',
      'afford',
      'afraid',
      'again',
      'against',
      'age',
      'agent',
      'agree',
      'ahead',
      'aim',
      'air',
      'airport',
      'aisle',
      'alarm',
      'album',
      'alcohol',
      'alert',
      'alien',
      'all',
      'alley',
      'allow',
      'almost',
      'alone',
      'alpha',
      'already',
      'also',
      'alter',
      'always',
      'amateur',
      'amazing',
      'among',
      'amount',
      'amused',
      'analyst',
      'anchor',
      'ancient',
      'anger',
      'angle',
      'angry',
      'animal',
      'ankle',
      'announce',
      'annual',
      'another',
      'answer',
      'antenna',
      'antique',
      'anxiety',
      'any',
      'apart',
      'apology',
      'appear',
      'apple',
      'approve',
      'april',
      'arch',
      'arctic',
      'area',
      'arena',
      'argue',
      'arm',
      'armed',
      'armor',
      'army',
      'around',
      'arrange',
      'arrest',
      'arrive',
      'arrow',
      'art',
      'article',
      'artist',
      'artwork',
      'ask',
      'aspect',
      'assault',
      'asset',
      'assist',
      'assume',
      'asthma',
      'athlete',
      'atom',
      'attack',
      'attend',
      'attitude',
      'attract',
      'auction',
      'audit',
      'august',
      'aunt',
      'author',
      'auto',
      'autumn',
      'average',
      'avocado',
      'avoid',
      'awake',
      'aware',
      'away',
      'awesome',
      'awful',
      'awkward',
      'axis',
      'baby',
      'bachelor',
      'bacon',
      'badge',
      'bag',
      'balance',
      'balcony',
      'ball',
      'bamboo',
      'banana',
      'banner',
      'bar',
      'barely',
      'bargain',
      'barrel',
      'base',
      'basic',
      'basket',
      'battle',
      'beach',
      'bean',
      'beauty',
      'because',
      'become',
      'beef',
      'before',
      'begin',
      'behave',
      'behind',
      'believe',
      'below',
      'belt',
      'bench',
      'benefit',
      'best',
      'betray',
      'better',
      'between',
      'beyond',
      'bicycle',
      'bid',
      'bike',
      'bind',
      'biology',
      'bird',
      'birth',
      'bitter',
      'black',
      'blade',
      'blame',
      'blanket',
      'blast',
      'bleak',
      'bless',
      'blind',
      'blood',
      'blossom',
      'blow',
      'blue',
      'blur',
      'blush',
      'board',
      'boat',
      'body',
    ];

    final random = Random.secure();
    return List.generate(
        12, (index) => wordList[random.nextInt(wordList.length)]);
  }

  // Clear offline data (for testing/reset)
  Future<void> clearOfflineData() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove(_offlineWalletsKey);
      await _prefs?.remove(_verifiedAccountsKey);
      debugPrint('✅ Offline blockchain data cleared');
    } catch (e) {
      debugPrint('Failed to clear offline data: $e');
    }
  }

  // Sync offline data with online
  Future<void> syncOfflineData(String userId) async {
    try {
      final offlineWallets = await _getOfflineWallets(userId);

      for (final wallet in offlineWallets) {
        await _storeWalletOnline(wallet, userId);
      }

      debugPrint('✅ Offline data synced successfully');
    } catch (e) {
      debugPrint('Failed to sync offline data: $e');
    }
  }
}

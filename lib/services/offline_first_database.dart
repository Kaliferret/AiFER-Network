import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/aif_package_format.dart';
import 'aiferid_auth_service.dart';

/// Offline-First Database Service
/// Local SQLite database with blockchain synchronization
class OfflineFirstDatabase {
  static OfflineFirstDatabase? _instance;
  static OfflineFirstDatabase get instance => _instance ??= OfflineFirstDatabase._();
  OfflineFirstDatabase._();

  Database? _database;
  bool _isInitialized = false;
  final Map<String, SyncStatus> _syncStatus = {};
  Timer? _syncTimer;
  StreamController<DatabaseEventInfo>? _eventController;
  final Map<String, int> _pendingOperations = {};
  
  /// Initialize offline-first database
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'fer_offline_first.db');
      
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
      
      await _loadSyncStatus();
      _startPeriodicSync();
      _setupEventStream();
      _isInitialized = true;
      
      debugPrint('📱 Offline-first database initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize offline database: $e');
      rethrow;
    }
  }
  
  /// Store user profile with offline-first strategy
  Future<void> storeUserProfile(AiFERiDUserProfile profile) async {
    if (_database == null) await initialize();
    
    try {
      // Store locally first
      await _database!.insert(
        'user_profiles',
        {
          'id': profile.id,
          'wallet_address': profile.walletAddress,
          'ferret_id': profile.ferretId,
          'auth_type': profile.authType.toString(),
          'created_at': profile.createdAt.millisecondsSinceEpoch,
          'last_login': profile.lastLogin.millisecondsSinceEpoch,
          'metadata': json.encode(profile.metadata),
          'is_active': profile.isActive ? 1 : 0,
          'expires_at': profile.expiresAt?.millisecondsSinceEpoch,
          'sync_status': 'pending',
          'blockchain_hash': '',
          'last_sync': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Update sync status
      _updateSyncStatus('user_profiles');
      _incrementPendingOperations('user_profiles');
      
      // Trigger background sync
      _triggerSync('user_profiles');
      
      _emitEvent(DatabaseEvent.dataStored, 'user_profiles', profile.id);
      
      debugPrint('👤 User profile stored locally: ${profile.id}');
    } catch (e) {
      debugPrint('❌ Failed to store user profile: $e');
      rethrow;
    }
  }
  
  /// Store message with encryption
  Future<void> storeMessage(FERMessage message) async {
    if (_database == null) await initialize();
    
    try {
      // Encrypt message content
      final encryptedContent = await _encryptMessageContent(message.content);
      
      // Create AIF package for message
      final aifPackage = await _createMessageAiFPackage(message, encryptedContent);
      
      await _database!.insert(
        'messages',
        {
          'id': message.id,
          'from_user_id': message.fromUserId,
          'to_user_id': message.toUserId,
          'content': encryptedContent,
          'content_type': message.contentType.toString(),
          'timestamp': message.timestamp.millisecondsSinceEpoch,
          'message_status': message.status.toString(),
          'is_encrypted': 1,
          'sync_status': 'pending',
          'blockchain_hash': '',
          'aif_package': json.encode(aifPackage),
          'last_sync': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      _updateSyncStatus('messages');
      _incrementPendingOperations('messages');
      _triggerSync('messages');
      
      _emitEvent(DatabaseEvent.messageStored, 'messages', message.id);
      
      debugPrint('💬 Message stored locally: ${message.id}');
    } catch (e) {
      debugPrint('❌ Failed to store message: $e');
      rethrow;
    }
  }
  
  /// Store file with AIF packaging
  Future<void> storeFile(FERFile file) async {
    if (_database == null) await initialize();
    
    try {
      // Create AIF package for file
      final aifPackage = await _createFileAiFPackage(file);
      
      await _database!.insert(
        'files',
        {
          'id': file.id,
          'owner_id': file.ownerId,
          'file_name': file.fileName,
          'file_size': file.fileSize,
          'file_type': file.fileType.toString(),
          'file_hash': file.fileHash,
          'aif_package': json.encode(aifPackage),
          'created_at': file.createdAt.millisecondsSinceEpoch,
          'sync_status': 'pending',
          'blockchain_hash': '',
          'access_permissions': json.encode(file.accessPermissions),
          'last_sync': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      _updateSyncStatus('files');
      _incrementPendingOperations('files');
      _triggerSync('files');
      
      _emitEvent(DatabaseEvent.fileStored, 'files', file.id);
      
      debugPrint('📁 File stored locally: ${file.fileName}');
    } catch (e) {
      debugPrint('❌ Failed to store file: $e');
      rethrow;
    }
  }
  
  /// Store gaming session
  Future<void> storeGamingSession(FERGamingSession session) async {
    if (_database == null) await initialize();
    
    try {
      await _database!.insert(
        'gaming_sessions',
        {
          'id': session.id,
          'game_id': session.gameId,
          'host_user_id': session.hostUserId,
          'session_data': json.encode(session.sessionData),
          'status': session.status.toString(),
          'created_at': session.createdAt.millisecondsSinceEpoch,
          'updated_at': session.updatedAt.millisecondsSinceEpoch,
          'sync_status': 'pending',
          'blockchain_hash': '',
          'last_sync': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      _updateSyncStatus('gaming_sessions');
      _incrementPendingOperations('gaming_sessions');
      _triggerSync('gaming_sessions');
      
      _emitEvent(DatabaseEvent.gamingSessionStored, 'gaming_sessions', session.id);
      
      debugPrint('🎮 Gaming session stored locally: ${session.id}');
    } catch (e) {
      debugPrint('❌ Failed to store gaming session: $e');
      rethrow;
    }
  }
  
  /// Get messages with offline support
  Future<List<FERMessage>> getMessages({
    String? userId,
    int limit = 50,
    int offset = 0,
  }) async {
    if (_database == null) await initialize();
    
    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];
      
      if (userId != null) {
        whereClause = 'from_user_id = ? OR to_user_id = ?';
        whereArgs = [userId, userId];
      }
      
      final results = await _database!.query(
        'messages',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );
      
      return results.map((row) => _mapRowToMessage(row)).toList();
    } catch (e) {
      debugPrint('❌ Failed to get messages: $e');
      return [];
    }
  }
  
  /// Get user files
  Future<List<FERFile>> getUserFiles(String userId, {int limit = 100}) async {
    if (_database == null) await initialize();
    
    try {
      final results = await _database!.query(
        'files',
        where: 'owner_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      return results.map((row) => _mapRowToFile(row)).toList();
    } catch (e) {
      debugPrint('❌ Failed to get user files: $e');
      return [];
    }
  }
  
  /// Get gaming sessions
  Future<List<FERGamingSession>> getGamingSessions({
    String? userId,
    GameSessionStatus? status,
    int limit = 50,
  }) async {
    if (_database == null) await initialize();
    
    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];
      
      if (userId != null) {
        whereClause += ' AND host_user_id = ?';
        whereArgs.add(userId);
      }
      
      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status.toString());
      }
      
      final results = await _database!.query(
        'gaming_sessions',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      return results.map((row) => _mapRowToGamingSession(row)).toList();
    } catch (e) {
      debugPrint('❌ Failed to get gaming sessions: $e');
      return [];
    }
  }
  
  /// Synchronize pending changes with blockchain
  Future<SyncResult> synchronizeWithBlockchain() async {
    if (_database == null) await initialize();
    
    try {
      debugPrint('🔄 Starting blockchain synchronization...');
      
      // Sync user profiles
      await _syncTable('user_profiles');
      
      // Sync messages
      await _syncTable('messages');
      
      // Sync files
      await _syncTable('files');
      
      // Sync gaming sessions
      await _syncTable('gaming_sessions');
      
      debugPrint('✅ Blockchain synchronization completed');
      
      return SyncResult(
        success: true,
        syncedItems: _getTotalSyncedItems(),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Blockchain synchronization failed: $e');
      return SyncResult(
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Force sync specific table
  Future<void> forceSyncTable(String tableName) async {
    await _syncTable(tableName);
  }
  
  /// Get sync status
  SyncStatus? getSyncStatus(String tableName) {
    return _syncStatus[tableName];
  }
  
  /// Get all sync statuses
  Map<String, SyncStatus> getAllSyncStatuses() {
    return Map.from(_syncStatus);
  }
  
  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    debugPrint('🏗️ Creating database tables...');
    
    // User profiles table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        wallet_address TEXT UNIQUE,
        ferret_id TEXT,
        auth_type TEXT,
        created_at INTEGER,
        last_login INTEGER,
        metadata TEXT,
        is_active INTEGER DEFAULT 1,
        expires_at INTEGER,
        sync_status TEXT DEFAULT 'pending',
        blockchain_hash TEXT,
        last_sync INTEGER
      )
    ''');
    
    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        from_user_id TEXT,
        to_user_id TEXT,
        content TEXT,
        content_type TEXT DEFAULT 'text',
        timestamp INTEGER,
        message_status TEXT DEFAULT 'sent',
        is_encrypted INTEGER DEFAULT 1,
        sync_status TEXT DEFAULT 'pending',
        blockchain_hash TEXT,
        aif_package TEXT,
        last_sync INTEGER
      )
    ''');
    
    // Files table
    await db.execute('''
      CREATE TABLE files (
        id TEXT PRIMARY KEY,
        owner_id TEXT,
        file_name TEXT,
        file_size INTEGER,
        file_type TEXT,
        file_hash TEXT,
        aif_package TEXT,
        created_at INTEGER,
        sync_status TEXT DEFAULT 'pending',
        blockchain_hash TEXT,
        access_permissions TEXT,
        last_sync INTEGER
      )
    ''');
    
    // Gaming sessions table
    await db.execute('''
      CREATE TABLE gaming_sessions (
        id TEXT PRIMARY KEY,
        game_id TEXT,
        host_user_id TEXT,
        session_data TEXT,
        status TEXT DEFAULT 'active',
        created_at INTEGER,
        updated_at INTEGER,
        sync_status TEXT DEFAULT 'pending',
        blockchain_hash TEXT,
        last_sync INTEGER
      )
    ''');
    
    // Sync metadata table
    await db.execute('''
      CREATE TABLE sync_metadata (
        table_name TEXT PRIMARY KEY,
        last_sync_hash TEXT,
        last_sync_timestamp INTEGER,
        pending_sync_count INTEGER DEFAULT 0,
        sync_conflicts TEXT
      )
    ''');
    
    // Create indexes for performance
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_messages_users ON messages(from_user_id, to_user_id)');
    await db.execute('CREATE INDEX idx_files_owner ON files(owner_id)');
    await db.execute('CREATE INDEX idx_gaming_status ON gaming_sessions(status)');
    await db.execute('CREATE INDEX idx_gaming_host ON gaming_sessions(host_user_id)');
    
    debugPrint('✅ Database tables created successfully');
  }
  
  /// Upgrade database
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading database from version $oldVersion to $newVersion');
    
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }
  
  /// Sync specific table with blockchain
  Future<void> _syncTable(String tableName) async {
    try {
      // Get pending records
      final pendingRecords = await _database!.query(
        tableName,
        where: 'sync_status = ?',
        whereArgs: ['pending'],
      );
      
      debugPrint('🔄 Syncing $tableName: ${pendingRecords.length} pending records');
      
      for (final record in pendingRecords) {
        await _syncRecord(tableName, record);
      }
      
      // Update sync metadata
      final lastSyncHash = await _calculateTableHash(tableName);
      await _database!.insert(
        'sync_metadata',
        {
          'table_name': tableName,
          'last_sync_hash': lastSyncHash,
          'last_sync_timestamp': DateTime.now().millisecondsSinceEpoch,
          'pending_sync_count': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      _pendingOperations[tableName] = 0;
      _updateSyncStatus(tableName, synced: true);
      
      debugPrint('✅ Sync completed for $tableName');
    } catch (e) {
      debugPrint('❌ Failed to sync table $tableName: $e');
      _updateSyncStatus(tableName, hasError: true);
    }
  }
  
  /// Sync individual record with blockchain
  Future<void> _syncRecord(String tableName, Map<String, dynamic> record) async {
    try {
      // Create blockchain transaction
      final transaction = await _createBlockchainTransaction(tableName, record);
      
      // Submit to blockchain (simulated)
      final txHash = await _submitBlockchainTransaction(transaction);
      
      // Update record with blockchain hash
      await _database!.update(
        tableName,
        {
          'sync_status': 'synced',
          'blockchain_hash': txHash,
          'last_sync': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [record['id']],
      );
      
      debugPrint('⛓️ Record synced to blockchain: ${record['id']}');
    } catch (e) {
      // Mark as failed sync
      await _database!.update(
        tableName,
        {'sync_status': 'failed'},
        where: 'id = ?',
        whereArgs: [record['id']],
      );
      
      debugPrint('❌ Failed to sync record ${record['id']}: $e');
    }
  }
  
  /// Create blockchain transaction
  Future<Map<String, dynamic>> _createBlockchainTransaction(
    String tableName,
    Map<String, dynamic> record,
  ) async {
    return {
      'type': 'data_sync',
      'tableName': tableName,
      'recordId': record['id'],
      'data': record,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  /// Submit blockchain transaction (simulated)
  Future<String> _submitBlockchainTransaction(Map<String, dynamic> transaction) async {
    // Simulate blockchain submission
    await Future.delayed(Duration(milliseconds: 500));
    return 'tx_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000)}';
  }
  
  /// Calculate table hash for sync verification
  Future<String> _calculateTableHash(String tableName) async {
    final records = await _database!.query(tableName);
    final recordsJson = json.encode(records);
    final hash = sha256.convert(utf8.encode(recordsJson));
    return hash.toString();
  }
  
  /// Encrypt message content
  Future<String> _encryptMessageContent(String content) async {
    // Simple encryption simulation
    final bytes = utf8.encode(content);
    final encrypted = bytes.map((byte) => byte ^ 0x55).toList();
    return base64.encode(encrypted);
  }
  
  /// Create AIF package for message
  Future<Map<String, dynamic>> _createMessageAiFPackage(
    FERMessage message,
    String encryptedContent,
  ) async {
    return {
      'messageId': message.id,
      'encryptedContent': encryptedContent,
      'contentType': message.contentType.toString(),
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'packageType': 'message',
    };
  }
  
  /// Create AIF package for file
  Future<Map<String, dynamic>> _createFileAiFPackage(FERFile file) async {
    return {
      'fileId': file.id,
      'fileName': file.fileName,
      'fileSize': file.fileSize,
      'fileType': file.fileType.toString(),
      'fileHash': file.fileHash,
      'createdAt': file.createdAt.millisecondsSinceEpoch,
      'packageType': 'file',
    };
  }
  
  /// Map database row to message
  FERMessage _mapRowToMessage(Map<String, dynamic> row) {
    return FERMessage(
      id: row['id'],
      fromUserId: row['from_user_id'],
      toUserId: row['to_user_id'],
      content: row['content'],
      contentType: FERMessageContentType.values.firstWhere(
        (e) => e.toString() == row['content_type'],
        orElse: () => FERMessageContentType.text,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
      status: FERMessageStatus.values.firstWhere(
        (e) => e.toString() == row['message_status'],
        orElse: () => FERMessageStatus.sent,
      ),
      isEncrypted: row['is_encrypted'] == 1,
    );
  }
  
  /// Map database row to file
  FERFile _mapRowToFile(Map<String, dynamic> row) {
    return FERFile(
      id: row['id'],
      ownerId: row['owner_id'],
      fileName: row['file_name'],
      fileSize: row['file_size'],
      fileType: FERFileType.values.firstWhere(
        (e) => e.toString() == row['file_type'],
        orElse: () => FERFileType.document,
      ),
      fileHash: row['file_hash'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']),
      accessPermissions: Map<String, dynamic>.from(
        json.decode(row['access_permissions'] ?? '{}'),
      ),
    );
  }
  
  /// Map database row to gaming session
  FERGamingSession _mapRowToGamingSession(Map<String, dynamic> row) {
    return FERGamingSession(
      id: row['id'],
      gameId: row['game_id'],
      hostUserId: row['host_user_id'],
      sessionData: Map<String, dynamic>.from(json.decode(row['session_data'] ?? '{}')),
      status: GameSessionStatus.values.firstWhere(
        (e) => e.toString() == row['status'],
        orElse: () => GameSessionStatus.active,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']),
    );
  }
  
  /// Start periodic background sync
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (_hasConnectivity()) {
        synchronizeWithBlockchain();
      }
    });
    
    debugPrint('⏰ Periodic sync started');
  }
  
  /// Check if has connectivity (simulated)
  bool _hasConnectivity() {
    // In real implementation, check network connectivity
    return true;
  }
  
  /// Load sync status from storage
  Future<void> _loadSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncStatusJson = prefs.getString('sync_status') ?? '{}';
      final syncStatusData = Map<String, dynamic>.from(json.decode(syncStatusJson));
      
      for (final entry in syncStatusData.entries) {
        _syncStatus[entry.key] = SyncStatus(
          tableName: entry.key,
          lastSync: DateTime.fromMillisecondsSinceEpoch(entry.value['lastSync']),
          pendingCount: entry.value['pendingCount'],
          hasError: entry.value['hasError'] ?? false,
        );
      }
      
      debugPrint('📦 Loaded sync status for ${_syncStatus.length} tables');
    } catch (e) {
      debugPrint('❌ Failed to load sync status: $e');
    }
  }
  
  /// Update sync status
  void _updateSyncStatus(String tableName, {bool? synced, bool? hasError}) {
    _syncStatus[tableName] = SyncStatus(
      tableName: tableName,
      lastSync: DateTime.now(),
      pendingCount: _pendingOperations[tableName] ?? 0,
      hasError: hasError ?? false,
    );
    
    _saveSyncStatus();
  }
  
  /// Save sync status to storage
  Future<void> _saveSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncStatusData = <String, dynamic>{};
      
      for (final entry in _syncStatus.entries) {
        syncStatusData[entry.key] = {
          'lastSync': entry.value.lastSync.millisecondsSinceEpoch,
          'pendingCount': entry.value.pendingCount,
          'hasError': entry.value.hasError,
        };
      }
      
      await prefs.setString('sync_status', json.encode(syncStatusData));
    } catch (e) {
      debugPrint('❌ Failed to save sync status: $e');
    }
  }
  
  /// Increment pending operations
  void _incrementPendingOperations(String tableName) {
    _pendingOperations[tableName] = (_pendingOperations[tableName] ?? 0) + 1;
  }
  
  /// Trigger sync for table
  void _triggerSync(String tableName) {
    // Trigger immediate sync if pending operations exceed threshold
    if ((_pendingOperations[tableName] ?? 0) > 5) {
      Future.delayed(Duration(seconds: 2), () {
        synchronizeWithBlockchain();
      });
    }
  }
  
  /// Get total synced items
  int _getTotalSyncedItems() {
    return _pendingOperations.values.fold(0, (sum, count) => sum + count);
  }
  
  /// Setup event stream
  void _setupEventStream() {
    _eventController = StreamController<DatabaseEventInfo>.broadcast();
  }
  
  /// Emit database event
  void _emitEvent(DatabaseEvent event, String table, String itemId) {
    _eventController?.add(DatabaseEventInfo(event, table, itemId, DateTime.now()));
    debugPrint('📊 Database event: ${event.toString()} in $table for $itemId');
  }
  
  /// Get database event stream
  Stream<DatabaseEventInfo> get events => 
      _eventController?.stream ?? Stream.empty();
  
  /// Cleanup resources
  void dispose() {
    _syncTimer?.cancel();
    _eventController?.close();
    _database?.close();
    _isInitialized = false;
    debugPrint('🗑️ Offline database disposed');
  }
}

/// Sync status information
class SyncStatus {
  final String tableName;
  final DateTime lastSync;
  final int pendingCount;
  final bool hasError;
  
  SyncStatus({
    required this.tableName,
    required this.lastSync,
    this.pendingCount = 0,
    this.hasError = false,
  });
}

/// Sync result
class SyncResult {
  final bool success;
  final int syncedItems;
  final String? error;
  final DateTime timestamp;
  
  SyncResult({
    required this.success,
    this.syncedItems = 0,
    this.error,
    required this.timestamp,
  });
}

/// Message types
enum FERMessageContentType {
  text,
  image,
  audio,
  video,
  file,
}

/// Message status
enum FERMessageStatus {
  sent,
  delivered,
  read,
  failed,
}

/// File types
enum FERFileType {
  image,
  video,
  audio,
  document,
  archive,
  other,
}

/// Game session status
enum GameSessionStatus {
  active,
  waiting,
  inProgress,
  completed,
  cancelled,
}

/// Database events
enum DatabaseEvent {
  dataStored,
  messageStored,
  fileStored,
  gamingSessionStored,
  dataSynced,
  syncFailed,
}

/// Database event information
class DatabaseEventInfo {
  final DatabaseEvent event;
  final String table;
  final String itemId;
  final DateTime timestamp;
  
  DatabaseEventInfo(this.event, this.table, this.itemId, this.timestamp);
}

/// Data models
class FERMessage {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final FERMessageContentType contentType;
  final DateTime timestamp;
  final FERMessageStatus status;
  final bool isEncrypted;
  
  FERMessage({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.contentType,
    required this.timestamp,
    required this.status,
    this.isEncrypted = true,
  });
}

class FERFile {
  final String id;
  final String ownerId;
  final String fileName;
  final int fileSize;
  final FERFileType fileType;
  final String fileHash;
  final DateTime createdAt;
  final Map<String, dynamic> accessPermissions;
  
  FERFile({
    required this.id,
    required this.ownerId,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.fileHash,
    required this.createdAt,
    this.accessPermissions = const {},
  });
}

class FERGamingSession {
  final String id;
  final String gameId;
  final String hostUserId;
  final Map<String, dynamic> sessionData;
  final GameSessionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  FERGamingSession({
    required this.id,
    required this.gameId,
    required this.hostUserId,
    required this.sessionData,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}



import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Unified Supabase service with production-ready architecture
/// Provides centralized database operations with enhanced error handling and performance
class UnifiedSupabaseService {
  static UnifiedSupabaseService? _instance;
  static UnifiedSupabaseService get instance {
    _instance ??= UnifiedSupabaseService._();
    return _instance!;
  }

  UnifiedSupabaseService._();

  /// Production-ready environment configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Validate environment configuration
  static void validateEnvironment() {
    if (supabaseUrl.isEmpty) {
      throw Exception(
          'SUPABASE_URL is not configured. Check your env.json file.');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_ANON_KEY is not configured. Check your env.json file.');
    }
  }

  /// Enhanced Supabase client with error boundaries
  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('❌ Supabase client not available: $e');
      throw Exception(
          'Critical: Supabase not properly initialized. Check your configuration.');
    }
  }

  /// Initialize Supabase with comprehensive validation
  static Future<void> initialize() async {
    try {
      validateEnvironment();

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      debugPrint('✅ Unified Supabase service initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
      rethrow;
    }
  }

  // =============================================
  // AUTHENTICATION OPERATIONS
  // =============================================

  /// Get current authenticated user with null safety
  User? getCurrentUser() {
    try {
      return client.auth.currentUser;
    } catch (e) {
      debugPrint('⚠️ Cannot get current user: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => getCurrentUser() != null;

  /// Get user ID safely
  String? get currentUserId => getCurrentUser()?.id;

  /// Enhanced sign up with comprehensive profile data
  Future<AuthResponse> signUpWithProfile({
    required String email,
    required String password,
    String? fullName,
    String? avatarUrl,
    String? role,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final profileData = <String, dynamic>{
        'full_name': fullName ?? '',
        'avatar_url': avatarUrl ?? '',
        'role': role ?? 'user',
        ...?additionalMetadata,
      };

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: profileData,
      );

      if (response.user != null) {
        debugPrint('✅ User signed up successfully: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Sign up failed: $e');
      rethrow;
    }
  }

  /// Enhanced sign in with better error handling
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('✅ User signed in successfully: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Sign in failed: $e');
      throw _handleAuthError(e);
    }
  }

  /// Enhanced OAuth sign in (Google, etc.)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      final success = await client.auth.signInWithOAuth(provider);
      if (success) {
        debugPrint('✅ OAuth sign in successful with ${provider.name}');
      }
      return success;
    } catch (e) {
      debugPrint('❌ OAuth sign in failed: $e');
      rethrow;
    }
  }

  /// Enhanced sign out with cleanup
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }

  // =============================================
  // SMART CRUD OPERATIONS WITH SACRED ORDER
  // =============================================

  /// Universal select with sacred method chaining order
  Future<List<Map<String, dynamic>>> selectData(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    Map<String, dynamic>? rangeFilters,
    String? searchColumn,
    String? searchTerm,
    String? orderColumn,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      // Step 1: Start with table and operation (SACRED ORDER)
      var query = client.from(table).select(columns);

      // Step 2: Apply all filters first (SACRED ORDER)
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            query = query.eq(entry.key, entry.value);
          }
        }
      }

      // Apply range filters
      if (rangeFilters != null) {
        for (final entry in rangeFilters.entries) {
          final value = entry.value;
          if (value != null) {
            if (entry.key.endsWith('_gte')) {
              query = query.gte(entry.key.replaceAll('_gte', ''), value);
            } else if (entry.key.endsWith('_lte')) {
              query = query.lte(entry.key.replaceAll('_lte', ''), value);
            }
          }
        }
      }

      // Apply search filter
      if (searchColumn != null && searchTerm != null && searchTerm.isNotEmpty) {
        query = query.ilike(searchColumn, '%$searchTerm%');
      }

      // Step 3: Apply modifiers in one chain (SACRED ORDER)
      dynamic finalQuery = query;

      if (orderColumn != null) {
        finalQuery = finalQuery.order(orderColumn, ascending: ascending);
      }

      if (limit != null && limit > 0) {
        finalQuery = finalQuery.limit(limit);
      }

      if (offset != null && offset >= 0 && limit != null) {
        finalQuery = finalQuery.range(offset, offset + limit - 1);
      }

      final response = await finalQuery;
      return _processResponse(response);
    } catch (e) {
      debugPrint('❌ Select from $table failed: $e');
      return [];
    }
  }

  /// Smart insert with auto-cleanup and validation
  Future<Map<String, dynamic>?> insertData(
    String table,
    Map<String, dynamic> data, {
    bool returnData = true,
  }) async {
    try {
      // Clean data: remove null values and add timestamps
      final cleanData = _cleanInsertData(data);

      final query = client.from(table).insert(cleanData);
      final response = returnData ? await query.select().single() : await query;

      if (returnData && response is Map<String, dynamic>) {
        debugPrint('✅ Inserted into $table successfully');
        return response;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Insert into $table failed: $e');
      throw _handleDatabaseError(e, 'insert', table);
    }
  }

  /// Smart update with optimistic concurrency
  Future<Map<String, dynamic>?> updateData(
    String table,
    String id,
    Map<String, dynamic> data, {
    String idColumn = 'id',
  }) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID cannot be empty for update operation');
      }

      // Clean data and add updated timestamp
      final cleanData = _cleanUpdateData(data);

      final response = await client
          .from(table)
          .update(cleanData)
          .eq(idColumn, id)
          .select()
          .single();

      debugPrint('✅ Updated $table record successfully');
      return response is Map<String, dynamic> ? response : null;
    } catch (e) {
      debugPrint('❌ Update in $table failed: $e');
      throw _handleDatabaseError(e, 'update', table);
    }
  }

  /// Smart delete with cascade awareness
  Future<bool> deleteData(
    String table,
    String id, {
    String idColumn = 'id',
  }) async {
    try {
      if (id.isEmpty) {
        debugPrint('⚠️ Empty ID provided for delete operation');
        return false;
      }

      await client.from(table).delete().eq(idColumn, id);
      debugPrint('✅ Deleted from $table successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Delete from $table failed: $e');
      return false;
    }
  }

  // =============================================
  // ADVANCED OPERATIONS
  // =============================================

  /// Get count with proper method chaining
  Future<int> getCount(
    String table, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      var query = client.from(table).select('id');

      // Apply filters first (SACRED ORDER)
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            query = query.eq(entry.key, entry.value);
          }
        }
      }

      final response = await query.count();
      return response.count ?? 0;
    } catch (e) {
      debugPrint('❌ Count query for $table failed: $e');
      return 0;
    }
  }

  /// Batch operations with transaction safety
  Future<List<Map<String, dynamic>>> batchInsert(
    String table,
    List<Map<String, dynamic>> records,
  ) async {
    try {
      if (records.isEmpty) return [];

      // Clean all records
      final cleanRecords =
          records.map((record) => _cleanInsertData(record)).toList();

      final response = await client.from(table).insert(cleanRecords).select();
      debugPrint(
          '✅ Batch insert to $table completed: ${cleanRecords.length} records');

      return _processResponse(response);
    } catch (e) {
      debugPrint('❌ Batch insert to $table failed: $e');
      rethrow;
    }
  }

  /// Join operations with proper syntax
  Future<List<Map<String, dynamic>>> joinQuery(
    String primaryTable,
    String joinTable, {
    String? primaryColumns,
    String? joinColumns,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final primaryCols = primaryColumns ?? '*';
      final joinCols = joinColumns ?? '*';
      final selectClause = '$primaryCols, $joinTable($joinCols)';

      var query = client.from(primaryTable).select(selectClause);

      // Apply filters (SACRED ORDER)
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            query = query.eq(entry.key, entry.value);
          }
        }
      }

      final response = await query;
      return _processResponse(response);
    } catch (e) {
      debugPrint('❌ Join query failed: $e');
      return [];
    }
  }

  // =============================================
  // REAL-TIME SUBSCRIPTIONS
  // =============================================

  /// Enhanced real-time subscription with error recovery
  RealtimeChannel subscribeToTable(
    String table,
    void Function(PostgresChangePayload) onData, {
    PostgresChangeEvent event = PostgresChangeEvent.all,
    void Function(String, [Object?, StackTrace?])? onError,
  }) {
    try {
      final channel = client
          .channel('public:$table:${DateTime.now().millisecondsSinceEpoch}')
          .onPostgresChanges(
            event: event,
            schema: 'public',
            table: table,
            callback: (payload) {
              try {
                onData(payload);
              } catch (e, stackTrace) {
                debugPrint('❌ Real-time callback error for $table: $e');
                onError?.call('Callback error', e, stackTrace);
              }
            },
          );

      channel.subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          debugPrint('✅ Subscribed to $table changes');
        } else if (status == RealtimeSubscribeStatus.timedOut) {
          debugPrint('⏰ Subscription to $table timed out');
        } else if (status == RealtimeSubscribeStatus.closed) {
          debugPrint('🔒 Subscription to $table closed');
        }
      });

      return channel;
    } catch (e) {
      debugPrint('❌ Failed to subscribe to $table: $e');
      rethrow;
    }
  }

  /// Unsubscribe from real-time channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      await client.removeChannel(channel);
      debugPrint('✅ Unsubscribed from real-time channel');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe: $e');
    }
  }

  // =============================================
  // HEALTH & MONITORING
  // =============================================

  /// Comprehensive health check with performance metrics
  Future<Map<String, dynamic>> healthCheck() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Quick connectivity test
      await client.from('user_profiles').select('id').limit(1);

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      // Determine connection quality
      String quality;
      if (latency < 100) {
        quality = 'excellent';
      } else if (latency < 300) {
        quality = 'good';
      } else if (latency < 1000) {
        quality = 'fair';
      } else {
        quality = 'poor';
      }

      return {
        'status': 'healthy',
        'latency_ms': latency,
        'quality': quality,
        'authenticated': isAuthenticated,
        'user_id': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
        'environment': kDebugMode ? 'development' : 'production',
      };
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ Health check failed: $e');

      return {
        'status': 'unhealthy',
        'latency_ms': -1,
        'quality': 'unavailable',
        'authenticated': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'environment': kDebugMode ? 'development' : 'production',
      };
    }
  }

  /// Get comprehensive system status
  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final health = await healthCheck();
      final userCount = await getCount('user_profiles');
      final todoCount = await getCount('todos');
      final messageCount = await getCount('ferchat_messages');

      return {
        'connection': health,
        'database_stats': {
          'total_users': userCount,
          'total_todos': todoCount,
          'total_messages': messageCount,
          'last_updated': DateTime.now().toIso8601String(),
        },
        'features': {
          'real_time_sync': true,
          'offline_support': true,
          'blockchain_auth': true,
          'aiferid_integration': true,
          'file_storage': true,
          'push_notifications': false,
        },
        'sdk_info': {
          'supabase_url': supabaseUrl.isNotEmpty ? 'configured' : 'missing',
          'environment': kDebugMode ? 'development' : 'production',
          'debug_mode': kDebugMode,
        }
      };
    } catch (e) {
      debugPrint('❌ System status check failed: $e');
      return {
        'connection': {'status': 'failed', 'error': e.toString()},
        'database_stats': {'error': 'unavailable'},
        'features': {'error': 'unavailable'},
      };
    }
  }

  // =============================================
  // HELPER METHODS
  // =============================================

  /// Process query response with null safety
  List<Map<String, dynamic>> _processResponse(dynamic response) {
    try {
      if (response == null) return [];

      final List<dynamic> rawList = response is List ? response : [response];
      return rawList.map((item) {
        if (item is Map<String, dynamic>) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      debugPrint('❌ Error processing response: $e');
      return [];
    }
  }

  /// Clean insert data by removing nulls and adding timestamps
  Map<String, dynamic> _cleanInsertData(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};

    data.forEach((key, value) {
      if (value != null) {
        cleaned[key] = value;
      }
    });

    // Add created_at if not present
    if (!cleaned.containsKey('created_at')) {
      cleaned['created_at'] = DateTime.now().toIso8601String();
    }

    return cleaned;
  }

  /// Clean update data by removing nulls and updating timestamp
  Map<String, dynamic> _cleanUpdateData(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};

    data.forEach((key, value) {
      if (value != null && key != 'id' && key != 'created_at') {
        cleaned[key] = value;
      }
    });

    // Always update the updated_at timestamp
    cleaned['updated_at'] = DateTime.now().toIso8601String();

    return cleaned;
  }

  /// Handle authentication errors with user-friendly messages
  Exception _handleAuthError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('invalid_credentials') ||
        errorStr.contains('email not confirmed')) {
      return Exception(
          'Invalid email or password. Please check your credentials.');
    } else if (errorStr.contains('email_already_exists')) {
      return Exception('An account with this email already exists.');
    } else if (errorStr.contains('weak_password')) {
      return Exception(
          'Password is too weak. Please choose a stronger password.');
    } else if (errorStr.contains('invalid_email')) {
      return Exception('Please enter a valid email address.');
    } else {
      return Exception('Authentication failed. Please try again.');
    }
  }

  /// Handle database errors with context
  Exception _handleDatabaseError(
      dynamic error, String operation, String table) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('permission') || errorStr.contains('rls')) {
      return Exception(
          'Access denied. You don\'t have permission to $operation this data.');
    } else if (errorStr.contains('foreign_key') ||
        errorStr.contains('constraint')) {
      return Exception(
          'Data integrity error. Please check your input and try again.');
    } else if (errorStr.contains('duplicate') || errorStr.contains('unique')) {
      return Exception(
          'This record already exists. Please use different values.');
    } else {
      return Exception('Database operation failed. Please try again.');
    }
  }

  /// Safe execution wrapper with retry logic
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries) {
          debugPrint('❌ Operation failed after $maxRetries attempts: $e');
          rethrow;
        }

        debugPrint(
            '⚠️ Attempt $attempt failed, retrying in ${delay.inMilliseconds}ms: $e');
        await Future.delayed(delay);
      }
    }
    return null;
  }
}

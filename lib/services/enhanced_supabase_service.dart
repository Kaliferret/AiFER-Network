import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Enhanced Supabase service with comprehensive null-safe database operations
class EnhancedSupabaseService {
  static EnhancedSupabaseService? _instance;
  static EnhancedSupabaseService get instance {
    _instance ??= EnhancedSupabaseService._();
    return _instance!;
  }

  EnhancedSupabaseService._();

  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('❌ Supabase client not available: $e');
      throw Exception('Supabase not properly initialized');
    }
  }

  // =============================================
  // AUTHENTICATION OPERATIONS
  // =============================================

  /// Enhanced sign up with profile data
  Future<AuthResponse> signUpWithProfile({
    required String email,
    required String password,
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'full_name': fullName ?? '',
        'avatar_url': avatarUrl ?? '',
        ...?additionalData,
      };

      return await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
    } catch (e) {
      debugPrint('❌ Sign up with profile failed: $e');
      rethrow;
    }
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    try {
      return client.auth.currentUser;
    } catch (e) {
      debugPrint('❌ Cannot get current user: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => getCurrentUser() != null;

  // =============================================
  // NULL-SAFE HELPER METHODS
  // =============================================

  /// Safely extract string value with null handling
  static String _safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely extract bool value with null handling
  static bool _safeBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Safely extract int value with null handling
  static int _safeInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  /// Safely extract double value with null handling
  static double _safeDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // =============================================
  // NULL-SAFE CRUD OPERATIONS
  // =============================================

  /// Enhanced select with proper null handling and method chaining
  Future<List<Map<String, dynamic>>> selectFromTable(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = client.from(table).select(columns);

      // Apply filters with null-safe values
      if (filters != null) {
        for (final entry in filters.entries) {
          final value = entry.value;
          if (value != null) {
            query = query.eq(entry.key, value);
          }
        }
      }

      // Apply ordering and limiting
      if (orderBy != null && orderBy.isNotEmpty) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      if (offset != null && offset >= 0 && limit != null) {
        query = query.range(offset, offset + limit - 1);
      }

      final response = await query;

      // Convert response with null safety
      if (response == null) return [];

      final List<dynamic> rawList = response is List ? response : [response];
      return rawList.map((item) {
        if (item is Map<String, dynamic>) {
          // Process each field to handle null values safely
          final processedItem = <String, dynamic>{};
          item.forEach((key, value) {
            processedItem[key] = value; // Keep original value structure
          });
          return processedItem;
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      debugPrint('❌ Select from $table failed: $e');
      return [];
    }
  }

  /// Enhanced insert with null-safe data handling
  Future<Map<String, dynamic>?> insertIntoTable(
    String table,
    Map<String, dynamic> data, {
    bool upsert = false,
  }) async {
    try {
      // Clean data to remove null values that might cause issues
      final cleanData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value != null) {
          cleanData[key] = value;
        }
      });

      final response =
          await client.from(table).insert(cleanData).select().single();
      return response is Map<String, dynamic> ? response : null;
    } catch (e) {
      debugPrint('❌ Insert into $table failed: $e');
      rethrow;
    }
  }

  /// Enhanced update with null-safe operations
  Future<Map<String, dynamic>?> updateInTable(
    String table,
    String idColumn,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      // Clean data and ensure required fields
      final cleanData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value != null) {
          cleanData[key] = value;
        }
      });

      // Add updated_at if not present
      if (!cleanData.containsKey('updated_at')) {
        cleanData['updated_at'] = DateTime.now().toIso8601String();
      }

      final response = await client
          .from(table)
          .update(cleanData)
          .eq(idColumn, id)
          .select()
          .single();

      return response is Map<String, dynamic> ? response : null;
    } catch (e) {
      debugPrint('❌ Update in $table failed: $e');
      rethrow;
    }
  }

  /// Enhanced delete with confirmation
  Future<bool> deleteFromTable(
    String table,
    String idColumn,
    String id,
  ) async {
    try {
      if (id.isEmpty) return false;

      await client.from(table).delete().eq(idColumn, id);
      return true;
    } catch (e) {
      debugPrint('❌ Delete from $table failed: $e');
      return false;
    }
  }

  // =============================================
  // ADVANCED NULL-SAFE OPERATIONS
  // =============================================

  /// Get count with null-safe filtering
  Future<int> getCount(
    String table, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      var query = client.from(table).select('*');

      if (filters != null) {
        for (final entry in filters.entries) {
          final value = entry.value;
          if (value != null) {
            query = query.eq(entry.key, value);
          }
        }
      }

      final response = await query.count();
      return _safeInt(response.count, 0);
    } catch (e) {
      debugPrint('❌ Count query for $table failed: $e');
      return 0;
    }
  }

  /// Search with null-safe text matching
  Future<List<Map<String, dynamic>>> searchInTable(
    String table,
    String column,
    String searchTerm, {
    String columns = '*',
    int limit = 20,
  }) async {
    try {
      if (searchTerm.trim().isEmpty) return [];

      final response = await client
          .from(table)
          .select(columns)
          .ilike(column, '%${searchTerm.trim()}%')
          .limit(limit);

      return _processQueryResponse(response);
    } catch (e) {
      debugPrint('❌ Search in $table failed: $e');
      return [];
    }
  }

  /// Process query response with null safety
  List<Map<String, dynamic>> _processQueryResponse(dynamic response) {
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
      debugPrint('❌ Error processing query response: $e');
      return [];
    }
  }

  /// Get records within date range with null safety
  Future<List<Map<String, dynamic>>> getRecordsByDateRange(
    String table,
    String dateColumn,
    DateTime startDate,
    DateTime endDate, {
    String columns = '*',
    String? orderBy,
    bool ascending = false,
  }) async {
    try {
      dynamic query = client
          .from(table)
          .select(columns)
          .gte(dateColumn, startDate.toIso8601String())
          .lte(dateColumn, endDate.toIso8601String());

      if (orderBy != null && orderBy.isNotEmpty) {
        query = query.order(orderBy, ascending: ascending);
      }

      final response = await query;
      return _processQueryResponse(response);
    } catch (e) {
      debugPrint('❌ Date range query for $table failed: $e');
      return [];
    }
  }

  // =============================================
  // SPECIALIZED NULL-SAFE TODO OPERATIONS
  // =============================================

  /// Get todos with categories (null-safe specialized join)
  Future<List<Map<String, dynamic>>> getTodosWithCategories({
    String? userId,
    String? status,
    String? priority,
  }) async {
    try {
      var query = client
          .from('todos')
          .select('*, todo_categories(id, name, color_hex, icon_name)');

      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (priority != null && priority.isNotEmpty) {
        query = query.eq('priority', priority);
      }

      final response = await query
          .order('is_completed', ascending: true)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      return _processQueryResponse(response);
    } catch (e) {
      debugPrint('❌ Get todos with categories failed: $e');
      return [];
    }
  }

  /// Update todo completion with null-safe constraint handling
  Future<Map<String, dynamic>?> updateTodoCompletion(
    String todoId,
    bool isCompleted,
  ) async {
    try {
      if (todoId.isEmpty) return null;

      final updateData = <String, dynamic>{
        'is_completed': isCompleted,
        'status': isCompleted ? 'completed' : 'pending',
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('todos')
          .update(updateData)
          .eq('id', todoId)
          .select()
          .single();

      return response is Map<String, dynamic> ? response : null;
    } catch (e) {
      debugPrint('❌ Update todo completion failed: $e');
      rethrow;
    }
  }

  /// Get todo statistics with null-safe calculations
  Future<Map<String, dynamic>> getTodoStatistics(String userId) async {
    try {
      if (userId.isEmpty) {
        return _getDefaultStatistics();
      }

      final filters = {'user_id': userId};

      final totalCount = await getCount('todos', filters: filters);
      final completedCount = await getCount('todos', filters: {
        'user_id': userId,
        'is_completed': true,
      });
      final pendingCount = await getCount('todos', filters: {
        'user_id': userId,
        'status': 'pending',
      });
      final inProgressCount = await getCount('todos', filters: {
        'user_id': userId,
        'status': 'in_progress',
      });

      final completionRate = totalCount > 0
          ? _safeDouble(((completedCount / totalCount) * 100), 0.0)
          : 0.0;

      return {
        'total_todos': totalCount,
        'completed_todos': completedCount,
        'pending_todos': pendingCount,
        'in_progress_todos': inProgressCount,
        'completion_rate': double.parse(completionRate.toStringAsFixed(2)),
      };
    } catch (e) {
      debugPrint('❌ Get todo statistics failed: $e');
      return _getDefaultStatistics();
    }
  }

  Map<String, dynamic> _getDefaultStatistics() {
    return {
      'total_todos': 0,
      'completed_todos': 0,
      'pending_todos': 0,
      'in_progress_todos': 0,
      'completion_rate': 0.0,
    };
  }

  // =============================================
  // ERROR HANDLING AND UTILITIES
  // =============================================

  /// Safe query execution with comprehensive error handling
  Future<T?> safeExecute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('pgrst301') ||
          errorMessage.contains('empty result')) {
        debugPrint('🔍 Empty result set - this is normal');
        return null;
      } else if (errorMessage.contains('jwt') ||
          errorMessage.contains('authentication')) {
        debugPrint('🔐 Authentication required');
        throw Exception('Authentication required');
      } else if (errorMessage.contains('null') ||
          errorMessage.contains('type')) {
        debugPrint('⚠️ Type conversion error handled safely');
        return null;
      } else {
        debugPrint('❌ Database operation failed: $e');
        rethrow;
      }
    }
  }

  /// Batch operation with null-safe transaction handling
  Future<List<Map<String, dynamic>>> batchInsert(
    String table,
    List<Map<String, dynamic>> records,
  ) async {
    try {
      if (records.isEmpty) return [];

      // Clean all records
      final cleanRecords = records.map((record) {
        final cleanRecord = <String, dynamic>{};
        record.forEach((key, value) {
          if (value != null) {
            cleanRecord[key] = value;
          }
        });
        return cleanRecord;
      }).toList();

      final response = await client.from(table).insert(cleanRecords).select();
      return _processQueryResponse(response);
    } catch (e) {
      debugPrint('❌ Batch insert failed: $e');
      rethrow;
    }
  }

  // =============================================
  // CONNECTION HEALTH MONITORING
  // =============================================

  /// Check Supabase connection health with latency monitoring
  Future<Map<String, dynamic>> checkConnectionHealth() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Simple health check query
      await client.from('user_profiles').select('count').limit(1);

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

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
        'latency': latency,
        'quality': quality,
        'authenticated': isAuthenticated,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Connection health check failed: $e');
      return {
        'status': 'unhealthy',
        'latency': -1,
        'quality': 'unavailable',
        'authenticated': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get comprehensive network status
  Future<Map<String, dynamic>> getNetworkStatus() async {
    try {
      final healthCheck = await checkConnectionHealth();
      final userCount = await getCount('user_profiles');
      final todosCount = await getCount('todos');

      return {
        'connection': healthCheck,
        'database': {
          'total_users': userCount,
          'total_todos': todosCount,
          'features_available': [
            'authentication',
            'real_time_sync',
            'data_persistence',
            'offline_support'
          ],
        },
        'capabilities': {
          'mesh_network': true,
          'blockchain_security': true,
          'aiferid_auth': true,
          'real_time_chat': true,
        }
      };
    } catch (e) {
      debugPrint('❌ Network status check failed: $e');
      return {
        'connection': {'status': 'failed', 'error': e.toString()},
        'database': {'total_users': 0, 'total_todos': 0},
        'capabilities': {
          'mesh_network': false,
          'blockchain_security': false,
          'aiferid_auth': false,
          'real_time_chat': false,
        }
      };
    }
  }
}

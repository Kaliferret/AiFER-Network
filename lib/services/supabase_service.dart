import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  // Use environment variables instead of hardcoded values
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
      rethrow; // Rethrow to prevent app from starting with broken database
    }
  }

  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('❌ Supabase client not available: $e');
      throw Exception('Supabase not properly initialized');
    }
  }

  User? getCurrentUser() {
    try {
      return client.auth.currentUser;
    } catch (e) {
      debugPrint('❌ Cannot get current user: $e');
      return null;
    }
  }

  // Enhanced authentication methods
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('❌ Sign in failed: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
    } catch (e) {
      debugPrint('❌ Sign up failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }

  // Enhanced database operations with error handling
  Future<List<Map<String, dynamic>>> select(String table) async {
    try {
      final response = await client.from(table).select();
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      debugPrint('❌ Select failed for table $table: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      debugPrint('❌ Insert failed for table $table: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await client.from(table).update(data).eq('id', id).select().single();
      return response;
    } catch (e) {
      debugPrint('❌ Update failed for table $table: $e');
      rethrow;
    }
  }

  Future<void> delete(String table, String id) async {
    try {
      await client.from(table).delete().eq('id', id);
    } catch (e) {
      debugPrint('❌ Delete failed for table $table: $e');
      rethrow;
    }
  }

  // Real-time subscription support
  RealtimeChannel subscribe(
    String table,
    void Function(PostgresChangePayload) callback,
  ) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: callback,
        )
        .subscribe();
  }

  // Query builder support
  PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }
}

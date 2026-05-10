import 'package:supabase_flutter/supabase_flutter.dart';

class TodoService {
  static TodoService? _instance;
  static TodoService get instance => _instance ??= TodoService._();
  TodoService._();

  final SupabaseClient _client = Supabase.instance.client;

  // =============== CATEGORY OPERATIONS ===============

  /// Fetches all categories for the authenticated user
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('todo_categories')
          .select()
          .eq('user_id', _client.auth.currentUser!.id)
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  /// Creates a new category
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    String colorHex = '#6366f1',
    String iconName = 'folder',
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client
          .from('todo_categories')
          .insert({
            'user_id': _client.auth.currentUser!.id,
            'name': name,
            'description': description,
            'color_hex': colorHex,
            'icon_name': iconName,
            'sort_order': sortOrder,
          })
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create category: $error');
    }
  }

  /// Updates an existing category
  Future<Map<String, dynamic>> updateCategory(
    String categoryId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('todo_categories')
          .update(updates)
          .eq('id', categoryId)
          .eq('user_id', _client.auth.currentUser!.id)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update category: $error');
    }
  }

  /// Deletes a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _client
          .from('todo_categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to delete category: $error');
    }
  }

  // =============== TODO OPERATIONS ===============

  /// Fetches all todos for the authenticated user
  Future<List<Map<String, dynamic>>> getTodos({
    String? categoryId,
    String? status,
    bool? isCompleted,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _client
          .from('todos')
          .select('*, todo_categories(name, color_hex, icon_name)')
          .eq('user_id', _client.auth.currentUser!.id);

      // Apply filters
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      if (isCompleted != null) {
        query = query.eq('is_completed', isCompleted);
      }

      // Apply sorting
      final response = await query.order(sortBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch todos: $error');
    }
  }

  /// Gets todos due today or overdue
  Future<List<Map<String, dynamic>>> getTodosForToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('todos')
          .select('*, todo_categories(name, color_hex, icon_name)')
          .eq('user_id', _client.auth.currentUser!.id)
          .eq('is_completed', false)
          .or('due_date.lte.${DateTime.now().toIso8601String()},due_date.gte.${startOfDay.toIso8601String()}.and.due_date.lt.${endOfDay.toIso8601String()}')
          .order('due_date', ascending: true)
          .order('priority', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch today\'s todos: $error');
    }
  }

  /// Creates a new todo
  Future<Map<String, dynamic>> createTodo({
    required String title,
    String? description,
    String? categoryId,
    String priority = 'medium',
    DateTime? dueDate,
    List<String> tags = const [],
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client
          .from('todos')
          .insert({
            'user_id': _client.auth.currentUser!.id,
            'title': title,
            'description': description,
            'category_id': categoryId,
            'priority': priority,
            'due_date': dueDate?.toIso8601String(),
            'tags': tags,
            'sort_order': sortOrder,
          })
          .select('*, todo_categories(name, color_hex, icon_name)')
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create todo: $error');
    }
  }

  /// Updates an existing todo
  Future<Map<String, dynamic>> updateTodo(
    String todoId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('todos')
          .update(updates)
          .eq('id', todoId)
          .eq('user_id', _client.auth.currentUser!.id)
          .select('*, todo_categories(name, color_hex, icon_name)')
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update todo: $error');
    }
  }

  /// Marks a todo as completed
  Future<Map<String, dynamic>> completeTodo(String todoId) async {
    try {
      final response = await _client
          .from('todos')
          .update({
            'status': 'completed',
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', todoId)
          .eq('user_id', _client.auth.currentUser!.id)
          .select('*, todo_categories(name, color_hex, icon_name)')
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to complete todo: $error');
    }
  }

  /// Marks a todo as incomplete
  Future<Map<String, dynamic>> incompleteTodo(String todoId) async {
    try {
      final response = await _client
          .from('todos')
          .update({
            'status': 'pending',
            'is_completed': false,
            'completed_at': null,
          })
          .eq('id', todoId)
          .eq('user_id', _client.auth.currentUser!.id)
          .select('*, todo_categories(name, color_hex, icon_name)')
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to mark todo as incomplete: $error');
    }
  }

  /// Deletes a todo
  Future<void> deleteTodo(String todoId) async {
    try {
      await _client
          .from('todos')
          .delete()
          .eq('id', todoId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to delete todo: $error');
    }
  }

  // =============== STATISTICS & INSIGHTS ===============

  /// Gets comprehensive todo statistics
  Future<Map<String, dynamic>> getTodoStatistics() async {
    try {
      final userId = _client.auth.currentUser!.id;
      
      final totalTodos = await _client
          .from('todos')
          .select('id')
          .eq('user_id', userId)
          .count();

      final completedTodos = await _client
          .from('todos')
          .select('id')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .count();

      final pendingTodos = await _client
          .from('todos')
          .select('id')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .count();

      final overdueTodos = await _client
          .from('todos')
          .select('id')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .lt('due_date', DateTime.now().toIso8601String())
          .count();

      final totalCount = totalTodos.count ?? 0;
      final completedCount = completedTodos.count ?? 0;
      
      return {
        'total_todos': totalCount,
        'completed_todos': completedCount,
        'pending_todos': pendingTodos.count ?? 0,
        'overdue_todos': overdueTodos.count ?? 0,
        'completion_rate': totalCount > 0 
            ? double.parse(((completedCount / totalCount) * 100).toStringAsFixed(1))
            : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to get todo statistics: $error');
    }
  }

  /// Gets category-wise todo statistics
  Future<List<Map<String, dynamic>>> getCategoryStatistics() async {
    try {
      final categories = await _client
          .from('todo_categories')
          .select('id, name, color_hex')
          .eq('user_id', _client.auth.currentUser!.id)
          .order('name', ascending: true);

      final List<Map<String, dynamic>> categoryStats = [];

      for (final category in categories) {
        final categoryId = category['id'];
        
        final totalData = await _client
            .from('todos')
            .select('id')
            .eq('user_id', _client.auth.currentUser!.id)
            .eq('category_id', categoryId)
            .count();

        final completedData = await _client
            .from('todos')
            .select('id')
            .eq('user_id', _client.auth.currentUser!.id)
            .eq('category_id', categoryId)
            .eq('is_completed', true)
            .count();

        final totalCount = totalData.count ?? 0;
        final completedCount = completedData.count ?? 0;

        categoryStats.add({
          'category': category,
          'total_todos': totalCount,
          'completed_todos': completedCount,
          'pending_todos': totalCount - completedCount,
          'completion_rate': totalCount > 0 
              ? double.parse(((completedCount / totalCount) * 100).toStringAsFixed(1))
              : 0.0,
        });
      }

      return categoryStats;
    } catch (error) {
      throw Exception('Failed to get category statistics: $error');
    }
  }

  // =============== SEARCH & FILTER ===============

  /// Searches todos by title and description
  Future<List<Map<String, dynamic>>> searchTodos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getTodos();
      }

      final response = await _client
          .from('todos')
          .select('*, todo_categories(name, color_hex, icon_name)')
          .eq('user_id', _client.auth.currentUser!.id)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search todos: $error');
    }
  }

  /// Subscribes to real-time changes in todos
  RealtimeChannel subscribeToTodoChanges({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    return _client
        .channel('todos_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'todos',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'todos',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'todos',
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }
}
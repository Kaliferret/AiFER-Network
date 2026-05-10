/// Supabase Integration Guide for Flutter
///
/// This file serves as a comprehensive reference for integrating Supabase
/// with Flutter applications following best practices and proper method chaining.

/*
# 🚀 SUPABASE FLUTTER INTEGRATION GUIDE

## 📋 Table of Contents
1. [Setup and Configuration](#setup)
2. [Authentication](#authentication)
3. [Database Operations](#database-operations)
4. [Real-time Subscriptions](#real-time)
5. [Storage Operations](#storage)
6. [Best Practices](#best-practices)
7. [Error Handling](#error-handling)
8. [Common Patterns](#patterns)

## 🛠️ Setup and Configuration {#setup}

### Dependencies
```yaml
dependencies:
  supabase_flutter: ^2.9.0
  google_sign_in: ^6.2.1  # For Google OAuth
```

### Environment Variables
```json
{
  "SUPABASE_URL": "your_supabase_project_url",
  "SUPABASE_ANON_KEY": "your_supabase_anon_key"
}
```

### Initialization in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  
  runApp(MyApp());
}
```

## 🔐 Authentication {#authentication}

### Sign Up with Profile Data
```dart
Future<AuthResponse> signUpWithProfile({
  required String email,
  required String password,
  String? fullName,
  String? avatarUrl,
}) async {
  final response = await Supabase.instance.client.auth.signUp(
    email: email,
    password: password,
    data: {
      'full_name': fullName ?? '',
      'avatar_url': avatarUrl ?? '',
    },
  );
  return response;
}
```

### Sign In
```dart
Future<AuthResponse> signIn(String email, String password) async {
  return await Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );
}
```

### Google OAuth (Web)
```dart
Future<bool> signInWithGoogleWeb() async {
  return await Supabase.instance.client.auth.signInWithOAuth(
    OAuthProvider.google,
  );
}
```

### Google OAuth (Native)
```dart
Future<bool> signInWithGoogleNative(String webClientId) async {
  final googleSignIn = GoogleSignIn(serverClientId: webClientId);
  
  GoogleSignInAccount? user = await googleSignIn.signInSilently();
  user ??= await googleSignIn.signIn();
  
  if (user == null) return false;
  
  final googleAuth = await user.authentication;
  final idToken = googleAuth.idToken;
  
  if (idToken == null) throw AuthException('No ID Token found');
  
  final response = await Supabase.instance.client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: googleAuth.accessToken,
  );
  
  return response.user != null;
}
```

### Auth State Listening
```dart
StreamSubscription<AuthState>? _authSubscription;

void listenToAuthChanges() {
  _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    final User? user = data.session?.user;
    
    switch (event) {
      case AuthChangeEvent.signedIn:
        // Navigate to home
        break;
      case AuthChangeEvent.signedOut:
        // Navigate to login
        break;
      case AuthChangeEvent.tokenRefreshed:
        // Handle token refresh
        break;
    }
  });
}

@override
void dispose() {
  _authSubscription?.cancel();
  super.dispose();
}
```

## 💾 Database Operations {#database-operations}

### ⚠️ CRITICAL: Method Chaining Rules
**Sacred Order: from() → operation() → filters → modifiers → result_type**

```dart
// ✅ CORRECT: Filters first, then modifiers
final result = await client
    .from('todos')
    .select()
    .eq('user_id', userId)        // Filter
    .gte('created_at', startDate) // Filter
    .order('created_at')          // Modifier
    .limit(10);                   // Modifier

// ❌ WRONG: Modifiers before filters
final result = await client
    .from('todos')
    .select()
    .order('created_at')          // ❌ Modifier first
    .eq('user_id', userId);       // ❌ Filter after modifier
```

### Basic CRUD Operations

#### Create (Insert)
```dart
Future<Map<String, dynamic>?> createTodo(Map<String, dynamic> todoData) async {
  final response = await Supabase.instance.client
      .from('todos')
      .insert(todoData)
      .select()
      .single();
  return response;
}
```

#### Read (Select)
```dart
Future<List<Map<String, dynamic>>> getUserTodos(String userId) async {
  final response = await Supabase.instance.client
      .from('todos')
      .select('*, todo_categories(name, color_hex)')
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
}
```

#### Update
```dart
Future<Map<String, dynamic>?> updateTodo(
  String todoId, 
  Map<String, dynamic> updates,
) async {
  final response = await Supabase.instance.client
      .from('todos')
      .update(updates)
      .eq('id', todoId)
      .select()
      .single();
  return response;
}
```

#### Delete
```dart
Future<bool> deleteTodo(String todoId) async {
  try {
    await Supabase.instance.client
        .from('todos')
        .delete()
        .eq('id', todoId);
    return true;
  } catch (e) {
    return false;
  }
}
```

### Advanced Queries

#### Filtering with Multiple Conditions
```dart
Future<List<Map<String, dynamic>>> getFilteredTodos({
  required String userId,
  String? status,
  String? priority,
  DateTime? dueAfter,
}) async {
  var query = Supabase.instance.client
      .from('todos')
      .select()
      .eq('user_id', userId);

  // Apply filters first
  if (status != null) {
    query = query.eq('status', status);
  }
  
  if (priority != null) {
    query = query.eq('priority', priority);
  }
  
  if (dueAfter != null) {
    query = query.gte('due_date', dueAfter.toIso8601String());
  }

  // Apply modifiers last
  final response = await query
      .order('priority', ascending: false)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}
```

#### Search with Text Matching
```dart
Future<List<Map<String, dynamic>>> searchTodos(
  String userId, 
  String searchTerm,
) async {
  final response = await Supabase.instance.client
      .from('todos')
      .select()
      .eq('user_id', userId)
      .ilike('title', '%$searchTerm%')
      .order('created_at', ascending: false)
      .limit(20);
  
  return List<Map<String, dynamic>>.from(response);
}
```

#### Count Records
```dart
Future<int> getTodoCount(String userId, {String? status}) async {
  var query = Supabase.instance.client
      .from('todos')
      .select()
      .eq('user_id', userId);

  if (status != null) {
    query = query.eq('status', status);
  }

  final response = await query.count();
  return response.count ?? 0;
}
```

#### Pagination
```dart
Future<List<Map<String, dynamic>>> getTodosPaginated(
  String userId, {
  int page = 1,
  int limit = 20,
}) async {
  final offset = (page - 1) * limit;
  
  final response = await Supabase.instance.client
      .from('todos')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .range(offset, offset + limit - 1);

  return List<Map<String, dynamic>>.from(response);
}
```

## 📡 Real-time Subscriptions {#real-time}

### Subscribe to Table Changes
```dart
class TodosRealtimeService {
  RealtimeChannel? _channel;

  void subscribeToTodos(String userId, Function(List<Map<String, dynamic>>) onUpdate) {
    _channel = Supabase.instance.client
        .channel('todos:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'todos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Refresh todos when changes occur
            _refreshTodos(userId, onUpdate);
          },
        )
        .subscribe();
  }

  Future<void> _refreshTodos(String userId, Function(List<Map<String, dynamic>>) onUpdate) async {
    final todos = await Supabase.instance.client
        .from('todos')
        .select('*, todo_categories(name, color_hex)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    onUpdate(List<Map<String, dynamic>>.from(todos));
  }

  void dispose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
  }
}
```

### Usage in Widget
```dart
class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodosRealtimeService _realtimeService = TodosRealtimeService();
  List<Map<String, dynamic>> todos = [];

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _realtimeService.subscribeToTodos(userId, (updatedTodos) {
        setState(() {
          todos = updatedTodos;
        });
      });
    }
  }

  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
  }
}
```

## 📁 Storage Operations {#storage}

### Upload File
```dart
Future<String> uploadFile(String bucketName, String path, File file) async {
  await Supabase.instance.client.storage
      .from(bucketName)
      .upload(path, file);
  
  return Supabase.instance.client.storage
      .from(bucketName)
      .getPublicUrl(path);
}
```

### Download File
```dart
Future<Uint8List> downloadFile(String bucketName, String path) async {
  return await Supabase.instance.client.storage
      .from(bucketName)
      .download(path);
}
```

## ✅ Best Practices {#best-practices}

### 1. Service Layer Pattern
```dart
class TodoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Todo>> getUserTodos(String userId) async {
    final response = await _client
        .from('todos')
        .select('*, todo_categories(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return response.map((json) => Todo.fromJson(json)).toList();
  }
}
```

### 2. Model Classes
```dart
class Todo {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final TodoCategory? category;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    this.category,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      category: json['todo_categories'] != null 
          ? TodoCategory.fromJson(json['todo_categories'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### 3. Error Handling
```dart
class SupabaseException implements Exception {
  final String message;
  final String? code;
  
  SupabaseException(this.message, [this.code]);
  
  @override
  String toString() => 'SupabaseException: $message${code != null ? ' (Code: $code)' : ''}';
}

Future<T> safeSupabaseOperation<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST301') {
      throw SupabaseException('No data found', e.code);
    } else if (e.code?.startsWith('23') == true) {
      throw SupabaseException('Data validation error', e.code);
    } else {
      throw SupabaseException('Database error: ${e.message}', e.code);
    }
  } on AuthException catch (e) {
    throw SupabaseException('Authentication error: ${e.message}', 'AUTH_ERROR');
  } catch (e) {
    throw SupabaseException('Unexpected error: $e');
  }
}
```

## 🚫 Common Anti-Patterns to Avoid

### 1. Wrong Method Chaining Order
```dart
// ❌ DON'T DO THIS
final result = await client.from('todos').select()
    .order('created_at')  // Modifier first
    .eq('user_id', userId); // Filter after modifier

// ✅ DO THIS
final result = await client.from('todos').select()
    .eq('user_id', userId)  // Filter first
    .order('created_at');   // Modifier last
```

### 2. Incorrect Count Syntax
```dart
// ❌ DON'T DO THIS
.select('*', const FetchOptions(count: CountOption.exact))

// ✅ DO THIS
final response = await query.count();
final count = response.count ?? 0;
```

### 3. Reassigning After Modifiers
```dart
// ❌ DON'T DO THIS
var query = client.from('todos').select().eq('user_id', userId);
query = query.order('created_at'); // ❌ Can't reassign after modifier
query = query.limit(10);           // ❌ Type error

// ✅ DO THIS
var query = client.from('todos').select();
query = query.eq('user_id', userId); // ✅ Can reassign during filters
final result = await query.order('created_at').limit(10); // ✅ Chain modifiers
```

## 🎯 Key Takeaways

1. **Always follow method chaining order**: filters → modifiers → execution
2. **Use proper error handling** for different error types
3. **Implement service layer** for clean architecture
4. **Use model classes** for type safety
5. **Handle real-time subscriptions** properly with cleanup
6. **Use environment variables** for configuration
7. **Implement proper authentication flows**
8. **Use RLS policies** for security in database

This guide provides the foundation for building robust Flutter applications with Supabase integration.
*/

// This file serves as documentation and should not contain executable code.
// Refer to the comments above for implementation examples.

class SupabaseIntegrationGuide {
  // This class exists only to provide the guide as documentation
  // All actual implementations should be in separate service files

  static const String version = '1.0.0';
  static const String lastUpdated = '2025-11-05';

  static void printGuideInfo() {
    print('📚 Supabase Integration Guide v$version');
    print('📅 Last Updated: $lastUpdated');
    print('📖 Check the file comments for comprehensive documentation');
  }
}

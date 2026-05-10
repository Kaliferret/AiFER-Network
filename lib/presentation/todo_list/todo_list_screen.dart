import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/todo_service.dart';
import './widgets/add_category_dialog.dart';
import './widgets/add_todo_bottom_sheet.dart';
import './widgets/category_filter_widget.dart';
import './widgets/todo_item_widget.dart';
import './widgets/todo_statistics_widget.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with TickerProviderStateMixin {
  final TodoService _todoService = TodoService.instance;

  // Data
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _statistics;

  // Filters
  String? _selectedCategoryId;
  String? _selectedStatus;
  bool _showCompleted = false;
  String _searchQuery = '';

  // UI State
  bool _isLoading = true;
  bool _isSearching = false;

  // Controllers
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _performSearch();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _todoService.getCategories(),
        _loadTodos(),
        _todoService.getTodoStatistics(),
      ]);

      setState(() {
        _categories = results[0] as List<Map<String, dynamic>>;
        _todos = results[1] as List<Map<String, dynamic>>;
        _statistics = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load data: $error');
    }
  }

  Future<List<Map<String, dynamic>>> _loadTodos() async {
    if (_searchQuery.isNotEmpty) {
      return await _todoService.searchTodos(_searchQuery);
    }

    return await _todoService.getTodos(
      categoryId: _selectedCategoryId,
      status: _selectedStatus,
      isCompleted: _showCompleted ? null : false,
      sortBy: 'sort_order',
      ascending: true,
    );
  }

  Future<void> _performSearch() async {
    setState(() => _isSearching = true);
    try {
      final todos = await _loadTodos();
      setState(() {
        _todos = todos;
        _isSearching = false;
      });
    } catch (error) {
      setState(() => _isSearching = false);
      _showErrorSnackBar('Search failed: $error');
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadData();
  }

  Future<void> _toggleTodoCompletion(String todoId, bool isCompleted) async {
    try {
      HapticFeedback.selectionClick();

      if (isCompleted) {
        await _todoService.incompleteTodo(todoId);
      } else {
        await _todoService.completeTodo(todoId);
      }

      await _refreshData();
    } catch (error) {
      _showErrorSnackBar('Failed to update todo: $error');
    }
  }

  Future<void> _deleteTodo(String todoId) async {
    try {
      HapticFeedback.heavyImpact();
      await _todoService.deleteTodo(todoId);
      await _refreshData();
    } catch (error) {
      _showErrorSnackBar('Failed to delete todo: $error');
    }
  }

  void _showAddTodoSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTodoBottomSheet(
        categories: _categories,
        onTodoAdded: () async {
          Navigator.pop(context);
          await _refreshData();
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onCategoryAdded: () async {
          Navigator.pop(context);
          await _refreshData();
        },
      ),
    );
  }

  void _applyFilter(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _performSearch();
  }

  void _toggleCompletedFilter() {
    setState(() {
      _showCompleted = !_showCompleted;
    });
    _performSearch();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search todos...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _performSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryFilterWidget(
                    categories: _categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _applyFilter,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(_showCompleted ? 'All' : 'Pending'),
            selected: _showCompleted,
            onSelected: (_) => _toggleCompletedFilter(),
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.blue[100],
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No todos found for "$_searchQuery"'
                  : 'No todos yet. Add your first task!',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isEmpty)
              ElevatedButton.icon(
                onPressed: _showAddTodoSheet,
                icon: const Icon(Icons.add),
                label: const Text('Add Todo'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return TodoItemWidget(
            todo: todo,
            onToggleComplete: () => _toggleTodoCompletion(
              todo['id'],
              todo['is_completed'] ?? false,
            ),
            onDelete: () => _deleteTodo(todo['id']),
            onEdit: () async {
              // Navigate to edit todo screen
              await _refreshData();
            },
          );
        },
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TodoStatisticsWidget(statistics: _statistics!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Todos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _showAddCategoryDialog,
            tooltip: 'Add Category',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Todos'),
            Tab(text: 'Today'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_tabController.index == 0) ...[
            _buildSearchBar(),
            _buildFilterBar(),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodoList(),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _todoService.getTodosForToday(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final todayTodos = snapshot.data ?? [];

                    if (todayTodos.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.today, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No todos for today!',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: todayTodos.length,
                      itemBuilder: (context, index) {
                        final todo = todayTodos[index];
                        return TodoItemWidget(
                          todo: todo,
                          showDueDate: true,
                          onToggleComplete: () => _toggleTodoCompletion(
                            todo['id'],
                            todo['is_completed'] ?? false,
                          ),
                          onDelete: () => _deleteTodo(todo['id']),
                          onEdit: () async => await _refreshData(),
                        );
                      },
                    );
                  },
                ),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 2
          ? null
          : FloatingActionButton(
              onPressed: _showAddTodoSheet,
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.add),
            ),
    );
  }
}

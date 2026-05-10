import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/todo_service.dart';

class AddTodoBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final VoidCallback onTodoAdded;
  final Map<String, dynamic>? editTodo;

  const AddTodoBottomSheet({
    Key? key,
    required this.categories,
    required this.onTodoAdded,
    this.editTodo,
  }) : super(key: key);

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TodoService _todoService = TodoService.instance;

  String? _selectedCategoryId;
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;
  List<String> _tags = [];
  bool _isLoading = false;

  final List<String> _priorities = ['low', 'medium', 'high', 'urgent'];
  final List<Color> _priorityColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editTodo != null) {
      _initializeEditMode();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeEditMode() {
    final todo = widget.editTodo!;
    _titleController.text = todo['title'] ?? '';
    _descriptionController.text = todo['description'] ?? '';
    _selectedCategoryId = todo['category_id'];
    _selectedPriority = todo['priority'] ?? 'medium';

    if (todo['due_date'] != null) {
      _selectedDueDate = DateTime.tryParse(todo['due_date']);
    }

    if (todo['tags'] != null) {
      _tags = List<String>.from(todo['tags']);
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _selectedDueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      HapticFeedback.selectionClick();

      final todoData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'priority': _selectedPriority,
        'due_date': _selectedDueDate?.toIso8601String(),
        'tags': _tags,
      };

      if (widget.editTodo != null) {
        await _todoService.updateTodo(widget.editTodo!['id'], todoData);
      } else {
        await _todoService.createTodo(
          title: todoData['title'] as String,
          description: todoData['description'] as String?,
          categoryId: todoData['category_id'] as String?,
          priority: todoData['priority'] as String,
          dueDate: _selectedDueDate,
          tags: todoData['tags'] as List<String>,
        );
      }

      widget.onTodoAdded();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save todo: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _priorities.asMap().entries.map((entry) {
            final index = entry.key;
            final priority = entry.value;
            final isSelected = _selectedPriority == priority;

            return FilterChip(
              label: Text(
                priority.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : _priorityColors[index],
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: _priorityColors[index],
              side: BorderSide(color: _priorityColors[index]),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          hint: const Text('Select category (optional)'),
          items: widget.categories.map((category) {
            final color = Color(
              int.parse(category['color_hex'].substring(1), radix: 16) +
                  0xFF000000,
            );

            return DropdownMenuItem<String>(
              value: category['id'],
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category['name']),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ..._tags.map((tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeTag(tag),
                  backgroundColor: Colors.blue[50],
                )),
            ActionChip(
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text('Add Tag'),
                ],
              ),
              onPressed: () => _showAddTagDialog(),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _addTag(value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addTag(controller.text.trim());
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.editTodo != null ? 'Edit Todo' : 'Add New Todo',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _saveTodo,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      maxLength: 200,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      maxLength: 1000,
                    ),

                    const SizedBox(height: 16),

                    // Priority
                    _buildPrioritySelector(),

                    const SizedBox(height: 16),

                    // Category
                    _buildCategorySelector(),

                    const SizedBox(height: 16),

                    // Due Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDueDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDueDate != null
                                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year} at ${TimeOfDay.fromDateTime(_selectedDueDate!).format(context)}'
                                      : 'Select due date (optional)',
                                  style: TextStyle(
                                    color: _selectedDueDate != null
                                        ? Colors.black87
                                        : Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                if (_selectedDueDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedDueDate = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tags
                    _buildTagsSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
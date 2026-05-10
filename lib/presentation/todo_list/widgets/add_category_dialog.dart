import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/todo_service.dart';

class AddCategoryDialog extends StatefulWidget {
  final VoidCallback onCategoryAdded;
  final Map<String, dynamic>? editCategory;

  const AddCategoryDialog({
    Key? key,
    required this.onCategoryAdded,
    this.editCategory,
  }) : super(key: key);

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TodoService _todoService = TodoService.instance;

  String _selectedColorHex = '#6366f1';
  String _selectedIcon = 'folder';
  bool _isLoading = false;

  final List<String> _availableColors = [
    '#6366f1', // Blue
    '#10b981', // Green
    '#f59e0b', // Yellow
    '#ef4444', // Red
    '#8b5cf6', // Purple
    '#06b6d4', // Cyan
    '#f97316', // Orange
    '#84cc16', // Lime
    '#ec4899', // Pink
    '#6b7280', // Gray
  ];

  final List<String> _availableIcons = [
    'folder',
    'work',
    'home',
    'fitness_center',
    'school',
    'shopping_cart',
    'restaurant',
    'travel_explore',
    'favorite',
    'star',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editCategory != null) {
      _initializeEditMode();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeEditMode() {
    final category = widget.editCategory!;
    _nameController.text = category['name'] ?? '';
    _descriptionController.text = category['description'] ?? '';
    _selectedColorHex = category['color_hex'] ?? '#6366f1';
    _selectedIcon = category['icon_name'] ?? 'folder';
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'school':
        return Icons.school;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'travel_explore':
        return Icons.travel_explore;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      default:
        return Icons.folder;
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      HapticFeedback.selectionClick();

      final categoryData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'color_hex': _selectedColorHex,
        'icon_name': _selectedIcon,
      };

      if (widget.editCategory != null) {
        await _todoService.updateCategory(
          widget.editCategory!['id'],
          categoryData,
        );
      } else {
        await _todoService.createCategory(
          name: categoryData['name']!,
          description: categoryData['description'],
          colorHex: categoryData['color_hex']!,
          iconName: categoryData['icon_name']!,
        );
      }

      widget.onCategoryAdded();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save category: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: _availableColors.map((colorHex) {
            final color = Color(
              int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
            );
            final isSelected = _selectedColorHex == colorHex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColorHex = colorHex;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black54 : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableIcons.map((iconName) {
            final isSelected = _selectedIcon == iconName;
            final selectedColor = Color(
              int.parse(_selectedColorHex.substring(1), radix: 16) + 0xFF000000,
            );

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = iconName;
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedColor.withAlpha(51)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? selectedColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getIconData(iconName),
                  color: isSelected ? selectedColor : Colors.grey[600],
                  size: 24,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final selectedColor = Color(
      int.parse(_selectedColorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selectedColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selectedColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getIconData(_selectedIcon),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Category Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_descriptionController.text.isNotEmpty)
                    Text(
                      _descriptionController.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.editCategory != null
                        ? 'Edit Category'
                        : 'Add New Category',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                        maxLength: 100,
                        onChanged: (value) => setState(() {}),
                      ),

                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 2,
                        maxLength: 500,
                        onChanged: (value) => setState(() {}),
                      ),

                      const SizedBox(height: 16),

                      // Color picker
                      _buildColorPicker(),

                      const SizedBox(height: 16),

                      // Icon picker
                      _buildIconPicker(),

                      const SizedBox(height: 16),

                      // Preview
                      _buildPreview(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.editCategory != null ? 'Update' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

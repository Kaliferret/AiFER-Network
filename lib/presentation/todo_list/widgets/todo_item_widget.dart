import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TodoItemWidget extends StatefulWidget {
  final Map<String, dynamic> todo;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool showDueDate;
  final bool showCategory;

  const TodoItemWidget({
    Key? key,
    required this.todo,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
    this.showDueDate = true,
    this.showCategory = true,
  }) : super(key: key);

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getPriorityColor() {
    switch (widget.todo['priority']) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon() {
    switch (widget.todo['priority']) {
      case 'urgent':
        return Icons.priority_high;
      case 'high':
        return Icons.keyboard_arrow_up;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.keyboard_arrow_down;
      default:
        return Icons.remove;
    }
  }

  String _formatDueDate() {
    final dueDate = DateTime.tryParse(widget.todo['due_date'] ?? '');
    if (dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todoDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final difference = todoDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days overdue';
    }
  }

  bool _isOverdue() {
    final dueDate = DateTime.tryParse(widget.todo['due_date'] ?? '');
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now()) &&
        !(widget.todo['is_completed'] ?? false);
  }

  void _showMoreOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            ListTile(
              leading: Icon(
                (widget.todo['is_completed'] ?? false)
                    ? Icons.undo
                    : Icons.check_circle,
              ),
              title: Text(
                (widget.todo['is_completed'] ?? false)
                    ? 'Mark as Incomplete'
                    : 'Mark as Complete',
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onToggleComplete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todo['is_completed'] ?? false;
    final category = widget.todo['todo_categories'];
    final categoryColor = category != null
        ? Color(int.parse(category['color_hex'].substring(1), radix: 16) +
            0xFF000000)
        : Colors.blue;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: _isOverdue()
                  ? Border.all(color: Colors.red.withAlpha(77))
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onToggleComplete();
                },
                onTapDown: (_) {
                  setState(() => _isPressed = true);
                  _animationController.forward();
                },
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  _animationController.reverse();
                },
                onTapCancel: () {
                  setState(() => _isPressed = false);
                  _animationController.reverse();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Completion checkbox
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isCompleted ? categoryColor : Colors.grey[400]!,
                            width: 2,
                          ),
                          color:
                              isCompleted ? categoryColor : Colors.transparent,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),

                      const SizedBox(width: 12),

                      // Todo content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              widget.todo['title'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? Colors.grey[500]
                                    : Colors.black87,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),

                            // Description (if available)
                            if (widget.todo['description'] != null &&
                                widget.todo['description'].isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.todo['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            const SizedBox(height: 8),

                            // Metadata row
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                // Priority indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor().withAlpha(26),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getPriorityIcon(),
                                        size: 12,
                                        color: _getPriorityColor(),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        widget.todo['priority'] ?? 'medium',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _getPriorityColor(),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Category (if available and showCategory is true)
                                if (widget.showCategory && category != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withAlpha(26),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      category['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: categoryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                // Due date (if available and showDueDate is true)
                                if (widget.showDueDate &&
                                    widget.todo['due_date'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isOverdue()
                                          ? Colors.red.withAlpha(26)
                                          : Colors.grey.withAlpha(26),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isOverdue()
                                              ? Icons.warning
                                              : Icons.schedule,
                                          size: 10,
                                          color: _isOverdue()
                                              ? Colors.red
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          _formatDueDate(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _isOverdue()
                                                ? Colors.red
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // More options button
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: _showMoreOptions,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryFilterWidget({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All categories chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(null);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
            ),
          ),

          // Individual category chips
          ...categories.map((category) {
            final isSelected = selectedCategoryId == category['id'];
            final color = Color(
              int.parse(category['color_hex'].substring(1), radix: 16) +
                  0xFF000000,
            );

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                label: Text(
                  category['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onCategorySelected(category['id']);
                  } else {
                    onCategorySelected(null);
                  }
                },
                backgroundColor: color.withAlpha(26),
                selectedColor: color,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

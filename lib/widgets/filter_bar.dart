import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String selectedCategory;
  final String selectedStatus;
  final String selectedDate;
  final List<Map<String, String>> categories;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onDateChanged;

  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.selectedDate,
    required this.categories,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDropdown(
          label: '分类',
          value: selectedCategory,
          items: ['全部分类', ...categories.map((c) => c['name'] ?? '')],
          onChanged: (v) {
            final index = categories.indexWhere((c) => c['name'] == v);
            onCategoryChanged(index >= 0 ? categories[index]['id'] ?? '' : '');
          },
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          label: '状态',
          value: selectedStatus.isEmpty
              ? '全部状态'
              : _statusLabel(selectedStatus),
          items: ['全部状态', '未完成', '已完成', '部分完成'],
          onChanged: (v) {
            onStatusChanged(_statusValue(v));
          },
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          label: '日期',
          value: selectedDate.isEmpty ? '全部时间' : selectedDate,
          items: const ['全部时间', '今天', '昨天', '近7天', '本周', '本月'],
          onChanged: (v) {
            onDateChanged(v == '全部时间' ? '' : v);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : items.first,
                isExpanded: true,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'todo':
        return '未完成';
      case 'done':
        return '已完成';
      case 'partial':
        return '部分完成';
      default:
        return value;
    }
  }

  String _statusValue(String label) {
    switch (label) {
      case '未完成':
        return 'todo';
      case '已完成':
        return 'done';
      case '部分完成':
        return 'partial';
      default:
        return '';
    }
  }
}

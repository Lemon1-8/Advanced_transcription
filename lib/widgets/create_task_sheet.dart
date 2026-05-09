import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';

class CreateTaskSheet extends StatefulWidget {
  final Task? existingTask;

  const CreateTaskSheet({super.key, this.existingTask});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _notesController;
  late String _folderId;
  late String _status;
  bool _saving = false;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _folderId = task?.folderId ?? '';
    _status = task?.status ?? 'todo';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final provider = context.read<AppProvider>();
    if (_isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: _titleController.text,
        description: _descController.text,
        folderId: _folderId,
        status: _status,
        notes: _notesController.text,
      );
      await provider.updateTask(updated);
    } else {
      await provider.addTask(
        title: _titleController.text,
        description: _descController.text,
        folderId: _folderId,
        status: _status,
        notes: _notesController.text,
      );
    }
    if (mounted) provider.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final folders = provider.folders;
    final currentFolderName =
        folders.where((f) => f.id == _folderId).firstOrNull?.name ?? '未分类';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? '编辑任务' : '新建任务',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '默认状态为未完成，创建日期由系统自动记录。',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          _buildLabel('任务标题'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '例如：完成毕业设计需求分析',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          _buildLabel('任务描述'),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '补充任务说明、完成要求或备注...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: '所属分类',
                  value: currentFolderName,
                  items: folders.map((f) => f.name).toList(),
                  onSelected: (name) {
                    final folder = folders.firstWhere((f) => f.name == name);
                    setState(() => _folderId = folder.id);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: '任务状态',
                  value: _statusLabel(_status),
                  items: const ['未完成', '已完成', '部分完成'],
                  onSelected: (label) {
                    setState(() => _status = _statusValue(label));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel('备注'),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: '可填写完成情况或其他说明',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => provider.closeOverlay(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: const Text('取消',
                      style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('保存任务',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5))),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onSelected(v);
              },
            ),
          ),
        ),
      ],
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
        return '未完成';
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
        return 'todo';
    }
  }
}

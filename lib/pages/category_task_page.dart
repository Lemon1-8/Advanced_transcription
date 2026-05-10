import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/task_card.dart';
import '../widgets/status_mark.dart';
import '../widgets/empty_state.dart';

class CategoryTaskPage extends StatefulWidget {
  const CategoryTaskPage({super.key});

  @override
  State<CategoryTaskPage> createState() => _CategoryTaskPageState();
}

class _CategoryTaskPageState extends State<CategoryTaskPage> {
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedIds.clear();
    _isSelecting = false;
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(List<String> ids) {
    setState(() {
      if (_selectedIds.length == ids.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(ids);
      }
    });
  }

  Future<void> _deleteSelected(AppProvider provider) async {
    if (_selectedIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('批量删除'),
        content: Text('确认删除已选的 ${_selectedIds.length} 个任务？\n删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await provider.deleteTasks(_selectedIds.toList());
      setState(() {
        _selectedIds.clear();
        _isSelecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final folderId = args?['folderId'] ?? '';
    final folderName = args?['folderName'] ?? '任务';

    final provider = context.watch<AppProvider>();
    final tasks = provider.getTasksByFolder(folderId);
    final taskIds = tasks.map((t) => t.id).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: folderName,
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSelecting = !_isSelecting;
                      if (!_isSelecting) _selectedIds.clear();
                    });
                  },
                  child: Text(
                    _isSelecting ? '取消' : '选择',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isSelecting
                          ? const Color(0xFF64748B)
                          : const Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const EmptyState(
                      icon: Icons.task_outlined,
                      message: '该分类下暂无任务',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final selected = _selectedIds.contains(task.id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: _isSelecting
                              ? _buildSelectableCard(task, selected)
                              : TaskCard(
                                  task: task,
                                  showFolder: false,
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(
                                    '/create-task',
                                    arguments: task.id,
                                  ),
                                  onLongPress: () {
                                    setState(() {
                                      _isSelecting = true;
                                      _selectedIds.add(task.id);
                                    });
                                  },
                                ),
                        );
                      },
                    ),
            ),
            if (_isSelecting) _buildBottomBar(tasks.length, taskIds),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableCard(Task task, bool selected) {
    return GestureDetector(
      onTap: () => _toggleSelect(task.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEEF2FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F46E5)
                : const Color(0xFFF1F5F9),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            StatusMark(status: task.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.displayTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? const Color(0xFF4F46E5)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(int totalCount, List<String> taskIds) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => _toggleSelectAll(taskIds),
            child: Text(
              _selectedIds.length == totalCount ? '取消全选' : '全选',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed:
                _selectedIds.isEmpty ? null : () => _deleteSelected(context.read<AppProvider>()),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('删除选中 (${_selectedIds.length})'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/task_history.dart';
import '../providers/app_provider.dart';
import '../utils/date_utils.dart' as du;

class TaskHistoryPage extends StatelessWidget {
  const TaskHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskId = ModalRoute.of(context)?.settings.arguments as String?;
    if (taskId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('历史记录')),
        body: const Center(child: Text('任务不存在')),
      );
    }

    final provider = context.watch<AppProvider>();
    final task = provider.getTaskById(taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('历史记录')),
        body: const Center(child: Text('任务已删除')),
      );
    }

    final history = task.history.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('历史记录'),
        foregroundColor: const Color(0xFFE8833A),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无修改记录',
                    style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = history[index];
                final isLatest = index == 0;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/task-history-detail',
                      arguments: {
                        'taskId': task.id,
                        'entryIndex': index,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _buildHistoryCard(context, entry, task, isLatest),
                );
              },
            ),
    );
  }

  Widget _buildHistoryCard(
      BuildContext context, TaskHistory entry, Task task, bool isLatest) {
    final time = _formatTime(entry.updatedAt);
    final date = _formatDate(entry.updatedAt);
    final provider = context.read<AppProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLatest
              ? const Color(0xFFE8833A).withValues(alpha: 0.3)
              : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLatest
                            ? const Color(0xFFE8833A).withValues(alpha: 0.1)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLatest
                              ? const Color(0xFFE8833A)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8833A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '最新',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                _buildChangedContent(entry, provider),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangedContent(TaskHistory entry, AppProvider provider) {
    final lines = <String>[];
    if (entry.title != null) lines.add('标题: ${entry.title}');
    if (entry.description != null) lines.add('描述: ${entry.description}');
    if (entry.folderId != null) {
      final folder = provider.getFolderById(entry.folderId!);
      lines.add('分类: ${folder?.name ?? entry.folderId}');
    }
    if (entry.status != null) lines.add('状态: ${_statusLabel(entry.status!)}');
    if (entry.notes != null) lines.add('备注: ${entry.notes}');
    if (entry.taskDate != null) {
      lines.add('执行日期: ${du.formatDate(entry.taskDate!)}');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
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

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return du.formatDateTime(dt);
    } catch (_) {
      return iso;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return du.formatDate(
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}');
    } catch (_) {
      return iso;
    }
  }
}

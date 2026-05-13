import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/task_history.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
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
    final time = du.formatIsoTime(entry.updatedAt);
    final date = du.formatIsoDate(entry.updatedAt);
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
    final lines = <Widget>[];
    _addLine(lines, entry.titleChangeType, '标题', entry.titleBefore, entry.titleAfter, (v) => v);
    _addLine(lines, entry.descriptionChangeType, '描述', entry.descriptionBefore, entry.descriptionAfter, (v) => v);
    if (entry.folderIdChangeType != null) {
      final beforeName = entry.folderIdBefore != null
          ? (provider.getFolderById(entry.folderIdBefore!)?.name ?? entry.folderIdBefore)
          : null;
      final afterName = entry.folderIdAfter != null
          ? (provider.getFolderById(entry.folderIdAfter!)?.name ?? entry.folderIdAfter)
          : null;
      _addLine(lines, entry.folderIdChangeType, '分类', beforeName, afterName, (v) => v ?? '');
    }
    if (entry.statusChangeType != null) {
      _addLine(lines, entry.statusChangeType, '状态',
          entry.statusBefore != null ? getStatusLabel(entry.statusBefore!) : null,
          entry.statusAfter != null ? getStatusLabel(entry.statusAfter!) : null,
          (v) => v ?? '');
    }
    _addLine(lines, entry.notesChangeType, '备注', entry.notesBefore, entry.notesAfter, (v) => v);
    if (entry.taskDateChangeType != null) {
      _addLine(lines, entry.taskDateChangeType, '执行日期',
          entry.taskDateBefore != null ? du.formatDate(entry.taskDateBefore!) : null,
          entry.taskDateAfter != null ? du.formatDate(entry.taskDateAfter!) : null,
          (v) => v ?? '');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }

  void _addLine(
      List<Widget> lines, FieldChangeType? changeType, String fieldName,
      String? before, String? after, String? Function(String?) fmt) {
    if (changeType == null) return;
    final text = switch (changeType) {
      FieldChangeType.added => '$fieldName: [新增] ${fmt(after) ?? ''}',
      FieldChangeType.modified =>
        '$fieldName: ${fmt(before) ?? ''} → ${fmt(after) ?? ''}',
      FieldChangeType.cleared => '$fieldName: [已清空] ${fmt(before) ?? ''}',
    };
    lines.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: changeType == FieldChangeType.added
                ? const Color(0xFF16A34A)
                : changeType == FieldChangeType.modified
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

}

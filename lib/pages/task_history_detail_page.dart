import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as du;

class TaskHistoryDetailPage extends StatelessWidget {
  const TaskHistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('版本详情')),
        body: const Center(child: Text('参数错误')),
      );
    }

    final taskId = args['taskId'] as String;
    final entryIndex = args['entryIndex'] as int;

    final provider = context.watch<AppProvider>();
    final task = provider.getTaskById(taskId);
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('版本详情')),
        body: const Center(child: Text('任务已删除')),
      );
    }

    final historyReversed = task.history.reversed.toList();
    if (entryIndex >= historyReversed.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('版本详情')),
        body: const Center(child: Text('记录不存在')),
      );
    }

    final entry = historyReversed[entryIndex];
    final isLatest = entryIndex == 0;
    final versionNumber = historyReversed.length - entryIndex;
    final totalVersions = historyReversed.length;

    // Reconstruct "before" values by walking through earlier history entries
    final beforeValues = <String, String?>{};
    for (int i = entryIndex + 1; i < historyReversed.length; i++) {
      final prev = historyReversed[i];
      beforeValues['title'] ??= prev.title;
      beforeValues['description'] ??= prev.description;
      beforeValues['folderId'] ??= prev.folderId;
      beforeValues['status'] ??= prev.status;
      beforeValues['notes'] ??= prev.notes;
      beforeValues['taskDate'] ??= prev.taskDate;
    }

    // Build field info list
    final fields = [
      _FieldInfo(
        label: '标题',
        icon: Icons.title,
        changed: entry.title != null,
        newValue: entry.title,
        oldValue: beforeValues['title'],
        fallbackValue: task.title,
      ),
      _FieldInfo(
        label: '描述',
        icon: Icons.description_outlined,
        changed: entry.description != null,
        newValue: entry.description,
        oldValue: beforeValues['description'],
        fallbackValue: task.description,
      ),
      _FieldInfo(
        label: '分类',
        icon: Icons.folder_outlined,
        changed: entry.folderId != null,
        newValue: entry.folderId != null
            ? _getFolderName(provider, entry.folderId!)
            : null,
        oldValue: beforeValues['folderId'] != null
            ? _getFolderName(provider, beforeValues['folderId']!)
            : null,
        fallbackValue: _getFolderName(provider, task.folderId),
      ),
      _FieldInfo(
        label: '状态',
        icon: Icons.check_circle_outline,
        changed: entry.status != null,
        newValue: entry.status != null ? getStatusLabel(entry.status!) : null,
        oldValue: beforeValues['status'] != null
            ? getStatusLabel(beforeValues['status']!)
            : null,
        fallbackValue: getStatusLabel(task.status),
      ),
      _FieldInfo(
        label: '执行日期',
        icon: Icons.calendar_today_outlined,
        changed: entry.taskDate != null,
        newValue: entry.taskDate != null
            ? du.formatDate(entry.taskDate!)
            : null,
        oldValue: beforeValues['taskDate'] != null
            ? du.formatDate(beforeValues['taskDate']!)
            : null,
        fallbackValue: du.formatDate(task.taskDate),
      ),
      _FieldInfo(
        label: '备注',
        icon: Icons.notes_outlined,
        changed: entry.notes != null,
        newValue: entry.notes,
        oldValue: beforeValues['notes'],
        fallbackValue: task.notes,
      ),
    ];

    final timeStr = '${_formatDate(entry.updatedAt)} ${_formatTime(entry.updatedAt)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('版本详情'),
        foregroundColor: const Color(0xFFE8833A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          children: [
            // Timestamp header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLatest
                          ? const Color(0xFFE8833A).withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.history,
                      size: 20,
                      color: isLatest
                          ? const Color(0xFFE8833A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '第 $versionNumber / $totalVersions 次修改',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLatest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8833A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '最新',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Field details
            ...fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildFieldCard(f),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldCard(_FieldInfo field) {
    final changed = field.changed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: changed
              ? const Color(0xFFFEF3C7)
              : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + label + badge
          Row(
            children: [
              Icon(field.icon, size: 16,
                  color: changed
                      ? const Color(0xFFD97706)
                      : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                field.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: changed
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  changed ? '已修改' : '未修改',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: changed
                        ? const Color(0xFFD97706)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          if (changed) ...[
            const SizedBox(height: 10),
            // Old value
            if (field.oldValue != null && field.oldValue!.isNotEmpty)
              _buildValueRow('修改前', field.oldValue!, const Color(0xFF94A3B8)),
            // New value
            _buildValueRow(
                '修改后', field.newValue!, const Color(0xFFE8833A)),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              field.fallbackValue?.isNotEmpty == true
                  ? field.fallbackValue!
                  : '（空）',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFolderName(AppProvider provider, String folderId) {
    final folder = provider.getFolderById(folderId);
    return folder?.name ?? '未分类';
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

class _FieldInfo {
  final String label;
  final IconData icon;
  final bool changed;
  final String? newValue;
  final String? oldValue;
  final String? fallbackValue;

  _FieldInfo({
    required this.label,
    required this.icon,
    required this.changed,
    this.newValue,
    this.oldValue,
    this.fallbackValue,
  });
}

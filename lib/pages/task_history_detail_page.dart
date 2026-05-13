import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_history.dart';
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

    // 单次遍历预计算所有字段在此时的历史值，"当时的值" = 更老条目中第一次修改该字段的 After 值
    String? histTitle, histDesc, histFolderId, histStatus, histTaskDate, histNotes;
    for (int i = entryIndex + 1; i < historyReversed.length; i++) {
      final h = historyReversed[i];
      histTitle ??= h.titleAfter;
      histDesc ??= h.descriptionAfter;
      histFolderId ??= h.folderIdAfter;
      histStatus ??= h.statusAfter;
      histTaskDate ??= h.taskDateAfter;
      histNotes ??= h.notesAfter;
    }
    // 若更老条目中都没有，取当前条目的 Before（即首次修改前的初始值）
    histTitle ??= entry.titleBefore;
    histDesc ??= entry.descriptionBefore;
    histFolderId ??= entry.folderIdBefore;
    histStatus ??= entry.statusBefore;
    histTaskDate ??= entry.taskDateBefore;
    histNotes ??= entry.notesBefore;

    String? folderName(String? id) {
      if (id == null) return null;
      return provider.getFolderById(id)?.name ?? '未分类';
    }

    final fields = [
      _FieldInfo(label: '标题', icon: Icons.title,
          changeType: entry.titleChangeType,
          beforeValue: entry.titleBefore, afterValue: entry.titleAfter,
          historicalValue: histTitle),
      _FieldInfo(label: '描述', icon: Icons.description_outlined,
          changeType: entry.descriptionChangeType,
          beforeValue: entry.descriptionBefore, afterValue: entry.descriptionAfter,
          historicalValue: histDesc),
      _FieldInfo(label: '分类', icon: Icons.folder_outlined,
          changeType: entry.folderIdChangeType,
          beforeValue: folderName(entry.folderIdBefore),
          afterValue: folderName(entry.folderIdAfter),
          historicalValue: folderName(histFolderId),
          formatValue: (v) => v ?? '未分类'),
      _FieldInfo(label: '状态', icon: Icons.check_circle_outline,
          changeType: entry.statusChangeType,
          beforeValue: entry.statusBefore != null ? getStatusLabel(entry.statusBefore!) : null,
          afterValue: entry.statusAfter != null ? getStatusLabel(entry.statusAfter!) : null,
          historicalValue: histStatus != null ? getStatusLabel(histStatus) : null),
      _FieldInfo(label: '执行日期', icon: Icons.calendar_today_outlined,
          changeType: entry.taskDateChangeType,
          beforeValue: entry.taskDateBefore != null ? du.formatDate(entry.taskDateBefore!) : null,
          afterValue: entry.taskDateAfter != null ? du.formatDate(entry.taskDateAfter!) : null,
          historicalValue: histTaskDate != null ? du.formatDate(histTaskDate) : null),
      _FieldInfo(label: '备注', icon: Icons.notes_outlined,
          changeType: entry.notesChangeType,
          beforeValue: entry.notesBefore, afterValue: entry.notesAfter,
          historicalValue: histNotes),
    ];

    final timeStr =
        '${du.formatIsoDate(entry.updatedAt)} ${du.formatIsoTime(entry.updatedAt)}';

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
    final changeType = field.changeType;
    final changed = changeType != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: changed ? _badgeBgColor(changeType) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(field.icon,
                  size: 16,
                  color: changed ? _badgeTextColor(changeType) : const Color(0xFF94A3B8)),
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
                  color: changed ? _badgeBgColor(changeType) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  changed ? _changeLabel(changeType) : '未修改',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: changed
                        ? _badgeTextColor(changeType)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          if (changed) ...[
            const SizedBox(height: 10),
            if (changeType == FieldChangeType.modified) ...[
              _buildValueRow('修改前', field.beforeValue ?? '', const Color(0xFF94A3B8)),
              _buildValueRow('修改后', field.afterValue ?? '', const Color(0xFFE8833A)),
            ] else if (changeType == FieldChangeType.added)
              _buildValueRow('新增内容', field.afterValue ?? '', const Color(0xFF16A34A)),
            if (changeType == FieldChangeType.cleared) ...[
              _buildValueRow('修改前', field.beforeValue ?? '', const Color(0xFF94A3B8)),
              _buildValueRow('结果', '（空）', const Color(0xFF94A3B8)),
            ],
          ] else ...[
            const SizedBox(height: 10),
            Text(
              (field.historicalValue ?? '').trim().isEmpty ? '（空）' : field.formatValue(field.historicalValue),
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

  Color _badgeBgColor(FieldChangeType type) => switch (type) {
        FieldChangeType.added => const Color(0xFFDCFCE7),
        FieldChangeType.modified => const Color(0xFFFEF3C7),
        FieldChangeType.cleared => const Color(0xFFF1F5F9),
      };

  Color _badgeTextColor(FieldChangeType type) => switch (type) {
        FieldChangeType.added => const Color(0xFF16A34A),
        FieldChangeType.modified => const Color(0xFFD97706),
        FieldChangeType.cleared => const Color(0xFF94A3B8),
      };

  String _changeLabel(FieldChangeType type) => switch (type) {
        FieldChangeType.added => '新增',
        FieldChangeType.modified => '已修改',
        FieldChangeType.cleared => '已清空',
      };
}

class _FieldInfo {
  final String label;
  final IconData icon;
  final FieldChangeType? changeType;
  final String? beforeValue;
  final String? afterValue;
  final String? historicalValue;
  final String Function(String?) formatValue;

  _FieldInfo({
    required this.label,
    required this.icon,
    required this.changeType,
    this.beforeValue,
    this.afterValue,
    this.historicalValue,
    this.formatValue = _defaultFormat,
  });

  static String _defaultFormat(String? v) => v ?? '';
}

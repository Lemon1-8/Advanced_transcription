import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/status_mark.dart';
import '../widgets/empty_state.dart';
import '../utils/date_utils.dart' as du;

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskId = ModalRoute.of(context)?.settings.arguments as String?;
    if (taskId == null) {
      return Scaffold(
        body: SafeArea(
          child: PageHeader(title: '任务详情'),
        ),
      );
    }

    final provider = context.watch<AppProvider>();
    final task = provider.getTaskById(taskId);

    if (task == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: '任务详情'),
              const EmptyState(
                icon: Icons.error_outline,
                message: '任务不存在',
                subMessage: '该任务可能已被删除',
              ),
            ],
          ),
        ),
      );
    }

    final folder = provider.getFolderById(task.folderId);
    final folderName = folder?.name ?? '未分类';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: '任务详情'),
              // Status and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => provider.toggleStatus(task.id),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: StatusMark(status: task.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.displayTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            folderName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Status badge
              _infoRow('任务状态', _statusLabel(task.status)),
              const SizedBox(height: 12),
              // Description
              if (task.description.isNotEmpty) ...[
                const _FieldLabel('任务描述'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Dates
              _infoRow('创建日期', du.formatDate(task.createdAt)),
              const SizedBox(height: 8),
              _infoRow('最后更新', _formatUpdated(task.updatedAt)),
              const SizedBox(height: 16),
              // Notes
              if (task.notes.isNotEmpty) ...[
                const _FieldLabel('备注'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    task.notes,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF92400E),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label：',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
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
        return value;
    }
  }

  String _formatUpdated(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return du.formatDateTime(dt);
    } catch (_) {
      return iso;
    }
  }

}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
      ),
    );
  }
}

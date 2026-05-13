import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_utils.dart' as du;

class ShareableTaskCard extends StatelessWidget {
  final Task task;
  final String folderName;
  final GlobalKey repaintKey;

  const ShareableTaskCard({
    super.key,
    required this.task,
    required this.folderName,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8E4DF), Color(0xFFF5F2ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: const Color(0xFF7A7268),
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  '任务记录',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A7268),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.displayTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C2416),
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5A5348),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2416).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _infoItem(Icons.folder_outlined, folderName),
                  _infoItem(Icons.flag_outlined, _statusLabel(task.status)),
                  _infoItem(
                      Icons.calendar_today_outlined, du.formatDate(task.taskDate)),
                ],
              ),
            ),
            if (task.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2416).withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '备注: ${task.notes}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B6358),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '创建于 ${du.formatDate(task.createdAt)}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFB0A898),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF8B8378)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF5A5348),
            fontWeight: FontWeight.w500,
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
}

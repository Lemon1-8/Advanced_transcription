import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';
import '../widgets/shareable_task_card.dart';
import 'share_utils.dart';

Future<void> showShareTaskDialog(
  BuildContext context, {
  required Task task,
  required String folderName,
}) async {
  final repaintKey = GlobalKey();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.share_outlined, size: 20, color: Color(0xFF6366F1)),
          SizedBox(width: 8),
          Text('分享任务', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: ShareableTaskCard(
          task: task,
          folderName: folderName,
          repaintKey: repaintKey,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(ctx).pop(true),
          icon: const Icon(Icons.share, size: 16),
          label: const Text('分享'),
        ),
      ],
    ),
  ).then((confirmed) async {
    if (confirmed != true) return;

    final bytes = await captureWidget(repaintKey);
    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片生成失败，请重试')),
        );
      }
      return;
    }

    final fileName =
        'task_${task.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.png';
    final tempFile = await saveToTemp(bytes, fileName);

    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: task.displayTitle,
    );

    if (!context.mounted) return;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('保存图片'),
        content: const Text('是否将分享的图片保存至本地？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('不需要'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await saveToDocuments(bytes, fileName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片已保存至本地')),
        );
      }
    }
  });
}

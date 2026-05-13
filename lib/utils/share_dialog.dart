import 'dart:typed_data';
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
  // 第一阶段：预览对话框（可滚动，避免长内容被裁剪）
  final confirmed = await showDialog<bool>(
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
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.55,
        ),
        child: SingleChildScrollView(
          child: ShareableTaskCard(
            task: task,
            folderName: folderName,
            repaintKey: GlobalKey(), // 预览阶段不需要抓取
          ),
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
  );

  if (confirmed != true || !context.mounted) return;

  // 第二阶段：用 OverlayEntry 渲染不受约束的完整卡片，实现长截屏效果
  final overlay = Overlay.of(context);
  final repaintKey = GlobalKey();

  final overlayEntry = OverlayEntry(
    builder: (_) => Center(
      child: SingleChildScrollView(
        child: ShareableTaskCard(
          task: task,
          folderName: folderName,
          repaintKey: repaintKey,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // 等待下一帧确保 overlay 完成布局和绘制
  await WidgetsBinding.instance.endOfFrame;
  await WidgetsBinding.instance.endOfFrame;

  Uint8List? bytes;
  try {
    bytes = await captureWidget(repaintKey);
  } finally {
    overlayEntry.remove();
  }

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
}

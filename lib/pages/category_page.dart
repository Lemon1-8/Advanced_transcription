import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/folder.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../utils/constants.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  static Future<void> _deleteFolder(
      BuildContext context, AppProvider provider, Folder folder, int count) async {
    if (count > 0) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('无法删除'),
          content: Text('该文件夹下有 $count 个任务，请先删除任务后再删除文件夹。'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('去处理'),
            ),
          ],
        ),
      );
      if (go == true && context.mounted) {
        Navigator.of(context).pushNamed(
          '/category-tasks',
          arguments: {
            'folderId': folder.id,
            'folderName': folder.name,
          },
        );
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('删除文件夹'),
          content: Text('确认删除"${folder.name}"？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        await provider.deleteFolder(folder.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final folders = provider.folders;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: '分类',
              desc: '用户可自行新建文件夹分类',
              showBack: false,
            ),
            Expanded(
              child: folders.isEmpty
                  ? const EmptyState(
                      icon: Icons.folder_outlined,
                      message: '暂无分类',
                      subMessage: '点击右下角 + 创建新文件夹',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        final count =
                            provider.getTaskCountByFolder(folder.id);
                        final isDefault = folder.id == defaultFolderId;
                        return _buildFolderCard(
                          context,
                          folder.name,
                          folder.description,
                          count,
                          isDefault,
                          () => Navigator.of(context).pushNamed(
                            '/category-tasks',
                            arguments: {
                              'folderId': folder.id,
                              'folderName': folder.name,
                            },
                          ),
                          onDelete: isDefault
                              ? null
                              : () => _deleteFolder(context, provider, folder, count),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard(
    BuildContext context,
    String name,
    String desc,
    int count,
    bool isDefault,
    VoidCallback onTap, {
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.folder_outlined,
                  color: Color(0xFF4F46E5), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (desc.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Text(
                  '个任务',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

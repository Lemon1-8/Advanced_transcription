import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../utils/constants.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

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
    VoidCallback onTap,
  ) {
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
          ],
        ),
      ),
    );
  }
}

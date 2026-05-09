import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';

class CategoryTaskPage extends StatelessWidget {
  const CategoryTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, String>?;
    final folderId = args?['folderId'] ?? '';
    final folderName = args?['folderName'] ?? '任务';

    final provider = context.watch<AppProvider>();
    final tasks = provider.getTasksByFolder(folderId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: folderName),
            Expanded(
              child: tasks.isEmpty
                  ? const EmptyState(
                      icon: Icons.task_outlined,
                      message: '该分类下暂无任务',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: tasks[index],
                          showFolder: false,
                          onTap: () => Navigator.of(context).pushNamed(
                            '/task-detail',
                            arguments: tasks[index].id,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

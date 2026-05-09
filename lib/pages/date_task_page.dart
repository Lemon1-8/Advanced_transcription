import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import '../utils/date_utils.dart' as du;

class DateTaskPage extends StatelessWidget {
  const DateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, String>?;
    final groupKey = args?['groupKey'] ?? '';

    final provider = context.watch<AppProvider>();
    final tasks = _getTasks(provider, groupKey);

    String title;
    if (groupKey == 'today') {
      title = '今天';
    } else if (groupKey == 'yesterday') {
      title = '昨天';
    } else {
      title = du.formatMonth(groupKey);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: title),
            Expanded(
              child: tasks.isEmpty
                  ? const EmptyState(
                      icon: Icons.date_range_outlined,
                      message: '该时间段暂无任务',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: tasks[index],
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

  List _getTasks(AppProvider provider, String key) {
    if (key == 'today') {
      return provider.todayTasks;
    } else if (key == 'yesterday') {
      final yesterday = du.yesterdayStr();
      return provider.getTasksByDate(yesterday);
    } else {
      return provider.getTasksByMonth(key);
    }
  }
}

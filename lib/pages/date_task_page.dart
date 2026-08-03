import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import '../utils/date_utils.dart' as du;
import '../models/task.dart';

class DateTaskPage extends StatelessWidget {
  const DateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, String>?;
    final groupKey = args?['groupKey'] ?? '';
    final groupLabel = args?['groupLabel'];

    final provider = context.watch<AppProvider>();
    final title = groupLabel ?? _titleForKey(groupKey);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: title),
            Expanded(
              child: _buildContent(context, provider, groupKey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppProvider provider,
    String groupKey,
  ) {
    if (groupKey.startsWith('year:')) {
      return _buildGroupList(
        context,
        provider.getMonthGroupsForDateGroupKey(groupKey),
        '该年份暂无任务',
      );
    }

    if (groupKey == 'week:this' ||
        groupKey == 'week:last' ||
        groupKey.startsWith('bucket-month:') ||
        groupKey.startsWith('month:')) {
      return _buildGroupList(
        context,
        provider.getDayGroupsForDateGroupKey(groupKey),
        '该时间段暂无任务',
      );
    }

    return _buildTaskList(context, _getTasks(provider, groupKey));
  }

  Widget _buildGroupList(
    BuildContext context,
    List<DateGroup> groups,
    String emptyMessage,
  ) {
    if (groups.isEmpty) {
      return EmptyState(
        icon: Icons.date_range_outlined,
        message: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildDateGroup(
          group.label,
          group.key,
          group.totalCount,
          group.doneCount,
          () {
            Navigator.of(context).pushNamed(
              '/date-tasks',
              arguments: {
                'groupKey': group.key,
                'groupLabel': group.label,
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.date_range_outlined,
        message: '该时间段暂无任务',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TaskCard(
          task: tasks[index],
          onTap: () => Navigator.of(context).pushNamed(
            '/create-task',
            arguments: tasks[index].id,
          ),
        ),
      ),
    );
  }

  Widget _buildDateGroup(
    String label,
    String key,
    int total,
    int done,
    VoidCallback onTap,
  ) {
    final rate = total > 0 ? done / total : 0.0;
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (du.getDateGroupSubLabel(key).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            du.getDateGroupSubLabel(key),
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
                      '$total 个任务',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '完成 $done 个',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rate,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleForKey(String key) {
    if (key == 'today') return '今天';
    if (key == 'yesterday') return '昨天';
    if (key == 'tomorrow') return '明天';
    if (key.isEmpty) return '日期记录';
    return du.getDateGroupTitle(key);
  }

  List<Task> _getTasks(AppProvider provider, String key) {
    if (key == 'today') {
      return provider.todayTasks;
    } else if (key == 'yesterday') {
      final yesterday = du.yesterdayStr();
      return provider.getTasksByDate(yesterday);
    } else if (key == 'tomorrow') {
      final tomorrow = du.tomorrowStr();
      return provider.getTasksByDate(tomorrow);
    } else {
      return provider.getTasksByDateGroupKey(key);
    }
  }
}

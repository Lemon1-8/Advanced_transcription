import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../utils/date_utils.dart' as du;

class DatePage extends StatelessWidget {
  const DatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final groups = provider.dateGroups;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: '日期记录',
              desc: '系统自动按任务日期归档',
              showBack: false,
            ),
            Expanded(
              child: groups.isEmpty
                  ? const EmptyState(
                      icon: Icons.date_range_outlined,
                      message: '暂无日期记录',
                      subMessage: '创建新任务后会自动按日期归档',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    ),
            ),
          ],
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final todayTasks = provider.todayTasks;
    final todayTotal = provider.todayTotal;
    final todayDone = provider.todayDone;
    final todayTodo = provider.todayTodo;
    final todayPartial = provider.todayPartial;
    final rate = provider.todayCompletionRate;
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 16),
          _buildStatsCard(now, todayTotal, todayDone, todayTodo, todayPartial, rate),
          const SizedBox(height: 20),
          SectionTitle(
            title: '今日任务',
            desc: '点击左侧状态可切换：□ → √ → √\u{0336}',
            actionLabel: '全部',
          ),
          const SizedBox(height: 12),
          if (todayTasks.isEmpty)
            const EmptyState(
              icon: Icons.today_outlined,
              message: '今天还没有任务',
              subMessage: '点击右下角 + 创建新任务',
            )
          else
            ...todayTasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskCard(
                    task: task,
                    showDate: false,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/task-detail',
                        arguments: task.id,
                      );
                    },
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/search'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
              SizedBox(width: 8),
              Text(
                '搜索任务标题、描述、备注',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    DateTime now,
    int total,
    int done,
    int todo,
    int partial,
    double rate,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日任务信息',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '今天 · ${now.month}月${now.day}日',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '共 $total 个任务，已完成 $done 个',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${(rate * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '完成率',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statItem(done.toString(), '已完成'),
              _statItem(todo.toString(), '未完成'),
              _statItem(partial.toString(), '部分完成'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

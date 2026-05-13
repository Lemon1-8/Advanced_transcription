import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _searchExpanded = false;
  late TextEditingController _keywordController;
  int _lastTabVersion = 0;

  late PageController _statsPageController;
  late Timer _statsTimer;
  int _statsPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
    _lastTabVersion = context.read<AppProvider>().tabTapVersion;
    _statsPageController = PageController(initialPage: 0);
    _statsTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_statsPageController.hasClients && mounted) {
        final next = _statsPageIndex == 0 ? 1 : 0;
        _statsPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _statsTimer.cancel();
    _statsPageController.dispose();
    super.dispose();
  }

  void _openSearch() {
    _lastTabVersion = context.read<AppProvider>().tabTapVersion;
    setState(() => _searchExpanded = true);
  }

  void _closeSearch(AppProvider provider) {
    _keywordController.clear();
    provider.setQueryKeyword('');
    provider.setQueryCategory('');
    provider.setQueryStatus('');
    provider.setQueryDate('');
    provider.search();
    setState(() => _searchExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // 重新点击底部首页 tab 时收起搜索
    if (_searchExpanded && provider.tabTapVersion > _lastTabVersion) {
      _lastTabVersion = provider.tabTapVersion;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _keywordController.clear();
          provider.setQueryKeyword('');
          provider.setQueryCategory('');
          provider.setQueryStatus('');
          provider.setQueryDate('');
          provider.search();
          setState(() => _searchExpanded = false);
        }
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          children: [
            if (_searchExpanded)
              _buildExpandedSearch(provider)
            else ...[
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildStatsCard(provider),
              const SizedBox(height: 20),
              SectionTitle(
                title: '今日任务',
                desc: '点击左侧状态可切换：□ → √ → √̶',
                actionLabel: '全部',
              ),
              const SizedBox(height: 12),
              if (provider.todayTasks.isEmpty)
                const EmptyState(
                  icon: Icons.today_outlined,
                  message: '今天还没有任务',
                  subMessage: '点击右下角 + 创建新任务',
                )
              else
                ...provider.todayTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskCard(
                        task: task,
                        showDate: false,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/create-task',
                            arguments: task.id,
                          );
                        },
                      ),
                    )),
            ],
            if (_searchExpanded) ...[
              const SizedBox(height: 20),
              _buildResults(provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openSearch,
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

  Widget _buildExpandedSearch(AppProvider provider) {
    final folders = provider.folders;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('搜索',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              const Spacer(),
              GestureDetector(
                onTap: () => _closeSearch(provider),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Keyword input
          TextField(
            controller: _keywordController,
            decoration: InputDecoration(
              hintText: '搜索任务标题、描述、备注',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon:
                  const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) {
              provider.setQueryKeyword(v);
              provider.search();
            },
          ),
          const SizedBox(height: 12),
          // Filters in one row
          Row(
            children: [
              Expanded(
                child: _buildInlineDropdown(
                  value: provider.queryCategory.isEmpty
                      ? '全部分类'
                      : (folders
                              .where((f) => f.id == provider.queryCategory)
                              .firstOrNull
                              ?.name ??
                          '全部分类'),
                  items: ['全部分类', ...folders.map((f) => f.name)],
                  onChanged: (v) {
                    if (v == '全部分类') {
                      provider.setQueryCategory('');
                    } else {
                      final folder = folders.firstWhere((f) => f.name == v);
                      provider.setQueryCategory(folder.id);
                    }
                    provider.search();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildInlineDropdown(
                  value: provider.queryStatus.isEmpty
                      ? '全部状态'
                      : _statusLabel(provider.queryStatus),
                  items: const ['全部状态', '未完成', '已完成', '部分完成'],
                  onChanged: (v) {
                    provider.setQueryStatus(
                        v == '全部状态' ? '' : _statusValue(v));
                    provider.search();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildInlineDropdown(
                  value: provider.queryDate.isEmpty
                      ? '全部时间'
                      : provider.queryDate,
                  items: const [
                    '全部时间',
                    '今天',
                    '昨天',
                    '近7天',
                    '本周',
                    '本月'
                  ],
                  onChanged: (v) {
                    provider.setQueryDate(v == '全部时间' ? '' : v);
                    provider.search();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          isDense: true,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4F46E5),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F46E5),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildResults(AppProvider provider) {
    final results = provider.queryResults;

    if (!_searchExpanded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (results.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '查询结果：共 ${results.length} 条',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        if (results.isEmpty)
          const EmptyState(
            icon: Icons.search_off,
            message: '未找到匹配的任务',
          )
        else
          ...results.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskCard(
                  task: task,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/create-task',
                      arguments: task.id,
                    );
                  },
                ),
              )),
      ],
    );
  }

  Widget _buildStatsCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF2E6).withValues(alpha: 0.75),
            const Color(0xFFFFE4CC).withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8833A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _smallSegment('今日', 0),
              _smallSegment('昨日', 1),
            ],
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 62,
            child: PageView(
              controller: _statsPageController,
              onPageChanged: (i) => setState(() => _statsPageIndex = i),
              children: [
                _buildCardContent(
                  total: provider.todayTotal,
                  done: provider.todayDone,
                  todo: provider.todayTodo,
                  partial: provider.todayPartial,
                  rate: provider.todayCompletionRate,
                ),
                _buildCardContent(
                  total: provider.yesterdayTotal,
                  done: provider.yesterdayDone,
                  todo: provider.yesterdayTodo,
                  partial: provider.yesterdayPartial,
                  rate: provider.yesterdayCompletionRate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallSegment(String label, int pageIndex) {
    final active = _statsPageIndex == pageIndex;
    return GestureDetector(
      onTap: () {
        _statsPageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFE8833A).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFFE8833A) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent({
    required int total,
    required int done,
    required int todo,
    required int partial,
    required double rate,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: rate == 0 ? 0.001 : rate,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: const Color(0xFFE8833A),
                  backgroundColor:
                      const Color(0xFFE8833A).withValues(alpha: 0.1),
                ),
              ),
              Text(
                '${(rate * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE8833A),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$total 个任务，$done 已完成',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C2D12),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _miniStat('$todo', '未完成', const Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  _miniStat('$partial', '部分', const Color(0xFFD97706)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

  String _statusValue(String label) {
    switch (label) {
      case '未完成':
        return 'todo';
      case '已完成':
        return 'done';
      case '部分完成':
        return 'partial';
      default:
        return '';
    }
  }
}

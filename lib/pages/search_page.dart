import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/filter_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _keywordController;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final results = provider.queryResults;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: '查询任务', showBack: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Keyword input
                  TextField(
                    controller: _keywordController,
                    decoration: InputDecoration(
                      hintText: '搜索任务标题、描述、备注',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) => provider.setQueryKeyword(v),
                  ),
                  const SizedBox(height: 12),
                  // Filters
                  FilterBar(
                    selectedCategory: provider.queryCategory,
                    selectedStatus: provider.queryStatus,
                    selectedDate: provider.queryDate,
                    categories: provider.folders
                        .map((f) => {'id': f.id, 'name': f.name})
                        .toList(),
                    onCategoryChanged: (v) => provider.setQueryCategory(v),
                    onStatusChanged: (v) => provider.setQueryStatus(v),
                    onDateChanged: (v) => provider.setQueryDate(v),
                  ),
                  const SizedBox(height: 16),
                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _hasSearched = true);
                        provider.search();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '搜索',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Results
            Expanded(
              child: _hasSearched
                  ? (results.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off,
                          message: '未找到匹配的任务',
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                '查询结果：共 ${results.length} 条',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: results.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TaskCard(
                                    task: results[index],
                                    onTap: () =>
                                        Navigator.of(context).pushNamed(
                                      '/task-detail',
                                      arguments: results[index].id,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                  : const EmptyState(
                      icon: Icons.search,
                      message: '输入关键词或选择筛选条件',
                      subMessage: '点击搜索查看结果',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'pages/home_page.dart';
import 'pages/category_page.dart';
import 'pages/category_task_page.dart';
import 'pages/date_page.dart';
import 'pages/date_task_page.dart';
import 'pages/search_page.dart';
import 'pages/stats_page.dart';
import 'pages/setting_page.dart';
import 'pages/task_detail_page.dart';
import 'pages/task_history_page.dart';
import 'pages/task_history_detail_page.dart';
import 'pages/create_task_page.dart';
import 'widgets/create_folder_sheet.dart';
import 'utils/constants.dart';
import 'utils/intent_handler.dart';

class App extends StatelessWidget {
  final String? pendingImportPath;

  const App({super.key, this.pendingImportPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: ImportHandler(
        pendingPath: pendingImportPath,
        child: const MainShell(),
      ),
      routes: {
        '/search': (_) => const SearchPage(),
        '/task-detail': (_) => const TaskDetailPage(),
        '/create-task': (_) => const CreateTaskPage(),
        '/task-history': (_) => const TaskHistoryPage(),
        '/task-history-detail': (_) => const TaskHistoryDetailPage(),
        '/category-tasks': (_) => const CategoryTaskPage(),
        '/date-tasks': (_) => const DateTaskPage(),
      },
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF4F46E5);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final pages = const [
      HomePage(),
      CategoryPage(),
      DatePage(),
      StatsPage(),
      SettingPage(),
    ];

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: provider.currentTab,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: provider.currentTab,
              onTap: (index) => provider.navigateToTab(index),
              items: navItems.map((item) {
                return BottomNavigationBarItem(
                  icon: _navIcon(item['key']!),
                  activeIcon: _navIcon(item['key']!, active: true),
                  label: item['label'],
                );
              }).toList(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/create-task'),
            backgroundColor: const Color(0xFF4F46E5),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
        // Overlay
        if (provider.overlayType != null) _buildOverlay(context, provider),
      ],
    );
  }

  Widget _navIcon(String key, {bool active = false}) {
    final iconMap = {
      'home': Icons.home_outlined,
      'category': Icons.folder_outlined,
      'date': Icons.date_range_outlined,
      'stats': Icons.bar_chart_outlined,
      'setting': Icons.settings_outlined,
    };
    final activeIconMap = {
      'home': Icons.home,
      'category': Icons.folder,
      'date': Icons.date_range,
      'stats': Icons.bar_chart,
      'setting': Icons.settings,
    };
    return Icon(
      active ? (activeIconMap[key] ?? iconMap[key]) : iconMap[key],
      size: 22,
    );
  }

  Widget _buildOverlay(BuildContext context, AppProvider provider) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => provider.closeOverlay(),
          child: Container(color: Colors.black38),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SingleChildScrollView(
                  child: const CreateFolderSheet(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 处理从外部打开文件的导入流程
class ImportHandler extends StatefulWidget {
  final String? pendingPath;
  final Widget child;

  const ImportHandler({super.key, this.pendingPath, required this.child});

  @override
  State<ImportHandler> createState() => _ImportHandlerState();
}

class _ImportHandlerState extends State<ImportHandler> {
  bool _handledInitial = false;

  @override
  void initState() {
    super.initState();
    FileIntentHandler.listenForFiles(_onFileReceived);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledInitial) {
      _handledInitial = true;
      if (widget.pendingPath != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _doImport(widget.pendingPath!);
        });
      }
      // 无论是否有导入，都检查是否需要显示每日提示
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkTipAfterInit();
      });
    }
  }

  void _onFileReceived(String path) {
    if (!mounted) return;
    _doImport(path);
  }

  Future<void> _doImport(String path) async {
    if (!mounted) return;

    // 等待 provider 初始化完成
    final provider = context.read<AppProvider>();
    if (!provider.initialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      if (!provider.initialized) return;
    }

    final content = await FileIntentHandler.readFileContent(path);
    if (!mounted) return;

    // 验证是否为有效的数据文件
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map || (decoded['data'] as Map?)?.isEmpty == true) {
        _showMessage('导入失败：文件格式不正确');
        await FileIntentHandler.cleanupFile(path);
        return;
      }
    } catch (_) {
      _showMessage('导入失败：文件不是有效的 JSON');
      await FileIntentHandler.cleanupFile(path);
      return;
    }

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('导入数据'),
        content: const Text('检测到外部数据文件，导入将覆盖当前所有数据，此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认导入'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      final success = await provider.importFromJsonString(content);
      _showMessage(success ? '数据导入成功' : '导入失败：数据格式有误');
    }

    await FileIntentHandler.cleanupFile(path);
  }

  void _checkTipAfterInit() {
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    if (provider.initialized && provider.shouldShowTip) {
      _showTipDialog(provider);
    } else if (!provider.initialized) {
      // 还没初始化完，等一会儿再试
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _checkTipAfterInit();
      });
    }
  }

  Future<void> _showTipDialog(AppProvider provider) async {
    if (!mounted) return;
    await showDialog<void>(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline,
                color: Color(0xFFE8833A), size: 24),
            SizedBox(width: 8),
            Text('欢迎使用 你的强',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _TipSection(
                icon: Icons.info_outline,
                title: '注意事项',
                items: [
                  '所有数据仅保存在本机，卸载 App 后数据会丢失',
                  '建议定期导出数据进行备份',
                  '删除的任务无法恢复，请谨慎操作',
                ],
              ),
              SizedBox(height: 16),
              _TipSection(
                icon: Icons.auto_awesome,
                title: 'App 亮点',
                items: [
                  '本地保存，无需登录，保护隐私',
                  '自由创建分类，灵活管理任务',
                  '三态状态切换：未完成 ✓ 已完成 ✓̶ 部分完成',
                  '支持数据导出分享，跨设备迁移',
                  '任务以图片形式分享，信息一目了然',
                ],
              ),
              SizedBox(height: 16),
              _TipSection(
                icon: Icons.tips_and_updates,
                title: '使用技巧',
                items: [
                  '长按任务卡片可批量选择删除',
                  '点击任务左侧状态图标快速切换状态',
                  '在分类页右滑或点击删除按钮管理文件夹',
                  '通过微信分享 .json 文件可在本 App 直接打开导入',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.dismissTip('daily');
              Navigator.of(ctx).pop();
            },
            child: const Text('我知道了'),
          ),
          TextButton(
            onPressed: () {
              provider.dismissTip('weekly');
              Navigator.of(ctx).pop();
            },
            child: const Text('一周内不再弹出'),
          ),
          TextButton(
            onPressed: () {
              provider.dismissTip('forever');
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('永远不再弹出'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _TipSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _TipSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFE8833A)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3728),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ',
                      style: TextStyle(color: Color(0xFFE8833A))),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

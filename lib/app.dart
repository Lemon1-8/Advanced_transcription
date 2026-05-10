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
import 'pages/create_task_page.dart';
import 'widgets/create_folder_sheet.dart';
import 'utils/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const MainShell(),
      routes: {
        '/search': (_) => const SearchPage(),
        '/task-detail': (_) => const TaskDetailPage(),
        '/create-task': (_) => const CreateTaskPage(),
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

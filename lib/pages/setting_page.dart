import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/settings_row.dart';
import '../widgets/info_tile.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('清空全部数据？'),
        content: const Text('此操作无法撤销。\n所有任务和分类数据将被清除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().clearAllData();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('所有数据已清空')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final settings = provider.settings;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: '设置',
                desc: '第一版保持简单，不加入账号系统',
                showBack: false,
              ),
              const SizedBox(height: 8),
              // Storage info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.storage_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '仅本机保存',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '卸载 App 后数据可能被清除',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Settings list
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    SettingsRow(
                      label: '默认首页',
                      value: '今日任务',
                    ),
                    SettingsRow(
                      label: '任务排序',
                      value: settings.sortOrder == 'createdAt'
                          ? '创建时间'
                          : '完成状态',
                      onTap: () => _showSortPicker(context, settings),
                    ),
                    SettingsRow(
                      label: '删除确认',
                      value: settings.deleteConfirm ? '开启' : '关闭',
                      onTap: () {
                        final updated = AppSettings(
                          sortOrder: settings.sortOrder,
                          deleteConfirm: !settings.deleteConfirm,
                        );
                        provider.updateSettings(updated);
                      },
                    ),
                    SettingsRow(
                      label: '清空全部数据',
                      value: '谨慎操作',
                      danger: true,
                      onTap: () => _confirmClearAll(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Info tiles
              Row(
                children: [
                  const Expanded(
                      child: InfoTile(
                          icon: Icons.smartphone_outlined,
                          label: '无需登录')),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: InfoTile(
                          icon: Icons.notifications_off_outlined,
                          label: '无提醒')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoTile(
                      icon: Icons.verified_outlined,
                      label: '本地数据',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  dataStorageHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortPicker(BuildContext context, AppSettings current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '任务排序',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
            ),
            ...List.generate(sortOptions.length, (i) {
              return ListTile(
                title: Text(sortLabels[i]),
                trailing: current.sortOrder == sortOptions[i]
                    ? const Icon(Icons.check, color: Color(0xFF4F46E5))
                    : null,
                onTap: () {
                  context.read<AppProvider>().updateSettings(
                        AppSettings(
                          sortOrder: sortOptions[i],
                          deleteConfirm: current.deleteConfirm,
                        ),
                      );
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

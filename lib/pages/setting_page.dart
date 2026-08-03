import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = context.read<AppProvider>();
      final jsonStr = provider.exportToJsonString();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/任务记录器_备份_$timestamp.json');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '任务记录器数据备份',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
  }

  Future<void> _showImportPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
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
                '导入数据',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('从 JSON 文件恢复'),
              subtitle: const Text('选择手机中的备份文件'),
              onTap: () {
                Navigator.of(ctx).pop();
                _importFromJsonFile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('从微信中恢复'),
              subtitle: const Text('从微信聊天中的备份文件打开本 App'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showWechatImportGuide(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showWechatImportGuide(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('从微信中恢复'),
        content: const Text(
          '请在微信聊天中找到备份 JSON 文件，点击文件后选择“用其他应用打开”，再选择“任务记录器”。\n\n如果文件已保存到手机，也可以直接选择本地 JSON 文件恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('我知道了'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _importFromJsonFile(context);
            },
            child: const Text('选择 JSON 文件'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromJsonFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.first.path;
      if (filePath == null) return;

      final file = File(filePath);
      final jsonStr = await file.readAsString();

      // Validate JSON before confirmation
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is! Map || (decoded['data'] as Map?)?.isEmpty == true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('导入失败：文件格式不正确')),
            );
          }
          return;
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('导入失败：文件不是有效的 JSON')),
          );
        }
        return;
      }

      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('导入数据？'),
          content: const Text('导入将覆盖当前所有数据，此操作无法撤销。'),
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

      if (confirmed != true) return;
      if (!context.mounted) return;

      final provider = context.read<AppProvider>();
      final success = await provider.importFromJsonString(jsonStr);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '数据导入成功' : '导入失败：数据格式有误'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败：$e')),
        );
      }
    }
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
                      value: _tabLabel(settings.defaultTab),
                      onTap: () => _showDefaultTabPicker(context, settings),
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
                          defaultTab: settings.defaultTab,
                          tipMode: settings.tipMode,
                          lastTipDate: settings.lastTipDate,
                        );
                        provider.updateSettings(updated);
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    SettingsRow(
                      label: '导出数据',
                      value: '分享 JSON 文件',
                      onTap: () => _exportData(context),
                    ),
                    SettingsRow(
                      label: '导入数据',
                      value: 'JSON 文件 / 微信',
                      onTap: () => _showImportPicker(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
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

  String _tabLabel(int index) {
    const labels = ['首页', '分类', '日期', '统计', '设置'];
    return index >= 0 && index < labels.length ? labels[index] : '首页';
  }

  void _showDefaultTabPicker(BuildContext context, AppSettings current) {
    const tabs = ['首页', '分类', '日期', '统计', '设置'];
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
                '默认首页',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
            ),
            ...List.generate(tabs.length, (i) {
              return ListTile(
                title: Text(tabs[i]),
                trailing: current.defaultTab == i
                    ? const Icon(Icons.check, color: Color(0xFF4F46E5))
                    : null,
                onTap: () {
                  context.read<AppProvider>().updateSettings(
                        AppSettings(
                          sortOrder: current.sortOrder,
                          deleteConfirm: current.deleteConfirm,
                          defaultTab: i,
                          tipMode: current.tipMode,
                          lastTipDate: current.lastTipDate,
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
                          defaultTab: current.defaultTab,
                          tipMode: current.tipMode,
                          lastTipDate: current.lastTipDate,
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

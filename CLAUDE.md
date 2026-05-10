# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Flutter 本地 Todo 应用，采用 **Provider + Hive** 架构。所有数据仅保存在本机，无需登录。

## 技术栈

- Flutter + Dart (SDK ^3.11.5)
- Provider 6.x（状态管理）
- Hive 2.x（本地持久化，JSON 序列化）
- uuid（任务/文件夹 ID 生成）
- intl（日期格式化）
- share_plus + file_picker + path_provider（数据导出/导入）

## 常用命令

```bash
flutter pub get                 # 安装依赖（如 PUB_CACHE 跨盘失败，检查环境变量）
flutter run                     # 运行
flutter build apk --target-platform android-arm64  # 构建 APK
flutter analyze                 # 代码分析
```

**注意：** Windows 环境下 `PUB_CACHE` 必须设为 `D:\.pub-cache`（含反斜杠），否则会被当作相对路径导致 `flutter pub get` 失败。

## 架构核心模式

### 数据流

```
用户操作 → Provider 方法 → 修改内存数据 → _saveXxx() 写 Hive → notifyListeners() 刷新 UI
```

- 所有状态集中在 `AppProvider`（ChangeNotifier）
- 页面通过 `context.watch<AppProvider>()` 监听，`context.read<AppProvider>()` 触发事件
- Hive 的三个 box（`tasks` / `folders` / `settings`）均以单 key `'data'` 存取 JSON

### 导航

- 底部 5 Tab（首页/分类/日期/统计/设置），通过 `IndexedStack` 保持页面状态
- 普通页面使用命名路由，路由参数通过 `ModalRoute.of(context)?.settings.arguments` 接收
- Tab 重新点击触发 `_tabTapVersion++`，`HomePage` 据此收起搜索

### 任务三态循环

```
todo → done → partial → todo （getNextStatus()）
```

- 点击任务卡片的 StatusMark 触发 `toggleStatus()`
- 状态字符串 'todo' / 'done' / 'partial' 映射到 '未完成' / '已完成' / '部分完成'

### 编辑保存流程（含历史记录）

```
CreateTaskPage._save()
  → 逐字段对比旧值，收集有变化的字段
  → 如有变化，构造 TaskHistory 实例记录变更的字段值（仅保留有变的字段）
  → task.history.add(historyEntry)
  → provider.updateTask(task)  // 更新内存 + 写 Hive
```

- 编辑页用 `PopScope` 拦截返回，自动保存
- 没有字段变化时不新增历史记录
- `TaskHistory.updatedAt` 使用 ISO datetime，`changedFields` 仅显示非 null 字段

### 微信导入（Android Intent）

```
外部 .json 文件 → AndroidManifest ACTION_VIEW → MainActivity.kt MethodChannel
→ FileIntentHandler → ImportHandler → showDialog 确认 → provider.importFromJsonString()
```

## 项目结构要点

```
lib/
├── main.dart                   # 入口：初始化 Hive、检查 intent 文件、挂载 Provider
├── app.dart                    # MaterialApp + MainShell + ImportHandler
├── models/
│   ├── task.dart               # Task（copyWith / toJson / fromJson / displayTitle）
│   ├── task_history.dart       # 修改历史（仅记录有变的字段，null = 未变更）
│   ├── folder.dart             # Folder
│   └── app_settings.dart       # AppSettings（排序方式/删除确认/默认首页/提示设置）
├── providers/
│   └── app_provider.dart       # 全局状态：CRUD + 搜索/筛选 + 统计 + 导入导出 + 提示控制
├── pages/                      # 每个页面一个文件，通过命名路由跳转
├── widgets/                    # UI 组件
└── utils/
    ├── constants.dart          # 常量、状态映射、getNextStatus()
    ├── date_utils.dart         # 日期判定和格式化
    └── intent_handler.dart     # Android intent 文件接收
```

## 常见开发场景

### 添加新的任务字段

1. 在 `Task` 模型添加字段 + `copyWith` / `toJson` / `fromJson`
2. 在 `TaskHistory` 添加对应字段（用于记录变更）
3. 在 `CreateTaskPage._save()` 中添加对比逻辑
4. 在 `TaskHistoryDetailPage` 展示该字段
5. 旧数据兼容：`fromJson` 中为新字段提供默认值

### 添加新页面

1. 在 `app.dart` 的 `routes` 中注册命名路由
2. 通过 `provider` 获取数据，使用 `context.watch` 监听变化

### 修改排序/筛选

- 排序：修改 `sortOptions`（constants.dart）和 `AppProvider` 中对应的排序逻辑
- 日期筛选：在 `_filterByDate()` 中添加新的 case

## 注意事项

- 默认分类（`default_uncategorized` / "未分类"）不可删除
- `.pub-cache/` 已加入 `.gitignore`，请勿提交
- 无测试文件，验证方式为 `flutter analyze` + 模拟器手动测试
- 当前仅 Android 端注册了 intent filter，iOS 未处理文件打开

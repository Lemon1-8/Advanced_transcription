# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Flutter 本地任务管理应用"你的强"，采用 **Provider + Hive** 架构。所有数据仅保存在本机，无需登录。核心能力：任务 CRUD + 三态切换 + 修改历史追溯 + 任务图片分享 + 数据导入导出 + 多维度统计。

## 技术栈

- Flutter + Dart (SDK ^3.11.5)
- Provider 6.x（状态管理）
- Hive 2.x（本地持久化，JSON 序列化）
- uuid（任务/文件夹 ID 生成）
- intl（日期格式化）
- share_plus + file_picker + path_provider（数据导出/导入 + 任务图片分享）

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

### 首页统计卡片（轮播）

- `_buildStatsCard`：毛玻璃暖色卡片（`#FFF2E6` → `#FFE4CC`），圆角 18px，白边框
- 右上角「今日/昨日」分段按钮，选中为橙色浅底
- 通过 `PageController` + `PageView` 实现左右滑动 + 自动轮播（4 秒间隔）
- 左侧：52px 环形进度圈（橙色 `#E8833A`）+ 中心百分比
- 右侧：「X 个任务，X 已完成」+ 未完成/部分完成迷你胶囊
- 数据来源：`AppProvider.today*` 和 `AppProvider.yesterday*` 两组 getter

### 编辑保存流程（含历史记录）

```
CreateTaskPage._save()
  → 逐字段对比旧值，收集有变化的字段
  → 如有变化，构造 TaskHistory 实例，同时存储 Before/After 值对（分别记录旧值和新值）
    → 变更类型判断：Before 空 After 非空 = added（新增）；都非空 = modified（修改）；Before 非空 After 空 = cleared（清空）
  → task.history.add(historyEntry)
  → provider.updateTask(task)  // 更新内存 + 写 Hive
```

- 编辑页用 `PopScope` 拦截返回，自动保存
- 没有字段变化时不新增历史记录
- `TaskHistory` 每个字段存储 Before/After 值对，旧版单值格式自动兼容（映射为 After，Before 为 null）
- 历史详情页：未修改字段通过遍历更老条目重建该时间点的值；已修改字段按 added/modified/cleared 三种类型展示
- 列表页每条显示：`字段: [新增] 新值` / `字段: 旧值 → 新值` / `字段: [已清空] 旧值`

### 任务图片分享

```
TaskCard 分享按钮 / CreateTaskPage AppBar 分享按钮
→ showShareTaskDialog()
  → 第一阶段：弹出预览对话框（内嵌 ConstrainedBox + SingleChildScrollView + ShareableTaskCard，可滚动预览长内容）
  → 用户点击「分享」→ Navigator.pop(true)
  → 第二阶段：OverlayEntry 插入不受约束的完整 ShareableTaskCard → 等待渲染 → captureWidget() 截全高度 PNG
  → 移除 OverlayEntry → saveToTemp() + Share.shareXFiles() 调起系统分享
  → 分享完成后弹出对话框询问是否保存至本地
  → 确认则 saveToDocuments() 保存到 {documents}/images/
```

- 预览阶段卡片放在 `ConstrainedBox(maxHeight: 屏幕55%)` + `SingleChildScrollView` 中，解决长内容在对话框内被裁剪的问题
- 截图阶段用 `OverlayEntry` 渲染完整卡片（不受对话框高度约束），实现"长截屏"效果
- 截图完成后立即移除 OverlayEntry；截图失败在主页弹出 SnackBar 提示
- 取消分享静默返回（不弹错误提示）
- `CreateTaskPage._shareTask()` 先调 `_resolveFolderId()` 解析分类（与 `_save()` 一致），确保预览分类与表单当前输入同步
- `ShareableTaskCard` 为独立卡片组件：水墨留白配色（`#E8E4DF` → `#F5F2ED` 淡墨渐变），320px 宽，圆角 24px
- 标题/描述/备注均无 `maxLines` 限制，完整展示全文；信息行（分类/状态/日期）使用 `Wrap` 换行布局
- `captureWidget()` 通过 `RenderRepaintBoundary.toImage()` 渲染为 3x 像素比 PNG
- 分享功能在首页任务列表、新建页、编辑页均可用

### 微信导入（Android Intent）

```
外部 .json 文件 → AndroidManifest ACTION_VIEW → MainActivity.kt MethodChannel
→ FileIntentHandler → ImportHandler → showDialog 确认 → provider.importFromJsonString()
```

### 启动提示弹窗

```
App 启动 → ImportHandler.didChangeDependencies()
  → _checkTipAfterInit() → provider.shouldShowTip 判断
    → daily（默认）：当天未提示过则弹出
    → weekly：距上次提示 >= 7 天则弹出
    → forever：永不弹出
  → _showTipDialog() 显示欢迎对话框（barrierDismissible: false）
    → 三个板块：注意事项 / App 亮点 / 使用技巧
    → 三个按钮：「我知道了」（当天不再显示）/「一周内不再弹出」/「永远不再弹出」
    → 按钮点击调用 provider.dismissTip('daily'|'weekly'|'forever') 更新 tipMode + lastTipDate
```

- `_TipSection` 组件（`app.dart` 内）统一渲染板块：图标 + 标题 + 项目符号列表

### AppProvider 统计 getter

- **今天/昨天**：`todayTotal` / `todayDone` / `todayTodo` / `todayPartial` / `todayCompletionRate`；`yesterday*` 同理
- **本周/本月**：`weekDone` / `monthDone`
- **全局**：`totalCount` / `doneCount` / `groupedByDate`（返回 `List<DateGroup>`）/ `dateGroups`（排序后的日期分组列表）
- **筛选**：`searchTasks()` 按关键词/分类/状态/日期多条件筛选
- **统计页**：`getTasksByMonth(year, month)` / `getTaskCountByFolder(folderId)`

## 项目结构要点

```
lib/
├── main.dart                   # 入口：初始化 Hive、检查 intent 文件、挂载 Provider
├── app.dart                    # MaterialApp + MainShell + ImportHandler
├── models/
│   ├── task.dart               # Task（copyWith / toJson / fromJson / displayTitle）
│   ├── task_history.dart       # 修改历史（Before/After 值对 + FieldChangeType 枚举）
│   ├── folder.dart             # Folder
│   └── app_settings.dart       # AppSettings（排序/删除确认/默认首页/提示设置/lastTipDate）
├── providers/
│   └── app_provider.dart       # 全局状态：CRUD + 搜索/筛选 + 今天/昨天统计 + 导入导出 + 提示控制
├── pages/                      # 每个页面一个文件，通过命名路由跳转
├── widgets/                    # UI 组件（TaskCard / StatusMark / ShareableTaskCard 等）
└── utils/
    ├── constants.dart          # 常量、状态映射、getNextStatus()
    ├── date_utils.dart         # 日期判定和格式化（todayStr / yesterdayStr / isYesterday / formatDate 等）
    ├── intent_handler.dart     # Android intent 文件接收
    ├── share_utils.dart        # 截图工具（captureWidget / saveToTemp / saveToDocuments）
    └── share_dialog.dart       # 分享对话框流程（预览 → 截图 → 系统分享 → 询问保存）
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

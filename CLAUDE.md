# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个 Flutter 任务记录器 App（本地 Todo 应用），采用 Provider + Hive 架构，包名为 `advanced_transcription`。

## 技术栈

- Flutter + Dart (SDK ^3.11.5)
- Provider 6.x（状态管理）
- Hive 2.x（本地持久化，JSON 序列化）
- uuid（任务/文件夹 ID 生成）
- intl（日期格式化）
- share_plus + file_picker + path_provider（数据导出/导入）

## 项目架构

```
lib/
├── main.dart                  # 入口：初始化 Hive、检查 intent 文件、挂载 Provider
├── app.dart                   # MaterialApp + MainShell + ImportHandler（处理外部打开文件 + 每日提示）
├── models/
│   ├── task.dart              # 任务模型（copyWith, toJson/fromJson, displayTitle, 内嵌历史数组）
│   ├── task_history.dart      # 修改历史记录模型（记录变更字段 + 时间戳）
│   ├── folder.dart            # 文件夹模型（可编辑名称/描述）
│   └── app_settings.dart      # 排序方式、删除确认、默认首页、提示弹窗设置
├── providers/
│   └── app_provider.dart      # 全局 ChangeNotifier：CRUD、搜索筛选、统计、数据导入导出、提示控制
├── pages/
│   ├── home_page.dart         # 今日任务 + 统计卡片 + 内联搜索
│   ├── category_page.dart     # 分类列表（含删除按钮，有任务时提示跳转批量删除）
│   ├── category_task_page.dart# 分类下任务列表（支持长按/选择按钮进入批量删除模式）
│   ├── date_page.dart         # 日期分组列表（按 taskDate 分组）
│   ├── date_task_page.dart
│   ├── search_page.dart       # 独立搜索页（备选方案）
│   ├── stats_page.dart        # 统计
│   ├── setting_page.dart      # 设置（默认首页、排序、删除确认、导出/导入、清空数据）
│   ├── task_detail_page.dart  # 只读详情页
│   ├── task_history_page.dart # 修改历史记录查看页（可点击进入版本详情）
│   ├── task_history_detail_page.dart # 版本详情页（展示所有字段，标注已修改/未修改）
│   └── create_task_page.dart  # 新建/编辑任务，PopScope 自动保存，暖色系 UI
├── widgets/
│   ├── task_card.dart         # 可点击进入编辑 + 左滑删除（Dismissible）+ 长按选择
│   ├── status_mark.dart       # □ / ✓ / 半勾 三态
│   ├── section_title.dart     # 区块标题
│   ├── page_header.dart       # 页面头部（支持返回按钮和 actions）
│   ├── settings_row.dart      # 设置行
│   ├── info_tile.dart         # 信息卡片
│   ├── empty_state.dart       # 空状态占位
│   ├── filter_bar.dart        # 筛选栏
│   └── create_folder_sheet.dart
└── utils/
    ├── constants.dart         # 默认分类ID/名称、导航项、状态映射、排序选项、getNextStatus()
    ├── date_utils.dart        # 日期判定和格式化
    └── intent_handler.dart    # Android intent 文件接收（MethodChannel）
```

## 关键设计

### 状态管理
- 所有状态集中在 `AppProvider`（ChangeNotifier），页面通过 `context.watch`（监听）/ `context.read`（事件）访问
- `search()` 调用 `notifyListeners()`，配合 `context.watch` 自动刷新搜索结果

### 持久化
- Hive 的三个 box：`tasks`、`folders`、`settings`，均以单 key `'data'` 存取 JSON 数组/对象
- 初始化在 `AppProvider.initialize()` 中完成，异步加载数据后调用 `notifyListeners()`

### 任务模型
- 三个状态：`status` 为 `'todo'` | `'done'` | `'partial'`
- 循环顺序：`todo` → `done` → `partial` → `todo`（通过 `getNextStatus()` 切换）
- `displayTitle`：优先显示 title，为空则截取 description 14 字，再空则显示"未命名任务"
- `createdAt`：YYYY-MM-DD（实际创建时间）；`taskDate`：YYYY-MM-DD（用户可设定的执行日期，默认同 createdAt）
- `updatedAt`：ISO datetime
- 内嵌 `List<TaskHistory>`，每次从编辑页保存时对比字段变化，有变才追加记录
- 旧数据兼容：`taskDate` 在 `fromJson` 中为空时自动回退到 `createdAt`

### 导航
- 底部 5 个 Tab（首页/分类/日期/统计/设置），通过 `IndexedStack` 保持页面状态
- 默认首页可由用户在设置页切换（`settings.defaultTab`）
- Tab 重新点击触发 `_tabTapVersion++`，`HomePage` 据此收起搜索
- 命名路由：`/create-task`（传 task.id 编辑）、`/task-detail`、`/task-history`、`/task-history-detail`、`/search`、`/category-tasks`、`/date-tasks`
- 路由参数统一通过 `ModalRoute.of(context)?.settings.arguments` 接收

### 任务交互
- **点击卡片** → 导航至 `/create-task`（传入 task.id）
- **左滑卡片** → `Dismissible` + 确认弹窗 → 删除
- **长按卡片**（分类页面）→ 进入批量选择模式
- **点击状态图标** → `toggleStatus()` 循环切换

### 文件夹管理
- 默认分类（`default_uncategorized` / "未分类"）不可删除
- 删除非空文件夹时弹窗提示任务数，提供"去处理"跳转到批量删除页
- 批量选择模式：逐一点选或全选，底部栏显示选中数量，确认后批量删除

### 创建/编辑任务页
- 暖色系 UI（米白背景、杏色输入框、暖橙强调色、暖棕标签）
- `PopScope` 拦截系统返回，关闭时自动保存
- 描述/备注输入框 `minLines: 3` + `maxLines: null`，自动随内容扩展
- 每个 TextField 绑定独立 `FocusNode`，获得焦点自动滚动到可见区域
- 编辑模式下 AppBar 显示"历史记录"按钮
- 保存时逐字段对比，仅真有变化时才新增 `TaskHistory` 并持久化
- 分类字段支持输入新名称自动创建文件夹
- 状态下拉菜单带图标（○未完成 / ✓已完成 / ⊖部分完成），选中项高亮暖橙色
- 可选的"执行日期"字段，默认当天，点击弹出 DatePicker，非当天日期显示清除按钮

### 微信导入（Android Intent）
- `AndroidManifest.xml` 注册 `ACTION_VIEW` + `application/json` intent filter
- `MainActivity.kt` 通过 MethodChannel 转发文件 URI 到 Dart 端
- `ImportHandler`（app.dart）接收文件 → 验证 JSON → 弹窗确认 → `importFromJsonString`

### 每日提示
- App 首次启动时检查 `AppProvider.shouldShowTip`（依据 `tipMode` 和 `lastTipDate`）
- 弹窗含注意事项 / App 亮点 / 使用技巧三块
- 用户可选："我知道了"（明天再弹）/ "一周内不再弹出" / "永远不再弹出"

### 数据导出/导入
- `exportToJsonString()` → JSON 字符串 → `share_plus` 分享
- `importFromJsonString()` → 读取 JSON → 覆盖恢复本地数据
- 微信导入通过 Android intent filter 接收 `.json` 文件

## 常用命令

```bash
# 运行项目
flutter run

# 构建 APK（arm64）
flutter build apk --target-platform android-arm64

# 构建 APK（全架构）
flutter build apk

# 代码分析
flutter analyze

# 获取依赖
flutter pub get

# 清除构建缓存
flutter clean
```

## 注意事项

- 当前仅 Android 端注册了 intent filter，iOS 未处理文件打开
- 无测试文件，验证方式为 `flutter analyze` + 模拟器手动测试
- 底部 Tab 切换通过 `navigateToTab` + `_tabTapVersion` 实现
- 编辑任务时若没有任何字段变化则不保存也不新增历史记录
- PUB_CACHE 跨盘（项目在 D 盘、缓存默认在 C 盘）可能导致 Gradle 构建失败，Windows 用户环境变量需设为 `PUB_CACHE=D:\.pub-cache`（必须是绝对路径，`D:.pub-cache` 缺少反斜杠会被当作相对路径，导致失效退回到 C 盘缓存）

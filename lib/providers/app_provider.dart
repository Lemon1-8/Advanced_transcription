import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/folder.dart';
import '../models/app_settings.dart';
import '../utils/date_utils.dart' as du;
import '../utils/constants.dart';

class AppProvider extends ChangeNotifier {
  // Data
  List<Task> _tasks = [];
  List<Folder> _folders = [];
  AppSettings _settings = AppSettings();
  bool _initialized = false;

  // UI state
  int _currentTab = 0;
  String? _overlayType; // 'task' | 'folder' | null
  Task? _editingTask;
  Folder? _editingFolder;

  // Query state
  String _queryKeyword = '';
  String _queryCategory = '';
  String _queryStatus = '';
  String _queryDate = '';
  // ignore: unused_field
  DateTime? _queryCustomStart;
  // ignore: unused_field
  DateTime? _queryCustomEnd;
  List<Task> _queryResults = [];

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Folder> get folders => List.unmodifiable(_folders);
  AppSettings get settings => _settings;
  bool get initialized => _initialized;
  int get currentTab => _currentTab;
  String? get overlayType => _overlayType;
  Task? get editingTask => _editingTask;
  Folder? get editingFolder => _editingFolder;
  String get queryKeyword => _queryKeyword;
  String get queryCategory => _queryCategory;
  String get queryStatus => _queryStatus;
  String get queryDate => _queryDate;
  List<Task> get queryResults => List.unmodifiable(_queryResults);

  Folder? get defaultFolder {
    try {
      return _folders.firstWhere((f) => f.id == defaultFolderId);
    } catch (_) {
      return null;
    }
  }

  List<Task> get todayTasks {
    final today = du.todayStr();
    return _tasks.where((t) => t.createdAt == today).toList();
  }

  // ========== Initialization ==========

  Future<void> initialize() async {
    if (_initialized) return;

    final taskBox = await Hive.openBox('tasks');
    final folderBox = await Hive.openBox('folders');
    final settingsBox = await Hive.openBox('settings');

    // Load tasks
    final tasksData = taskBox.get('data') as List<dynamic>?;
    if (tasksData != null) {
      _tasks = tasksData
          .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Load folders
    final foldersData = folderBox.get('data') as List<dynamic>?;
    if (foldersData != null) {
      _folders = foldersData
          .map((e) => Folder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Load settings
    final settingsData = settingsBox.get('data');
    if (settingsData != null) {
      _settings = AppSettings.fromJson(Map<String, dynamic>.from(settingsData));
    }

    // Ensure default folder exists
    if (_folders.every((f) => f.id != defaultFolderId)) {
      _folders.insert(
        0,
        Folder(
          id: defaultFolderId,
          name: defaultFolderName,
          description: '默认分类，不可删除',
        ),
      );
      _saveFolders();
    }

    _initialized = true;
    notifyListeners();
  }

  // ========== Persistence ==========

  Future<void> _saveTasks() async {
    final box = await Hive.openBox('tasks');
    await box.put('data', _tasks.map((t) => t.toJson()).toList());
  }

  Future<void> _saveFolders() async {
    final box = await Hive.openBox('folders');
    await box.put('data', _folders.map((f) => f.toJson()).toList());
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox('settings');
    await box.put('data', _settings.toJson());
  }

  // ========== Task CRUD ==========

  Future<void> addTask({
    String title = '',
    String description = '',
    String folderId = '',
    String status = 'todo',
    String notes = '',
  }) async {
    final task = Task(
      title: title,
      description: description,
      folderId: folderId.isEmpty ? defaultFolderId : folderId,
      status: status,
      notes: notes,
    );
    _tasks.insert(0, task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _tasks[index] = updated;
    await _saveTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final current = _tasks[index];
    final nextStatus = getNextStatus(current.status);
    _tasks[index] = current.copyWith(
      status: nextStatus,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _saveTasks();
    notifyListeners();
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Task> getTasksByFolder(String folderId) {
    return _tasks.where((t) => t.folderId == folderId).toList();
  }

  List<Task> getTasksByDate(String dateStr) {
    return _tasks.where((t) => t.createdAt == dateStr).toList();
  }

  List<Task> getTasksByMonth(String monthKey) {
    return _tasks.where((t) => t.createdAt.startsWith(monthKey)).toList();
  }

  int getTaskCountByFolder(String folderId) {
    return _tasks.where((t) => t.folderId == folderId).length;
  }

  // ========== Folder CRUD ==========

  Future<void> addFolder(String name, String description) async {
    final folder = Folder(name: name, description: description);
    _folders.add(folder);
    await _saveFolders();
    notifyListeners();
  }

  Future<void> renameFolder(String id, String newName) async {
    final index = _folders.indexWhere((f) => f.id == id);
    if (index == -1 || _folders[index].id == defaultFolderId) return;
    _folders[index].name = newName;
    await _saveFolders();
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    if (id == defaultFolderId) return;
    // Move tasks to default folder
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].folderId == id) {
        _tasks[i] = _tasks[i].copyWith(folderId: defaultFolderId);
      }
    }
    _folders.removeWhere((f) => f.id == id);
    await _saveFolders();
    await _saveTasks();
    notifyListeners();
  }

  Folder? getFolderById(String id) {
    try {
      return _folders.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  // ========== Settings ==========

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _tasks.clear();
    _folders.removeWhere((f) => f.id != defaultFolderId);
    _settings = AppSettings();
    await _saveTasks();
    await _saveFolders();
    await _saveSettings();
    notifyListeners();
  }

  // ========== Navigation ==========

  void navigateToTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void openCreateTaskSheet() {
    _overlayType = 'task';
    _editingTask = null;
    notifyListeners();
  }

  void openEditTaskSheet(Task task) {
    _overlayType = 'task';
    _editingTask = task;
    notifyListeners();
  }

  void openCreateFolderSheet() {
    _overlayType = 'folder';
    _editingFolder = null;
    notifyListeners();
  }

  void openEditFolderSheet(Folder folder) {
    _overlayType = 'folder';
    _editingFolder = folder;
    notifyListeners();
  }

  void closeOverlay() {
    _overlayType = null;
    _editingTask = null;
    _editingFolder = null;
    notifyListeners();
  }

  // ========== Query ==========

  void setQueryKeyword(String keyword) {
    _queryKeyword = keyword;
  }

  void setQueryCategory(String category) {
    _queryCategory = category;
  }

  void setQueryStatus(String status) {
    _queryStatus = status;
  }

  void setQueryDate(String date) {
    _queryDate = date;
  }

  void setQueryCustomDateRange(DateTime start, DateTime end) {
    _queryCustomStart = start;
    _queryCustomEnd = end;
  }

  void search() {
    var results = List<Task>.from(_tasks);

    // Keyword filter
    if (_queryKeyword.isNotEmpty) {
      final kw = _queryKeyword.toLowerCase();
      results = results.where((t) {
        return t.title.toLowerCase().contains(kw) ||
            t.description.toLowerCase().contains(kw) ||
            t.notes.toLowerCase().contains(kw) ||
            _getFolderName(t.folderId).toLowerCase().contains(kw);
      }).toList();
    }

    // Category filter
    if (_queryCategory.isNotEmpty) {
      results = results.where((t) => t.folderId == _queryCategory).toList();
    }

    // Status filter
    if (_queryStatus.isNotEmpty) {
      results = results.where((t) => t.status == _queryStatus).toList();
    }

    // Date filter
    if (_queryDate.isNotEmpty) {
      results = _filterByDate(results, _queryDate);
    }

    _queryResults = results;
    notifyListeners();
  }

  List<Task> _filterByDate(List<Task> source, String filter) {
    switch (filter) {
      case '今天':
        return source.where((t) => du.isToday(t.createdAt)).toList();
      case '昨天':
        return source.where((t) => du.isYesterday(t.createdAt)).toList();
      case '近7天':
        return source.where((t) => du.isWithinLast7Days(t.createdAt)).toList();
      case '本周':
        return source.where((t) => du.isCurrentWeek(t.createdAt)).toList();
      case '本月':
        return source.where((t) => du.isCurrentMonth(t.createdAt)).toList();
      default:
        return source;
    }
  }

  String _getFolderName(String folderId) {
    final folder = getFolderById(folderId);
    return folder?.name ?? '';
  }

  // ========== Statistics ==========

  int get todayTotal => todayTasks.length;
  int get todayDone => todayTasks.where((t) => t.status == 'done').length;
  int get todayTodo => todayTasks.where((t) => t.status == 'todo').length;
  int get todayPartial =>
      todayTasks.where((t) => t.status == 'partial').length;

  double get todayCompletionRate {
    if (todayTotal == 0) return 0;
    return todayDone / todayTotal;
  }

  int get weekDone {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    return _tasks.where((t) {
      if (t.status != 'done') return false;
      try {
        final date = DateTime.parse(t.createdAt);
        return !date.isBefore(monday);
      } catch (_) {
        return false;
      }
    }).length;
  }

  int get monthDone {
    final monthKey = du.currentMonthStr();
    return _tasks
        .where((t) => t.status == 'done' && t.createdAt.startsWith(monthKey))
        .length;
  }

  // ========== Date grouping ==========

  Map<String, List<Task>> get groupedByDate {
    final map = <String, List<Task>>{};
    for (final task in _tasks) {
      final key = du.getDateGroupKey(task.createdAt);
      map.putIfAbsent(key, () => []);
      map[key]!.add(task);
    }
    return map;
  }

  List<DateGroup> get dateGroups {
    final grouped = groupedByDate;
    final keys = grouped.keys.toList();

    // Sort: today first, yesterday second, then by month
    keys.sort((a, b) {
      if (a == 'today') return -1;
      if (b == 'today') return 1;
      if (a == 'yesterday') return -1;
      if (b == 'yesterday') return 1;
      return b.compareTo(a); // newer months first
    });

    return keys.map((key) {
      final tasks = grouped[key]!;
      String label;
      if (key == 'today') {
        label = '今天';
      } else if (key == 'yesterday') {
        label = '昨天';
      } else {
        label = du.formatMonth(key);
      }
      return DateGroup(label: label, key: key, tasks: tasks);
    }).toList();
  }
}

class DateGroup {
  final String label;
  final String key;
  final List<Task> tasks;

  DateGroup({
    required this.label,
    required this.key,
    required this.tasks,
  });

  int get doneCount => tasks.where((t) => t.status == 'done').length;
  int get totalCount => tasks.length;
}

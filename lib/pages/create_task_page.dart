import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/folder.dart';
import '../models/task_history.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as du;

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _notesController;
  late TextEditingController _categoryController;
  late String _status;
  late String _taskDate;
  bool _saving = false;
  Task? _existingTask;
  bool _initialized = false;

  final _scrollController = ScrollController();
  final _titleFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();

  bool get _isEditing => _existingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _notesController = TextEditingController();
    _categoryController = TextEditingController(text: '未分类');
    _status = 'todo';
    _taskDate = du.todayStr();
    _titleFocusNode.addListener(() => _onFieldFocus(_titleFocusNode));
    _descFocusNode.addListener(() => _onFieldFocus(_descFocusNode));
    _notesFocusNode.addListener(() => _onFieldFocus(_notesFocusNode));
    _categoryFocusNode.addListener(() => _onFieldFocus(_categoryFocusNode));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final taskId = ModalRoute.of(context)?.settings.arguments as String?;
      if (taskId != null) {
        final provider = context.read<AppProvider>();
        final task = provider.getTaskById(taskId);
        if (task != null) {
          _existingTask = task;
          _titleController.text = task.title;
          _descController.text = task.description;
          _notesController.text = task.notes;
          final folder = provider.getFolderById(task.folderId);
          _categoryController.text = folder?.name ?? '未分类';
          _status = task.status;
          _taskDate = task.taskDate;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    _titleFocusNode.dispose();
    _descFocusNode.dispose();
    _notesFocusNode.dispose();
    _categoryFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFieldFocus(FocusNode node) {
    if (node.hasFocus && node.context != null) {
      Scrollable.ensureVisible(
        node.context!,
        alignment: 0.3,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  bool get _hasContent {
    return _titleController.text.trim().isNotEmpty ||
        _descController.text.trim().isNotEmpty ||
        _notesController.text.trim().isNotEmpty;
  }

  Future<String> _resolveFolderId() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty || name == '未分类') return defaultFolderId;

    final provider = context.read<AppProvider>();
    final existing = provider.folders.where((f) => f.name == name).toList();
    if (existing.isNotEmpty) return existing.first.id;

    await provider.addFolder(name, '');
    final newFolder = provider.folders.firstWhere((f) => f.name == name);
    return newFolder.id;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final provider = context.read<AppProvider>();
    final folderId = await _resolveFolderId();
    if (_isEditing) {
      final existing = _existingTask!;
      final changes = <String, dynamic>{};
      if (_titleController.text != existing.title) {
        changes['title'] = _titleController.text;
      }
      if (_descController.text != existing.description) {
        changes['description'] = _descController.text;
      }
      if (folderId != existing.folderId) {
        changes['folderId'] = folderId;
      }
      if (_status != existing.status) {
        changes['status'] = _status;
      }
      if (_notesController.text != existing.notes) {
        changes['notes'] = _notesController.text;
      }
      if (_taskDate != existing.taskDate) {
        changes['taskDate'] = _taskDate;
      }

      if (changes.isNotEmpty) {
        final historyEntry = TaskHistory(
          updatedAt: DateTime.now().toIso8601String(),
          title: changes.containsKey('title') ? changes['title'] as String? : null,
          description: changes.containsKey('description') ? changes['description'] as String? : null,
          folderId: changes.containsKey('folderId') ? changes['folderId'] as String? : null,
          status: changes.containsKey('status') ? changes['status'] as String? : null,
          notes: changes.containsKey('notes') ? changes['notes'] as String? : null,
          taskDate: changes.containsKey('taskDate') ? changes['taskDate'] as String? : null,
        );
        final updated = existing.copyWith(
          title: _titleController.text,
          description: _descController.text,
          folderId: folderId,
          status: _status,
          notes: _notesController.text,
          taskDate: _taskDate,
          history: [...existing.history, historyEntry],
        );
        await provider.updateTask(updated);
      }
    } else {
      await provider.addTask(
        title: _titleController.text,
        description: _descController.text,
        folderId: folderId,
        status: _status,
        notes: _notesController.text,
        taskDate: _taskDate,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _autoSaveAndPop() async {
    if (_saving) return;
    if (_hasContent) {
      await _save();
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final folders = provider.folders;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: Text(_isEditing ? '编辑任务' : '新建任务'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _autoSaveAndPop,
        ),
        foregroundColor: const Color(0xFFE8833A),
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: '历史记录',
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/task-history',
                    arguments: _existingTask!.id,
                  ),
                ),
              ]
            : null,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _autoSaveAndPop();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                '默认状态为未完成，创建日期由系统自动记录。',
                style: TextStyle(fontSize: 13, color: Color(0xFF8B7355)),
              ),
              const SizedBox(height: 20),
              _buildLabel('任务标题'),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: InputDecoration(
                  hintText: '例如：完成毕业设计需求分析',
                  hintStyle: const TextStyle(color: Color(0xFFC4A882)),
                  filled: true,
                  fillColor: const Color(0xFFFFF2E6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              _buildLabel('任务描述'),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                focusNode: _descFocusNode,
                minLines: 3,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: '补充任务说明、完成要求或备注...',
                  hintStyle: const TextStyle(color: Color(0xFFC4A882)),
                  filled: true,
                  fillColor: const Color(0xFFFFF2E6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryField(folders, _categoryFocusNode),
              const SizedBox(height: 12),
              _buildStatusField(),
              const SizedBox(height: 12),
              _buildDateField(),
              const SizedBox(height: 12),
              _buildLabel('备注'),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                focusNode: _notesFocusNode,
                minLines: 3,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: '可填写完成情况或其他说明',
                  hintStyle: const TextStyle(color: Color(0xFFC4A882)),
                  filled: true,
                  fillColor: const Color(0xFFFFF2E6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8B7355),
      ),
    );
  }

  Widget _buildCategoryField(List<Folder> folders, FocusNode categoryFocusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('所属分类'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2E6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: TextField(
                    controller: _categoryController,
                    focusNode: categoryFocusNode,
                    decoration: const InputDecoration(
                      hintText: '未分类',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down,
                    color: Color(0xFFE8833A)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onSelected: (name) {
                  _categoryController.text = name;
                },
                itemBuilder: (context) => folders.map((f) {
                  final isSelected = f.name == _categoryController.text;
                  return PopupMenuItem(
                    value: f.name,
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 18,
                          color: isSelected
                              ? const Color(0xFFE8833A)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          f.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFFE8833A)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        if (isSelected) ...[
                          const Spacer(),
                          const Icon(Icons.check,
                              size: 16, color: Color(0xFFE8833A)),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    const items = [
      ('todo', '未完成', Icons.radio_button_unchecked),
      ('done', '已完成', Icons.check_circle_outline),
      ('partial', '部分完成', Icons.remove_circle_outline),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('任务状态'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2E6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _status,
              isExpanded: true,
              icon: const Icon(Icons.expand_more,
                  color: Color(0xFFE8833A)),
              borderRadius: BorderRadius.circular(14),
              items: items.map((item) {
                final (value, label, icon) = item;
                final isSelected = value == _status;
                return DropdownMenuItem(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? const Color(0xFFE8833A)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isSelected
                              ? const Color(0xFFE8833A)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('执行日期'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: Color(0xFFE8833A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    du.formatDate(_taskDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (_taskDate != du.todayStr())
                  GestureDetector(
                    onTap: () {
                      setState(() => _taskDate = du.todayStr());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Color(0xFF94A3B8)),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down,
                    color: Color(0xFFE8833A)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_taskDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _taskDate = formatted);
    }
  }
}

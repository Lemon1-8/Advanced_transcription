import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/folder.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

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
      final updated = _existingTask!.copyWith(
        title: _titleController.text,
        description: _descController.text,
        folderId: folderId,
        status: _status,
        notes: _notesController.text,
      );
      await provider.updateTask(updated);
    } else {
      await provider.addTask(
        title: _titleController.text,
        description: _descController.text,
        folderId: folderId,
        status: _status,
        notes: _notesController.text,
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
      appBar: AppBar(
        title: Text(_isEditing ? '编辑任务' : '新建任务'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _autoSaveAndPop,
        ),
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
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              _buildLabel('任务标题'),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: InputDecoration(
                  hintText: '例如：完成毕业设计需求分析',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
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
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '补充任务说明、完成要求或备注...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
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
              _buildDropdown(
                label: '任务状态',
                value: _statusLabel(_status),
                items: const ['未完成', '已完成', '部分完成'],
                onSelected: (label) {
                  setState(() => _status = _statusValue(label));
                },
              ),
              const SizedBox(height: 12),
              _buildLabel('备注'),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                focusNode: _notesFocusNode,
                decoration: InputDecoration(
                  hintText: '可填写完成情况或其他说明',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
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
        color: Color(0xFF64748B),
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
            color: const Color(0xFFF1F5F9),
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
                    color: Color(0xFF4F46E5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onSelected: (name) {
                  _categoryController.text = name;
                },
                itemBuilder: (context) => folders.map((f) {
                  return PopupMenuItem(
                    value: f.name,
                    child: Text(f.name),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5))),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onSelected(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'todo':
        return '未完成';
      case 'done':
        return '已完成';
      case 'partial':
        return '部分完成';
      default:
        return '未完成';
    }
  }

  String _statusValue(String label) {
    switch (label) {
      case '未完成':
        return 'todo';
      case '已完成':
        return 'done';
      case '部分完成':
        return 'partial';
      default:
        return 'todo';
    }
  }
}

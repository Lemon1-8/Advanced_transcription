import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CreateFolderSheet extends StatefulWidget {
  const CreateFolderSheet({super.key});

  @override
  State<CreateFolderSheet> createState() => _CreateFolderSheetState();
}

class _CreateFolderSheetState extends State<CreateFolderSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await context.read<AppProvider>().addFolder(name, _descController.text.trim());
    if (mounted) context.read<AppProvider>().closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '新建文件夹',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '用于把任务放入不同分类，未选择分类时进入"未分类"。',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          _buildLabel('文件夹名称'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '例如：毕设 / 学习 / 运动',
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
          _buildLabel('文件夹说明'),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '可选，用于说明这个分类存放哪些任务...',
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '删除文件夹时，文件夹内任务会移动到"未分类"；"未分类"不能被删除。',
              style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.read<AppProvider>().closeOverlay(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: const Text('取消',
                      style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('保存文件夹',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
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
}

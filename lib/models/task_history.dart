class TaskHistory {
  final String updatedAt;
  final String? title;
  final String? description;
  final String? folderId;
  final String? status;
  final String? notes;
  final String? taskDate;

  TaskHistory({
    required this.updatedAt,
    this.title,
    this.description,
    this.folderId,
    this.status,
    this.notes,
    this.taskDate,
  });

  bool get hasChanges =>
      title != null ||
      description != null ||
      folderId != null ||
      status != null ||
      notes != null ||
      taskDate != null;

  List<String> get changedFields {
    final fields = <String>[];
    if (title != null) fields.add('标题');
    if (description != null) fields.add('描述');
    if (folderId != null) fields.add('分类');
    if (status != null) fields.add('状态');
    if (notes != null) fields.add('备注');
    if (taskDate != null) fields.add('执行日期');
    return fields;
  }

  Map<String, dynamic> toJson() => {
        'updatedAt': updatedAt,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (folderId != null) 'folderId': folderId,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
        if (taskDate != null) 'taskDate': taskDate,
      };

  factory TaskHistory.fromJson(Map<String, dynamic> json) => TaskHistory(
        updatedAt: json['updatedAt'] as String,
        title: json['title'] as String?,
        description: json['description'] as String?,
        folderId: json['folderId'] as String?,
        status: json['status'] as String?,
        notes: json['notes'] as String?,
        taskDate: json['taskDate'] as String?,
      );
}

enum FieldChangeType { added, modified, cleared }

class TaskHistory {
  final String updatedAt;
  final String? titleBefore;
  final String? titleAfter;
  final String? descriptionBefore;
  final String? descriptionAfter;
  final String? folderIdBefore;
  final String? folderIdAfter;
  final String? statusBefore;
  final String? statusAfter;
  final String? notesBefore;
  final String? notesAfter;
  final String? taskDateBefore;
  final String? taskDateAfter;

  TaskHistory({
    required this.updatedAt,
    this.titleBefore,
    this.titleAfter,
    this.descriptionBefore,
    this.descriptionAfter,
    this.folderIdBefore,
    this.folderIdAfter,
    this.statusBefore,
    this.statusAfter,
    this.notesBefore,
    this.notesAfter,
    this.taskDateBefore,
    this.taskDateAfter,
  });

  FieldChangeType? get titleChangeType => _changeType(titleBefore, titleAfter);
  FieldChangeType? get descriptionChangeType =>
      _changeType(descriptionBefore, descriptionAfter);
  FieldChangeType? get folderIdChangeType =>
      _changeType(folderIdBefore, folderIdAfter);
  FieldChangeType? get statusChangeType => _changeType(statusBefore, statusAfter);
  FieldChangeType? get notesChangeType => _changeType(notesBefore, notesAfter);
  FieldChangeType? get taskDateChangeType =>
      _changeType(taskDateBefore, taskDateAfter);

  static FieldChangeType? _changeType(String? before, String? after) {
    if (after == null) return null;
    final hasBefore = (before ?? '').trim().isNotEmpty;
    final hasAfter = after.trim().isNotEmpty;
    if (!hasBefore && hasAfter) return FieldChangeType.added;
    if (hasBefore && hasAfter) return FieldChangeType.modified;
    if (hasBefore && !hasAfter) return FieldChangeType.cleared;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'updatedAt': updatedAt,
        if (titleBefore != null) 'titleBefore': titleBefore,
        if (titleAfter != null) 'titleAfter': titleAfter,
        if (descriptionBefore != null) 'descriptionBefore': descriptionBefore,
        if (descriptionAfter != null) 'descriptionAfter': descriptionAfter,
        if (folderIdBefore != null) 'folderIdBefore': folderIdBefore,
        if (folderIdAfter != null) 'folderIdAfter': folderIdAfter,
        if (statusBefore != null) 'statusBefore': statusBefore,
        if (statusAfter != null) 'statusAfter': statusAfter,
        if (notesBefore != null) 'notesBefore': notesBefore,
        if (notesAfter != null) 'notesAfter': notesAfter,
        if (taskDateBefore != null) 'taskDateBefore': taskDateBefore,
        if (taskDateAfter != null) 'taskDateAfter': taskDateAfter,
      };

  factory TaskHistory.fromJson(Map<String, dynamic> json) {
    // 兼容旧版单值格式：旧版 json 中 'title' 等字段同时表示新值
    final legacyTitle = json['title'] as String?;
    final legacyDescription = json['description'] as String?;
    final legacyFolderId = json['folderId'] as String?;
    final legacyStatus = json['status'] as String?;
    final legacyNotes = json['notes'] as String?;
    final legacyTaskDate = json['taskDate'] as String?;

    return TaskHistory(
      updatedAt: json['updatedAt'] as String,
      titleBefore: json['titleBefore'] as String?,
      titleAfter: json['titleAfter'] as String? ?? legacyTitle,
      descriptionBefore: json['descriptionBefore'] as String?,
      descriptionAfter: json['descriptionAfter'] as String? ?? legacyDescription,
      folderIdBefore: json['folderIdBefore'] as String?,
      folderIdAfter: json['folderIdAfter'] as String? ?? legacyFolderId,
      statusBefore: json['statusBefore'] as String?,
      statusAfter: json['statusAfter'] as String? ?? legacyStatus,
      notesBefore: json['notesBefore'] as String?,
      notesAfter: json['notesAfter'] as String? ?? legacyNotes,
      taskDateBefore: json['taskDateBefore'] as String?,
      taskDateAfter: json['taskDateAfter'] as String? ?? legacyTaskDate,
    );
  }
}

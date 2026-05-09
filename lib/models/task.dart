import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Task {
  final String id;
  String title;
  String description;
  String folderId;
  String status; // 'todo' | 'done' | 'partial'
  String createdAt; // YYYY-MM-DD
  String updatedAt; // ISO datetime
  String notes;

  Task({
    String? id,
    this.title = '',
    this.description = '',
    this.folderId = '',
    this.status = 'todo',
    String? createdAt,
    String? updatedAt,
    this.notes = '',
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? _todayStr(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();
    if (description.trim().isNotEmpty) {
      return description.length > 14
          ? '${description.substring(0, 14)}...'
          : description.trim();
    }
    return '未命名任务';
  }

  Task copyWith({
    String? title,
    String? description,
    String? folderId,
    String? status,
    String? notes,
    String? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      folderId: folderId ?? this.folderId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'folderId': folderId,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'notes': notes,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        folderId: json['folderId'] as String? ?? '',
        status: json['status'] as String? ?? 'todo',
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
        notes: json['notes'] as String? ?? '',
      );
}

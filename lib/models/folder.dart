import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Folder {
  final String id;
  String name;
  String description;
  final String createdAt;

  Folder({
    String? id,
    this.name = '',
    this.description = '',
    String? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt,
      };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        createdAt: json['createdAt'] as String?,
      );
}

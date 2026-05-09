class AppSettings {
  String sortOrder; // 'createdAt' | 'status'
  bool deleteConfirm;

  AppSettings({
    this.sortOrder = 'createdAt',
    this.deleteConfirm = true,
  });

  Map<String, dynamic> toJson() => {
        'sortOrder': sortOrder,
        'deleteConfirm': deleteConfirm,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        sortOrder: json['sortOrder'] as String? ?? 'createdAt',
        deleteConfirm: json['deleteConfirm'] as bool? ?? true,
      );
}

class AppSettings {
  String sortOrder; // 'createdAt' | 'status'
  bool deleteConfirm;
  int defaultTab; // 0: 首页, 1: 分类, 2: 日期, 3: 统计, 4: 设置
  String tipMode; // 'daily' | 'weekly' | 'forever'
  String? lastTipDate; // YYYY-MM-DD 格式，上次提示日期

  AppSettings({
    this.sortOrder = 'createdAt',
    this.deleteConfirm = true,
    this.defaultTab = 0,
    this.tipMode = 'daily',
    this.lastTipDate,
  });

  Map<String, dynamic> toJson() => {
        'sortOrder': sortOrder,
        'deleteConfirm': deleteConfirm,
        'defaultTab': defaultTab,
        'tipMode': tipMode,
        'lastTipDate': lastTipDate,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        sortOrder: json['sortOrder'] as String? ?? 'createdAt',
        deleteConfirm: json['deleteConfirm'] as bool? ?? true,
        defaultTab: json['defaultTab'] as int? ?? 0,
        tipMode: json['tipMode'] as String? ?? 'daily',
        lastTipDate: json['lastTipDate'] as String?,
      );
}

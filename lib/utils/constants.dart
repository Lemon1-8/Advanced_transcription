const String defaultFolderName = '未分类';
const String defaultFolderId = 'default_uncategorized';

const List<String> statusLabels = ['未完成', '已完成', '部分完成'];
const List<String> statusValues = ['todo', 'done', 'partial'];

const String appName = '任务记录器';
const String dataStorageHint = '所有数据仅保存在本机，不需要登录账号。';

const List<String> sortOptions = ['createdAt', 'status'];
const List<String> sortLabels = ['创建时间', '完成状态'];

const List<Map<String, String>> navItems = [
  {'key': 'home', 'label': '首页'},
  {'key': 'category', 'label': '分类'},
  {'key': 'date', 'label': '日期'},
  {'key': 'stats', 'label': '统计'},
  {'key': 'setting', 'label': '设置'},
];

const List<String> dateFilterOptions = [
  '全部时间',
  '今天',
  '昨天',
  '近7天',
  '本周',
  '本月',
  '自定义日期',
];

String getStatusLabel(String value) {
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

String getNextStatus(String current) {
  const order = ['todo', 'done', 'partial'];
  final index = order.indexOf(current);
  return order[(index + 1) % order.length];
}

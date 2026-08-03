import 'package:intl/intl.dart';

/// Get today's date as YYYY-MM-DD string.
String todayStr() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM-dd').format(now);
}

/// Get yesterday's date as YYYY-MM-DD string.
String yesterdayStr() {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return DateFormat('yyyy-MM-dd').format(yesterday);
}

/// Get tomorrow's date as YYYY-MM-DD string.
String tomorrowStr() {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  return DateFormat('yyyy-MM-dd').format(tomorrow);
}

/// Get current year-month as YYYY-MM string.
String currentMonthStr() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM').format(now);
}

/// Format a YYYY-MM-DD string to a readable Chinese format.
String formatDate(String yyyyMmDd) {
  try {
    final date = DateTime.parse(yyyyMmDd);
    return '${date.year}年${date.month}月${date.day}日';
  } catch (_) {
    return yyyyMmDd;
  }
}

/// Format a YYYY-MM string.
String formatMonth(String yyyyMm) {
  try {
    final parts = yyyyMm.split('-');
    return '${parts[0]}年${int.parse(parts[1])}月';
  } catch (_) {
    return yyyyMm;
  }
}

/// Check if a date string is today.
bool isToday(String yyyyMmDd) {
  return yyyyMmDd == todayStr();
}

/// Check if a date string is yesterday.
bool isYesterday(String yyyyMmDd) {
  return yyyyMmDd == yesterdayStr();
}

/// Check if a date string is tomorrow.
bool isTomorrow(String yyyyMmDd) {
  return yyyyMmDd == tomorrowStr();
}

/// Check if a date string is in the current month.
bool isCurrentMonth(String yyyyMmDd) {
  return yyyyMmDd.startsWith(currentMonthStr());
}

/// Get month prefix from a date string.
String getMonthKey(String yyyyMmDd) {
  if (yyyyMmDd.length >= 7) return yyyyMmDd.substring(0, 7);
  return yyyyMmDd;
}

DateTime? _parseDateOnly(String yyyyMmDd) {
  try {
    final dt = DateTime.parse(yyyyMmDd);
    return DateTime(dt.year, dt.month, dt.day);
  } catch (_) {
    return null;
  }
}

DateTime _todayOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Check if a date is within the last 7 days (including today).
bool isWithinLast7Days(String yyyyMmDd) {
  try {
    final date = DateTime.parse(yyyyMmDd);
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
    return date.isAfter(sevenDaysAgo.subtract(const Duration(days: 1)));
  } catch (_) {
    return false;
  }
}

/// Check if a date is within the current week (Mon-Sun).
bool isCurrentWeek(String yyyyMmDd) {
  try {
    final date = DateTime.parse(yyyyMmDd);
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return date.isAfter(monday.subtract(const Duration(days: 1))) &&
        date.isBefore(sunday.add(const Duration(days: 1)));
  } catch (_) {
    return false;
  }
}

/// Check if a date is within last week (Mon-Sun).
bool isLastWeek(String yyyyMmDd) {
  try {
    final date = DateTime.parse(yyyyMmDd);
    final now = DateTime.now();
    final weekday = now.weekday;
    final thisMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));
    final lastSunday = lastMonday.add(const Duration(days: 6));
    return date.isAfter(lastMonday.subtract(const Duration(days: 1))) &&
        date.isBefore(lastSunday.add(const Duration(days: 1)));
  } catch (_) {
    return false;
  }
}

/// Get display label for a date relative to today.
String getDateGroupLabel(String yyyyMmDd) {
  if (isToday(yyyyMmDd)) return '今天';
  if (isYesterday(yyyyMmDd)) return '昨天';
  if (isTomorrow(yyyyMmDd)) return '明天';
  return formatDate(yyyyMmDd);
}

/// Get month group label.
String getMonthGroupLabel(String monthKey) {
  if (monthKey == currentMonthStr()) return '本月';
  return formatMonth(monthKey);
}

/// Group tasks into the top-level date buckets used by the date tab.
String getDateGroupKey(String yyyyMmDd) {
  if (isYesterday(yyyyMmDd) || isToday(yyyyMmDd) || isTomorrow(yyyyMmDd)) {
    return 'day:$yyyyMmDd';
  }
  if (isCurrentWeek(yyyyMmDd)) return 'week:this';
  if (isLastWeek(yyyyMmDd)) return 'week:last';

  final date = _parseDateOnly(yyyyMmDd);
  if (date == null || date.year == _todayOnly().year) {
    return 'bucket-month:${getMonthKey(yyyyMmDd)}';
  }
  return 'year:${date.year}';
}

String dateFromGroupKey(String key) {
  return key.startsWith('day:') ? key.substring(4) : key;
}

String monthFromGroupKey(String key) {
  if (key.startsWith('bucket-month:')) return key.substring(13);
  if (key.startsWith('month:')) return key.substring(6);
  return key;
}

String yearFromGroupKey(String key) {
  return key.startsWith('year:') ? key.substring(5) : key;
}

String getDateGroupTitle(String key) {
  if (key.startsWith('day:')) return getDateGroupLabel(dateFromGroupKey(key));
  if (key == 'week:this') return '本周';
  if (key == 'week:last') return '上周';
  if (key.startsWith('bucket-month:') || key.startsWith('month:')) {
    return formatMonth(monthFromGroupKey(key));
  }
  if (key.startsWith('year:')) return '${yearFromGroupKey(key)}年';
  return key;
}

String getDateGroupSubLabel(String key) {
  if (key.startsWith('day:')) return dateFromGroupKey(key);
  if (key == 'week:this' || key == 'week:last') {
    final now = _todayOnly();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    final start = key == 'week:this'
        ? thisMonday
        : thisMonday.subtract(const Duration(days: 7));
    final end = start.add(const Duration(days: 6));
    final startText = DateFormat('yyyy-MM-dd').format(start);
    final endText = DateFormat('yyyy-MM-dd').format(end);
    return '$startText 至 $endText';
  }
  if (key.startsWith('bucket-month:') || key.startsWith('month:')) {
    return monthFromGroupKey(key);
  }
  if (key.startsWith('year:')) return yearFromGroupKey(key);
  return '';
}

int compareDateGroupKeys(String a, String b) {
  int rank(String key) {
    final yesterdayKey = 'day:${yesterdayStr()}';
    final todayKey = 'day:${todayStr()}';
    final tomorrowKey = 'day:${tomorrowStr()}';
    if (key == yesterdayKey) return 0;
    if (key == todayKey) return 1;
    if (key == tomorrowKey) return 2;
    if (key == 'week:this') return 3;
    if (key == 'week:last') return 4;
    if (key.startsWith('bucket-month:') || key.startsWith('month:')) {
      return 5;
    }
    if (key.startsWith('year:')) return 6;
    return 7;
  }

  final rankA = rank(a);
  final rankB = rank(b);
  if (rankA != rankB) return rankA.compareTo(rankB);
  return b.compareTo(a);
}

/// Format DateTime to Chinese display.
String formatDateTime(DateTime dt) {
  return DateFormat('yyyy年MM月dd日 HH:mm').format(dt);
}

/// Format an ISO datetime string to time only (HH:mm).
String formatIsoTime(String iso) {
  try {
    final dt = DateTime.parse(iso);
    return formatDateTime(dt);
  } catch (_) {
    return iso;
  }
}

/// Format an ISO datetime string to date only (X年X月X日).
String formatIsoDate(String iso) {
  try {
    final dt = DateTime.parse(iso);
    return formatDate(
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}');
  } catch (_) {
    return iso;
  }
}

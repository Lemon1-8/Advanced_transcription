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

/// Check if a date string is in the current month.
bool isCurrentMonth(String yyyyMmDd) {
  return yyyyMmDd.startsWith(currentMonthStr());
}

/// Get month prefix from a date string.
String getMonthKey(String yyyyMmDd) {
  if (yyyyMmDd.length >= 7) return yyyyMmDd.substring(0, 7);
  return yyyyMmDd;
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

/// Get display label for a date relative to today.
String getDateGroupLabel(String yyyyMmDd) {
  if (isToday(yyyyMmDd)) return '今天';
  if (isYesterday(yyyyMmDd)) return '昨天';
  return formatDate(yyyyMmDd);
}

/// Get month group label.
String getMonthGroupLabel(String monthKey) {
  if (monthKey == currentMonthStr()) return '本月';
  return formatMonth(monthKey);
}

/// Group tasks by date prefix (today, yesterday, month).
String getDateGroupKey(String yyyyMmDd) {
  if (isToday(yyyyMmDd)) return 'today';
  if (isYesterday(yyyyMmDd)) return 'yesterday';
  return getMonthKey(yyyyMmDd);
}

/// Format DateTime to Chinese display.
String formatDateTime(DateTime dt) {
  return DateFormat('yyyy年MM月dd日 HH:mm').format(dt);
}

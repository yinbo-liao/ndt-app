import 'package:intl/intl.dart';

/// Date utility helpers for the NDT app.
class DateUtils2 {
  DateUtils2._();

  /// ISO date formatter (yyyy-MM-dd) for Supabase DATE columns.
  static final DateFormat isoDateFormat = DateFormat('yyyy-MM-dd');

  /// ISO datetime formatter for Supabase TIMESTAMPTZ columns.
  static final DateFormat isoDateTimeFormat =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

  /// Display formatter for dates shown in the UI.
  static final DateFormat displayDateFormat = DateFormat('EEE, MMM dd, yyyy');

  /// Display formatter for month/year headers.
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy');

  /// Converts a [DateTime] to an ISO date string (yyyy-MM-dd).
  static String toIsoDate(DateTime date) => isoDateFormat.format(date);

  /// Converts a [DateTime] to an ISO datetime string.
  static String toIsoDateTime(DateTime date) => isoDateTimeFormat.format(date);

  /// Returns the first day of the given month.
  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  /// Returns the first day of the current month.
  static DateTime startOfCurrentMonth() => startOfMonth(DateTime.now());

  /// Returns the start of today (midnight).
  static DateTime startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns the end of today (just before midnight).
  static DateTime endOfToday() =>
      startOfToday().add(const Duration(days: 1));

  /// Returns a date range for the last N days including today.
  static (DateTime start, DateTime end) lastNDays(int days) {
    final end = startOfToday().add(const Duration(days: 1));
    final start = end.subtract(Duration(days: days + 1));
    return (start, end);
  }

  /// Formats a date for display in the UI.
  static String formatDisplay(DateTime date) =>
      displayDateFormat.format(date);

  /// Formats a date as month and year.
  static String formatMonthYear(DateTime date) =>
      monthYearFormat.format(date);

  /// Null-safe date display formatter.
  static String? formatDisplayOrNull(DateTime? date) {
    if (date == null) return null;
    return displayDateFormat.format(date);
  }
}

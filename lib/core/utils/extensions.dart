/// Extension methods for commonly used types.
///
/// {@category Core}
/// {@category Utilities}
library;

// ── DateTime Extensions ─────────────────────────────────────

extension DateTimeExtension on DateTime {
  /// Returns this date as an ISO date string (yyyy-MM-dd).
  String get toIsoDateString {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// Returns this date-time as an ISO datetime string.
  String get toIsoDateTimeString => toUtc().toIso8601String();

  /// Returns the start of the day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns the start of the month.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Returns the first day of the next month.
  DateTime get startOfNextMonth =>
      month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
}

// ── String Extensions ───────────────────────────────────────

extension StringExtension on String {
  /// Capitalizes the first letter of this string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts snake_case to Title Case.
  String get snakeToTitleCase {
    return split('_')
        .map((word) => word.capitalize)
        .join(' ');
  }

  /// Truncates to [maxLength] with an ellipsis if needed.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Returns null if the string is empty after trimming.
  String? get nullIfEmpty => trim().isEmpty ? null : trim();
}

// ── List Extensions ─────────────────────────────────────────

extension ListExtension<T> on List<T> {
  /// Returns a new list with [separator] between each element.
  List<T> separatedBy(T separator) {
    if (isEmpty) return [];
    final result = <T>[first];
    for (var i = 1; i < length; i++) {
      result.add(separator);
      result.add(this[i]);
    }
    return result;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/core/utils/date_utils.dart';

void main() {
  group('DateUtils2', () {
    group('toIsoDate', () {
      test('formats date as yyyy-MM-dd', () {
        final date = DateTime(2026, 6, 15);
        expect(DateUtils2.toIsoDate(date), '2026-06-15');
      });

      test('pads single digits', () {
        final date = DateTime(2026, 1, 5);
        expect(DateUtils2.toIsoDate(date), '2026-01-05');
      });
    });

    group('toIsoDateTime', () {
      test('formats as ISO datetime with Z suffix', () {
        final date = DateTime(2026, 6, 15, 12, 30, 0);
        final result = DateUtils2.toIsoDateTime(date);
        expect(result, contains('2026-06-15'));
        expect(result, endsWith('Z'));
      });
    });

    group('startOfMonth', () {
      test('returns first day of given month', () {
        final result = DateUtils2.startOfMonth(DateTime(2026, 6, 15));
        expect(result, DateTime(2026, 6, 1));
      });

      test('works for January', () {
        final result = DateUtils2.startOfMonth(DateTime(2026, 1, 20));
        expect(result, DateTime(2026, 1, 1));
      });
    });

    group('startOfCurrentMonth', () {
      test('returns first day of current month', () {
        final result = DateUtils2.startOfCurrentMonth();
        final now = DateTime.now();
        expect(result.year, now.year);
        expect(result.month, now.month);
        expect(result.day, 1);
      });
    });

    group('startOfToday', () {
      test('returns midnight of today', () {
        final result = DateUtils2.startOfToday();
        final now = DateTime.now();
        expect(result.year, now.year);
        expect(result.month, now.month);
        expect(result.day, now.day);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
      });
    });

    group('endOfToday', () {
      test('returns start of tomorrow', () {
        final today = DateUtils2.startOfToday();
        final end = DateUtils2.endOfToday();
        expect(end, today.add(const Duration(days: 1)));
      });
    });

    group('lastNDays', () {
      test('returns correct range for last 7 days', () {
        final (start, end) = DateUtils2.lastNDays(7);
        final today = DateUtils2.startOfToday();
        final expectedEnd = today.add(const Duration(days: 1));
        final expectedStart = expectedEnd.subtract(const Duration(days: 8));
        expect(start, expectedStart);
        expect(end, expectedEnd);
      });
    });

    group('formatDisplay', () {
      test('formats date for display', () {
        final date = DateTime(2026, 6, 15);
        final result = DateUtils2.formatDisplay(date);
        // Format: EEE, MMM dd, yyyy
        expect(result, contains('2026'));
        expect(result, contains('Jun'));
      });
    });

    group('formatMonthYear', () {
      test('formats as month and year', () {
        final date = DateTime(2026, 6, 15);
        final result = DateUtils2.formatMonthYear(date);
        expect(result, 'June 2026');
      });
    });

    group('formatDisplayOrNull', () {
      test('returns null for null input', () {
        expect(DateUtils2.formatDisplayOrNull(null), isNull);
      });

      test('formats non-null date for display', () {
        final date = DateTime(2026, 6, 15);
        final result = DateUtils2.formatDisplayOrNull(date);
        expect(result, isNotNull);
        expect(result, contains('2026'));
      });
    });

    group('formatters', () {
      test('isoDateFormat produces yyyy-MM-dd', () {
        expect(
          DateUtils2.isoDateFormat.format(DateTime(2026, 6, 15)),
          '2026-06-15',
        );
      });

      test('displayDateFormat includes day, month, year', () {
        final formatted =
            DateUtils2.displayDateFormat.format(DateTime(2026, 6, 15));
        expect(formatted, isNotEmpty);
      });

      test('monthYearFormat includes month name and year', () {
        final formatted =
            DateUtils2.monthYearFormat.format(DateTime(2026, 6, 1));
        expect(formatted, contains('2026'));
      });
    });
  });
}

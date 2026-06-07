import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/core/utils/extensions.dart';

void main() {
  group('DateTimeExtension', () {
    group('toIsoDateString', () {
      test('formats date as yyyy-MM-dd', () {
        final date = DateTime(2026, 6, 15);
        expect(date.toIsoDateString, '2026-06-15');
      });

      test('pads single-digit month and day', () {
        final date = DateTime(2026, 1, 5);
        expect(date.toIsoDateString, '2026-01-05');
      });

      test('handles year boundary', () {
        final date = DateTime(2025, 12, 31);
        expect(date.toIsoDateString, '2025-12-31');
      });
    });

    group('toIsoDateTimeString', () {
      test('converts to UTC ISO string', () {
        final date = DateTime(2026, 6, 15, 12, 30, 0);
        final result = date.toIsoDateTimeString;
        expect(result, contains('2026-06-15'));
        expect(result, contains('Z')); // UTC marker
      });
    });

    group('startOfDay', () {
      test('returns midnight of the same day', () {
        final date = DateTime(2026, 6, 15, 14, 30, 45);
        final start = date.startOfDay;
        expect(start.year, 2026);
        expect(start.month, 6);
        expect(start.day, 15);
        expect(start.hour, 0);
        expect(start.minute, 0);
        expect(start.second, 0);
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(DateTime.now().isToday, isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday, isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isToday, isFalse);
      });
    });

    group('startOfMonth', () {
      test('returns first day of the month', () {
        final date = DateTime(2026, 6, 15);
        final start = date.startOfMonth;
        expect(start.year, 2026);
        expect(start.month, 6);
        expect(start.day, 1);
      });
    });

    group('startOfNextMonth', () {
      test('returns first day of next month', () {
        final date = DateTime(2026, 6, 15);
        final next = date.startOfNextMonth;
        expect(next.year, 2026);
        expect(next.month, 7);
        expect(next.day, 1);
      });

      test('handles year rollover', () {
        final date = DateTime(2026, 12, 15);
        final next = date.startOfNextMonth;
        expect(next.year, 2027);
        expect(next.month, 1);
        expect(next.day, 1);
      });
    });
  });

  group('StringExtension', () {
    group('capitalize', () {
      test('capitalizes first letter of lowercase string', () {
        expect('hello'.capitalize, 'Hello');
      });

      test('keeps already capitalized string unchanged', () {
        expect('Hello'.capitalize, 'Hello');
      });

      test('handles empty string', () {
        expect(''.capitalize, '');
      });

      test('handles single character', () {
        expect('a'.capitalize, 'A');
      });

      test('does not modify rest of string', () {
        expect('hELLO'.capitalize, 'HELLO');
      });
    });

    group('snakeToTitleCase', () {
      test('converts snake_case to Title Case', () {
        expect('hello_world'.snakeToTitleCase, 'Hello World');
      });

      test('handles single word', () {
        expect('admin'.snakeToTitleCase, 'Admin');
      });

      test('handles multiple underscores', () {
        expect('ndt_company_id'.snakeToTitleCase, 'Ndt Company Id');
      });

      test('handles empty string', () {
        expect(''.snakeToTitleCase, '');
      });
    });

    group('truncate', () {
      test('returns full string when shorter than maxLength', () {
        expect('Hello'.truncate(10), 'Hello');
      });

      test('returns full string when equal to maxLength', () {
        expect('Hello'.truncate(5), 'Hello');
      });

      test('truncates with ellipsis when longer than maxLength', () {
        expect('Hello World'.truncate(5), 'Hello...');
      });
    });

    group('nullIfEmpty', () {
      test('returns null for empty string', () {
        expect(''.nullIfEmpty, isNull);
      });

      test('returns null for whitespace-only string', () {
        expect('   '.nullIfEmpty, isNull);
      });

      test('returns trimmed string for non-empty', () {
        expect('  Hello  '.nullIfEmpty, 'Hello');
      });

      test('returns original string when no trimming needed', () {
        expect('Hello'.nullIfEmpty, 'Hello');
      });
    });
  });

  group('ListExtension', () {
    group('separatedBy', () {
      test('adds separator between elements', () {
        final result = [1, 2, 3].separatedBy(0);
        expect(result, [1, 0, 2, 0, 3]);
      });

      test('returns empty list for empty input', () {
        final result = <int>[].separatedBy(0);
        expect(result, isEmpty);
      });

      test('returns single element unchanged', () {
        final result = [42].separatedBy(0);
        expect(result, [42]);
      });
    });
  });
}

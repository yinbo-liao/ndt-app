import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns null for non-empty value', () {
      expect(Validators.required('Hello'), isNull);
    });

    test('returns error for null value', () {
      expect(
        Validators.required(null),
        'This field is required',
      );
    });

    test('returns error for empty string', () {
      expect(
        Validators.required(''),
        'This field is required',
      );
    });

    test('returns error for whitespace-only string', () {
      expect(
        Validators.required('   '),
        'This field is required',
      );
    });

    test('uses custom field name in error message', () {
      expect(
        Validators.required(null, 'Email'),
        'Email is required',
      );
    });

    test('returns null for value with leading/trailing spaces after trim', () {
      // trim() removes spaces, but then there's still content
      expect(Validators.required('  Hello  '), isNull);
    });
  });

  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns null for email with subdomain', () {
      expect(Validators.email('user@mail.example.com'), isNull);
    });

    test('returns null for email with plus sign', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.email(null), 'Email is required');
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('returns error for missing @ symbol', () {
      expect(
        Validators.email('userexample.com'),
        'Please enter a valid email address',
      );
    });

    test('returns error for missing domain', () {
      expect(
        Validators.email('user@'),
        'Please enter a valid email address',
      );
    });

    test('returns error for missing username', () {
      expect(
        Validators.email('@example.com'),
        'Please enter a valid email address',
      );
    });

    test('returns error for invalid characters', () {
      expect(
        Validators.email('user name@example.com'),
        'Please enter a valid email address',
      );
    });
  });

  group('Validators.phone', () {
    test('returns null for null (phone is optional)', () {
      expect(Validators.phone(null), isNull);
    });

    test('returns null for empty (phone is optional)', () {
      expect(Validators.phone(''), isNull);
    });

    test('returns null for valid phone with country code', () {
      expect(Validators.phone('+6512345678'), isNull);
    });

    test('returns null for valid phone without country code', () {
      expect(Validators.phone('12345678'), isNull);
    });

    test('returns null for phone with spaces', () {
      expect(Validators.phone('+65 1234 5678'), isNull);
    });

    test('returns null for phone with dashes', () {
      expect(Validators.phone('123-456-7890'), isNull);
    });

    test('returns null for phone with parentheses', () {
      expect(Validators.phone('(123) 456-7890'), isNull);
    });

    test('returns error for phone that is too short', () {
      expect(
        Validators.phone('123'),
        'Please enter a valid phone number',
      );
    });

    test('returns error for phone with letters', () {
      expect(
        Validators.phone('123abc4567'),
        'Please enter a valid phone number',
      );
    });
  });

  group('Validators.positiveNumber', () {
    test('returns null for null (optional field)', () {
      expect(Validators.positiveNumber(null), isNull);
    });

    test('returns null for empty (optional field)', () {
      expect(Validators.positiveNumber(''), isNull);
    });

    test('returns null for positive integer', () {
      expect(Validators.positiveNumber('42'), isNull);
    });

    test('returns null for positive decimal', () {
      expect(Validators.positiveNumber('3.14'), isNull);
    });

    test('returns null for zero', () {
      expect(Validators.positiveNumber('0'), isNull);
    });

    test('returns error for negative number', () {
      expect(
        Validators.positiveNumber('-5'),
        'Value must be a positive number',
      );
    });

    test('returns error for non-numeric string', () {
      expect(
        Validators.positiveNumber('abc'),
        'Value must be a positive number',
      );
    });

    test('uses custom field name in error', () {
      expect(
        Validators.positiveNumber('-1', 'Price'),
        'Price must be a positive number',
      );
    });
  });

  group('Validators.futureDate', () {
    test('returns null for null', () {
      expect(Validators.futureDate(null), isNull);
    });

    test('returns null for today', () {
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      expect(Validators.futureDate(startOfToday), isNull);
    });

    test('returns null for future date', () {
      final future = DateTime.now().add(const Duration(days: 30));
      expect(Validators.futureDate(future), isNull);
    });

    test('returns error for past date', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(
        Validators.futureDate(past),
        'Date must be today or in the future',
      );
    });
  });

  group('Validators.dateRange', () {
    test('returns null when start is null', () {
      expect(
        Validators.dateRange(null, DateTime.now()),
        isNull,
      );
    });

    test('returns null when end is null', () {
      expect(
        Validators.dateRange(DateTime.now(), null),
        isNull,
      );
    });

    test('returns null when start is before end', () {
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 6, 30);
      expect(Validators.dateRange(start, end), isNull);
    });

    test('returns null when start equals end', () {
      final date = DateTime(2026, 6, 15);
      expect(Validators.dateRange(date, date), isNull);
    });

    test('returns error when end is before start', () {
      final start = DateTime(2026, 6, 30);
      final end = DateTime(2026, 6, 1);
      expect(
        Validators.dateRange(start, end),
        'End date must be after start date',
      );
    });
  });

  group('Validators.certificateNo', () {
    test('returns null for valid certificate number', () {
      expect(Validators.certificateNo('CERT-UT-001'), isNull);
    });

    test('returns null for certificate with minimum length (3)', () {
      expect(Validators.certificateNo('C01'), isNull);
    });

    test('returns error for null', () {
      expect(
        Validators.certificateNo(null),
        'Certificate number is required',
      );
    });

    test('returns error for empty string', () {
      expect(
        Validators.certificateNo(''),
        'Certificate number is required',
      );
    });

    test('returns error for too short value', () {
      expect(
        Validators.certificateNo('AB'),
        'Certificate number must be at least 3 characters',
      );
    });

    test('returns error for whitespace-only', () {
      expect(
        Validators.certificateNo('   '),
        'Certificate number is required',
      );
    });
  });
}

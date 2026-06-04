/// Form validation utilities for the NDT app.
class Validators {
  Validators._();

  /// Validates that a value is not null or empty after trimming.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates an email address format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a phone number format (simple check).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,20}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates that a numeric value is positive.
  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }

  /// Validates that a date is in the future (or today).
  static String? futureDate(DateTime? value) {
    if (value == null) return null;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    if (value.isBefore(startOfToday)) {
      return 'Date must be today or in the future';
    }
    return null;
  }

  /// Validates that end date is after start date.
  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }
    return null;
  }

  /// Validates a certificate number format.
  static String? certificateNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Certificate number is required';
    }
    if (value.trim().length < 3) {
      return 'Certificate number must be at least 3 characters';
    }
    return null;
  }
}

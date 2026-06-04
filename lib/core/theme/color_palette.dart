import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Semantic color definitions for the NDT app.
///
/// These colors map business concepts (shift types, statuses, priorities)
/// to Material Design colors for consistent visual language.
class ColorPalette {
  ColorPalette._();

  /// Returns the color associated with a shift type.
  static Color forShift(String shift) {
    switch (shift) {
      case 'day':
        return AppTheme.dayShiftColor;
      case 'night':
        return AppTheme.nightShiftColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  /// Returns a MaterialColor-like shade for the given shift background.
  static Color shiftBackground(String shift) {
    switch (shift) {
      case 'day':
        return AppTheme.dayShiftColor.withAlpha(25);
      case 'night':
        return AppTheme.nightShiftColor.withAlpha(25);
      default:
        return AppTheme.primaryColor.withAlpha(25);
    }
  }

  /// Returns the color for a deployment testing status.
  static Color forTestingStatus(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.statusCompleted;
      case 'in_progress':
        return AppTheme.statusInProgress;
      case 'rejected':
        return AppTheme.statusRejected;
      case 'not_started':
        return AppTheme.statusNotStarted;
      default:
        return AppTheme.statusNotStarted;
    }
  }

  /// Returns the color for a planning testing status.
  static Color forPlanningStatus(String status) {
    switch (status) {
      case 'planned':
        return AppTheme.statusPlanned;
      case 'in_progress':
        return AppTheme.statusInProgress;
      case 'completed':
        return AppTheme.statusCompleted;
      case 'rejected':
        return AppTheme.statusRejected;
      case 'on_hold':
        return AppTheme.statusOnHold;
      default:
        return AppTheme.statusPlanned;
    }
  }

  /// Returns the color for a validation status.
  static Color forValidationStatus(String status) {
    switch (status) {
      case 'valid':
        return AppTheme.successColor;
      case 'expired':
        return AppTheme.dangerColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'revoked':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Returns the color for a priority level.
  static Color forPriority(String priority) {
    switch (priority) {
      case 'urgent':
        return AppTheme.dangerColor;
      case 'high':
        return AppTheme.warningColor;
      case 'normal':
        return AppTheme.primaryColor;
      case 'low':
        return Colors.grey;
      default:
        return AppTheme.primaryColor;
    }
  }
}

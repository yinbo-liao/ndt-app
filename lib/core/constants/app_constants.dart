/// Application-wide constants used across the app.
class AppConstants {
  AppConstants._();

  // ── Roles ──────────────────────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleNdtCompany = 'ndt_company';
  static const String roleNdtTeam = 'ndt_team';

  static const List<String> allRoles = [
    roleAdmin,
    roleNdtCompany,
    roleNdtTeam,
  ];

  // ── Validation Statuses ───────────────────────────────────
  static const String statusValid = 'valid';
  static const String statusExpired = 'expired';
  static const String statusPending = 'pending';
  static const String statusRevoked = 'revoked';

  // ── Testing Statuses (Planning) ───────────────────────────
  static const String testingPlanned = 'planned';
  static const String testingInProgress = 'in_progress';
  static const String testingCompleted = 'completed';
  static const String testingRejected = 'rejected';
  static const String testingOnHold = 'on_hold';

  // ── Testing Statuses (Deployment) ──────────────────────────
  static const String deploymentNotStarted = 'not_started';
  static const String deploymentInProgress = 'in_progress';
  static const String deploymentCompleted = 'completed';
  static const String deploymentRejected = 'rejected';

  // ── Shift Types ───────────────────────────────────────────
  static const String shiftDay = 'day';
  static const String shiftNight = 'night';

  // ── Priorities ────────────────────────────────────────────
  static const String priorityLow = 'low';
  static const String priorityNormal = 'normal';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';

  // ── Assignment Roles ──────────────────────────────────────
  static const String assignedSupervisor = 'supervisor';
  static const String assignedTechnician = 'technician';
  static const String assignedInspector = 'inspector';
  static const String assignedHelper = 'helper';

  // ── Assignment Statuses ───────────────────────────────────
  static const String assignmentActive = 'active';
  static const String assignmentCompleted = 'completed';
  static const String assignmentOnHold = 'on_hold';
  static const String assignmentRemoved = 'removed';

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ── Date Limits ───────────────────────────────────────────
  static const int minYear = 2024;
  static const int maxFutureYears = 5;

  // ── Certificate Expiry ────────────────────────────────────
  static const int certificateExpiryWarningDays = 30;
}

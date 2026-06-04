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

  // ── NDT Testing Types ─────────────────────────────────────
  static const String testingUT = 'UT';
  static const String testingMT = 'MT';
  static const String testingPT = 'PT';
  static const String testingRT = 'RT';
  static const String testingVT = 'VT';

  static const List<String> testingTypes = [
    testingUT,
    testingMT,
    testingPT,
    testingRT,
    testingVT,
  ];

  // ── Engineering Disciplines ───────────────────────────────
  static const String disciplineStructure = 'structure';
  static const String disciplinePiping = 'piping';
  static const String disciplineMechanical = 'mechanical';
  static const String disciplineElectrical = 'electrical';

  static const List<String> disciplines = [
    disciplineStructure,
    disciplinePiping,
    disciplineMechanical,
    disciplineElectrical,
  ];

  // ── Working Sectors ───────────────────────────────────────
  static const String sectorMarine = 'marine_section';
  static const String sectorIndustry = 'industry_section';

  static const List<String> workingSectors = [
    sectorMarine,
    sectorIndustry,
  ];

  // ── Accept Statuses ───────────────────────────────────────
  static const String acceptAccept = 'accept';
  static const String acceptReject = 'reject';
  static const String acceptPending = 'pending';

  static const List<String> acceptStatuses = [
    acceptAccept,
    acceptReject,
    acceptPending,
  ];

  // ── Team Deploy Statuses ──────────────────────────────────
  static const String deployNotDeployed = 'not_deployed';
  static const String deployDeployed = 'deployed';
  static const String deployInProgress = 'in_progress';
  static const String deployCompleted = 'completed';

  static const List<String> teamDeployStatuses = [
    deployNotDeployed,
    deployDeployed,
    deployInProgress,
    deployCompleted,
  ];

  // ── Project Classifications ───────────────────────────────
  static const String classMarine = 'marine';
  static const String classIndustrial = 'industrial';
  static const String classOffshore = 'offshore';
  static const String classOnshore = 'onshore';

  static const List<String> classifications = [
    classMarine,
    classIndustrial,
    classOffshore,
    classOnshore,
  ];
}

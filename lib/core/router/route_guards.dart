import '../../core/constants/app_constants.dart';

/// Route guard utilities for role-based access control.
///
/// Use these to conditionally show/hide UI elements
/// and protect feature access based on user role.
class RouteGuards {
  RouteGuards._();

  /// Returns true if the user can access admin features.
  static bool canAccessAdmin(String? role) =>
      role == AppConstants.roleAdmin;

  /// Returns true if the user can access company management features.
  static bool canAccessCompany(String? role) =>
      role == AppConstants.roleAdmin || role == AppConstants.roleNdtCompany;

  /// Returns true if the user can manage deployments (all authenticated roles).
  static bool canManageDeployments(String? role) => role != null;

  /// Returns true if the user can view contractor register.
  static bool canViewContractors(String? role) =>
      role == AppConstants.roleAdmin || role == AppConstants.roleNdtCompany;

  /// Returns true if the user can edit contractor register.
  static bool canEditContractors(String? role) =>
      role == AppConstants.roleNdtCompany;

  /// Returns true if the user can view summaries and charts.
  static bool canViewSummaries(String? role) =>
      role == AppConstants.roleAdmin || role == AppConstants.roleNdtCompany;
}

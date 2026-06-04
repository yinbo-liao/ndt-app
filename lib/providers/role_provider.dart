import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../core/constants/app_constants.dart';

/// The current user's role, defaulting to 'ndt_team' if not set.
final userRoleProvider = Provider<String>((ref) {
  return ref.watch(currentUserRoleProvider) ?? AppConstants.roleNdtTeam;
});

/// Whether the current user is an admin.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == AppConstants.roleAdmin;
});

/// Whether the current user is an NDT company manager.
final isNdtCompanyProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == AppConstants.roleNdtCompany;
});

/// Whether the current user is an NDT team member.
final isNdtTeamProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == AppConstants.roleNdtTeam;
});

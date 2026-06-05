import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../core/services/supabase_client.dart';
import '../../providers/auth_provider.dart';

/// Provides a dedicated SupabaseClient for team-related queries.
final teamSupabaseProvider = Provider<SupabaseClient>(
    (ref) => SupabaseClientWrapper.instance);

/// Provides the [AssignmentRepository] singleton.
final assignmentRepoProvider =
    Provider<AssignmentRepository>((ref) => AssignmentRepository());

/// Team members — fetches all users for the current company.
final teamMembersProvider =
    FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  final client = ref.watch(teamSupabaseProvider);

  var query = client.from(SupabaseClientWrapper.tblUsers).select();
  if (companyId != null) {
    query = query.eq('ndt_company_id', companyId);
  }

  final response = await query.order('full_name');
  return SupabaseClientWrapper.safeList(response)
      .map((json) => UserModel.fromJson(json))
      .toList();
});

/// Team assignments — fetches assignments for the current company.
final teamAssignmentsProvider =
    FutureProvider.autoDispose<List<AssignmentModel>>((ref) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];

  final repo = ref.watch(assignmentRepoProvider);
  return repo.getByCompany(companyId);
});

/// Fetch projects the current team member is assigned to.
final myAssignedProjectsProvider =
    FutureProvider.autoDispose<List<AssignmentModel>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];

  final repo = ref.watch(assignmentRepoProvider);
  return repo.getByUser(userId);
});

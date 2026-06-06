import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/planning_model.dart';
import '../../data/repositories/planning_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

/// Provides the [PlanningRepository] singleton.
final planningRepositoryProvider =
    Provider<PlanningRepository>((ref) => PlanningRepository());

/// Fetch planning entries for a specific project.
/// When projectId is empty, falls back to company-scoped or admin-all view.
final planningByProjectProvider = FutureProvider.autoDispose
    .family<List<PlanningModel>, String>((ref, projectId) async {
  final repository = ref.watch(planningRepositoryProvider);

  if (projectId.isEmpty) {
    // No project filter — admin sees all, others see their company's
    final isAdmin = ref.watch(isAdminProvider);
    if (isAdmin) return repository.getAll();

    final companyId = ref.watch(currentUserCompanyIdProvider);
    if (companyId == null) return [];
    return repository.getByCompany(companyId);
  }

  return repository.getByProject(projectId);
});

/// Fetch planning entries for the current user's company.
final planningByCompanyProvider =
    FutureProvider.autoDispose<List<PlanningModel>>((ref) async {
  final repository = ref.watch(planningRepositoryProvider);
  final isAdmin = ref.watch(isAdminProvider);

  if (isAdmin) return repository.getAll();

  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];
  return repository.getByCompany(companyId);
});

/// Fetch a single planning entry by ID.
final planningDetailProvider = FutureProvider.autoDispose
    .family<PlanningModel?, String>((ref, planningId) async {
  final repository = ref.watch(planningRepositoryProvider);
  return repository.getById(planningId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/planning_model.dart';
import '../../data/repositories/planning_repository.dart';
import '../../providers/auth_provider.dart';

/// Provides the [PlanningRepository] singleton.
final planningRepositoryProvider =
    Provider<PlanningRepository>((ref) => PlanningRepository());

/// Fetch planning entries for a specific project.
final planningByProjectProvider = FutureProvider.autoDispose
    .family<List<PlanningModel>, String>((ref, projectId) async {
  final repository = ref.watch(planningRepositoryProvider);
  return repository.getByProject(projectId);
});

/// Fetch planning entries for the current user's company.
final planningByCompanyProvider =
    FutureProvider.autoDispose<List<PlanningModel>>((ref) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];

  final repository = ref.watch(planningRepositoryProvider);
  return repository.getByCompany(companyId);
});

/// Fetch a single planning entry by ID.
final planningDetailProvider = FutureProvider.autoDispose
    .family<PlanningModel?, String>((ref, planningId) async {
  final repository = ref.watch(planningRepositoryProvider);
  return repository.getById(planningId);
});

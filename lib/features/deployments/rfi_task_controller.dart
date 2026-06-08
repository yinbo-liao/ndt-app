import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/professional_assignment_model.dart';
import '../../data/repositories/professional_assignment_repository.dart';

/// Provides the [ProfessionalAssignmentRepository] singleton for RFI tasks.
final rfiTaskAssignmentRepoProvider = Provider<ProfessionalAssignmentRepository>(
    (ref) => ProfessionalAssignmentRepository());

/// Fetch professional assignments for a specific planning/RFI entry.
final assignmentsByPlanningProvider = FutureProvider.autoDispose
    .family<List<ProfessionalAssignmentModel>, String>(
        (ref, planningId) async {
  final repo = ref.watch(rfiTaskAssignmentRepoProvider);
  return repo.getByPlanning(planningId);
});

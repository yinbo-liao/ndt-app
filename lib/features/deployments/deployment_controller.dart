import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/deployment_model.dart';
import '../../data/repositories/deployment_repository.dart';
import '../../providers/auth_provider.dart';

/// Provides the [DeploymentRepository] singleton.
final deploymentRepositoryProvider =
    Provider<DeploymentRepository>((ref) => DeploymentRepository());

/// Fetch today's deployments for the current user's company.
final todayDeploymentsProvider =
    FutureProvider.autoDispose<List<DeploymentModel>>((ref) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  final repository = ref.watch(deploymentRepositoryProvider);
  return repository.getTodayDeployments(companyId: companyId);
});

/// Filter parameters for deployments.
class DeploymentFilterParams {
  final DateTime startDate;
  final DateTime endDate;
  final String? companyId;
  final ShiftType? shift;

  const DeploymentFilterParams({
    required this.startDate,
    required this.endDate,
    this.companyId,
    this.shift,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentFilterParams &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          companyId == other.companyId &&
          shift == other.shift;

  @override
  int get hashCode => Object.hash(startDate, endDate, companyId, shift);
}

/// Fetch deployments filtered by date range and optional filters.
final deploymentsByDateRangeProvider = FutureProvider.autoDispose
    .family<List<DeploymentModel>, DeploymentFilterParams>(
        (ref, filter) async {
  final repository = ref.watch(deploymentRepositoryProvider);
  return repository.getByDateRange(
    startDate: filter.startDate,
    endDate: filter.endDate,
    companyId: filter.companyId,
    shift: filter.shift,
  );
});

/// Selected date for the deployment list.
final selectedDeploymentDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

/// Selected shift filter for deployments.
final selectedShiftFilterProvider =
    StateProvider<ShiftType?>((ref) => null);

/// Fetch all deployments (admin only — no company filter).
final allDeploymentsProvider =
    FutureProvider.autoDispose<List<DeploymentModel>>((ref) async {
  final repository = ref.watch(deploymentRepositoryProvider);
  return repository.getAll();
});

/// Fetch a single deployment by ID.
final deploymentDetailProvider = FutureProvider.autoDispose
    .family<DeploymentModel?, String>((ref, deploymentId) async {
  final repository = ref.watch(deploymentRepositoryProvider);
  return repository.getById(deploymentId);
});

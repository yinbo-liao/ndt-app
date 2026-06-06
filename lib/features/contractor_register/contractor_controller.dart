import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/contractor_model.dart';
import '../../data/repositories/contractor_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../summaries/summary_controller.dart';

/// Provides the [ContractorRepository] singleton.
final contractorRepositoryProvider =
    Provider<ContractorRepository>((ref) => ContractorRepository());

/// Fetch all contractors. Admin sees all records; others see their company's.
final contractorsProvider =
    FutureProvider.autoDispose<List<ContractorModel>>((ref) async {
  final repository = ref.watch(contractorRepositoryProvider);
  final isAdmin = ref.watch(isAdminProvider);

  if (isAdmin) {
    return repository.getAll();
  }

  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];
  return repository.getByCompany(companyId);
});

/// Fetch contractors for a specific month. Admin sees all; others scoped.
final contractorsByMonthProvider = FutureProvider.autoDispose
    .family<List<ContractorModel>, DateTime>((ref, monthStart) async {
  final repository = ref.watch(contractorRepositoryProvider);
  final isAdmin = ref.watch(isAdminProvider);

  if (isAdmin) {
    return repository.getByMonth(monthStart);
  }

  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];
  return repository.getByCompanyAndMonth(
    companyId: companyId,
    monthStart: monthStart,
  );
});

/// Provider for the contractor summary RPC call. Admin skips (company-scoped).
final contractorSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, DateTime>((ref, monthStart) async {
  final isAdmin = ref.watch(isAdminProvider);
  if (isAdmin) return null;

  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return null;

  final repository = ref.watch(unifiedSummaryRepoProvider);
  return repository.getContractorSummary(
    companyId: companyId,
    monthStart: monthStart,
  );
});

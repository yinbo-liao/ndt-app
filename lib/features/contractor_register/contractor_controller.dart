import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/contractor_model.dart';
import '../../data/repositories/contractor_repository.dart';
import '../../providers/auth_provider.dart';
import '../summaries/summary_controller.dart';

/// Provides the [ContractorRepository] singleton.
final contractorRepositoryProvider =
    Provider<ContractorRepository>((ref) => ContractorRepository());

/// Fetch contractors for the current user's company.
final contractorsProvider =
    FutureProvider.autoDispose<List<ContractorModel>>((ref) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];

  final repository = ref.watch(contractorRepositoryProvider);
  return repository.getByCompany(companyId);
});

/// Fetch contractors for a specific company and month.
final contractorsByMonthProvider = FutureProvider.autoDispose
    .family<List<ContractorModel>, DateTime>((ref, monthStart) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];

  final repository = ref.watch(contractorRepositoryProvider);
  return repository.getByCompanyAndMonth(
    companyId: companyId,
    monthStart: monthStart,
  );
});

/// Provider for the contractor summary RPC call.
final contractorSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, DateTime>((ref, monthStart) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return null;

  final repository = ref.watch(unifiedSummaryRepoProvider);
  return repository.getContractorSummary(
    companyId: companyId,
    monthStart: monthStart,
  );
});

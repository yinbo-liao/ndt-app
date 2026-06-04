import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/professional_model.dart';
import '../../data/repositories/professional_repository.dart';
import '../../providers/auth_provider.dart';

/// Provides the [ProfessionalRepository] singleton.
final professionalRepoProvider =
    Provider<ProfessionalRepository>((ref) => ProfessionalRepository());

/// Fetch all professionals for the current user's company.
final professionalsProvider =
    FutureProvider.autoDispose<List<ProfessionalModel>>((ref) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];

  final repository = ref.watch(professionalRepoProvider);
  return repository.getByCompany(companyId);
});

/// Fetch professionals by working sector for the current company.
final professionalsBySectorProvider = FutureProvider.autoDispose
    .family<List<ProfessionalModel>, String>((ref, sector) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];

  final repository = ref.watch(professionalRepoProvider);
  return repository.getByCompanyAndSector(
    companyId: companyId,
    workingSector: sector,
  );
});

/// Fetch professionals by certification status.
final professionalsByStatusProvider = FutureProvider.autoDispose
    .family<List<ProfessionalModel>, String>((ref, status) async {
  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];

  final repository = ref.watch(professionalRepoProvider);
  return repository.getByStatus(
    companyId: companyId,
    certificateStatus: status,
  );
});

/// Fetch a single professional by ID.
final professionalDetailProvider = FutureProvider.autoDispose
    .family<ProfessionalModel?, String>((ref, id) async {
  final repository = ref.watch(professionalRepoProvider);
  return repository.getById(id);
});

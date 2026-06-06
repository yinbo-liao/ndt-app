import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/professional_model.dart';
import '../../data/repositories/professional_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

/// Provides the [ProfessionalRepository] singleton.
final professionalRepoProvider =
    Provider<ProfessionalRepository>((ref) => ProfessionalRepository());

/// Fetch all professionals. Admin sees all records; others see their company's.
final professionalsProvider =
    FutureProvider.autoDispose<List<ProfessionalModel>>((ref) async {
  final repository = ref.watch(professionalRepoProvider);
  final isAdmin = ref.watch(isAdminProvider);

  if (isAdmin) {
    return repository.getAll();
  }

  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];
  return repository.getByCompany(companyId);
});

/// Fetch professionals by working sector. Admin sees all; others scoped.
final professionalsBySectorProvider = FutureProvider.autoDispose
    .family<List<ProfessionalModel>, String>((ref, sector) async {
  final repository = ref.watch(professionalRepoProvider);
  final isAdmin = ref.watch(isAdminProvider);

  if (isAdmin) {
    return repository.getAllBySector(sector);
  }

  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];
  return repository.getByCompanyAndSector(
    companyId: companyId,
    workingSector: sector,
  );
});

/// Fetch professionals by certification status. Admin sees all; others scoped.
final professionalsByStatusProvider = FutureProvider.autoDispose
    .family<List<ProfessionalModel>, String>((ref, status) async {
  final repository = ref.watch(professionalRepoProvider);
  final isAdmin = ref.watch(isAdminProvider);

  if (isAdmin) {
    return repository.getAllByStatus(status);
  }

  final companyId = ref.watch(currentUserCompanyIdProvider);
  if (companyId == null) return [];
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

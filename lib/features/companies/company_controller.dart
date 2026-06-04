import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/company_repository.dart';

/// Provides the [CompanyRepository] singleton.
final companyRepoProvider =
    Provider<CompanyRepository>((ref) => CompanyRepository());

/// Fetch all companies.
final allCompaniesProvider =
    FutureProvider.autoDispose<List<CompanyModel>>((ref) async {
  final repo = ref.watch(companyRepoProvider);
  return repo.getAll(activeOnly: false);
});

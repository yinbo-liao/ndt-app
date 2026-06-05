import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/repositories/audit_repository.dart';

/// Provides the [AuditRepository] singleton.
final auditRepoProvider =
    Provider<AuditRepository>((ref) => AuditRepository());

/// Fetch audit logs.
final auditLogsProvider =
    FutureProvider.autoDispose<List<AuditLogModel>>((ref) async {
  final repo = ref.watch(auditRepoProvider);
  return repo.getAll();
});

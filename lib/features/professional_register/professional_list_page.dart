import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/professional_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'professional_controller.dart';

/// List page for NDT Professional Register.
///
/// Displays professionals for the current company with filtering
/// by working sector and certification status.
class ProfessionalListPage extends ConsumerStatefulWidget {
  const ProfessionalListPage({super.key});

  @override
  ConsumerState<ProfessionalListPage> createState() =>
      _ProfessionalListPageState();
}

class _ProfessionalListPageState
    extends ConsumerState<ProfessionalListPage> {
  String? _sectorFilter;
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final professionalsAsync = ref.watch(professionalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT Professionals'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-professional',
        onPressed: () => context.push('/professionals/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Sector filter chips
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Sectors'),
                  selected: _sectorFilter == null,
                  onSelected: (_) =>
                      setState(() => _sectorFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Marine'),
                  selected:
                      _sectorFilter == AppConstants.sectorMarine,
                  onSelected: (_) => setState(
                      () => _sectorFilter = AppConstants.sectorMarine),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Industry'),
                  selected:
                      _sectorFilter == AppConstants.sectorIndustry,
                  onSelected: (_) => setState(() =>
                      _sectorFilter = AppConstants.sectorIndustry),
                ),
              ],
            ),
          ),
          // Status filter chips
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Status'),
                  selected: _statusFilter == null,
                  onSelected: (_) =>
                      setState(() => _statusFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Valid'),
                  selected: _statusFilter == 'valid',
                  avatar: const Icon(Icons.check_circle,
                      size: 16, color: Colors.green),
                  onSelected: (_) =>
                      setState(() => _statusFilter = 'valid'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Expired'),
                  selected: _statusFilter == 'expired',
                  avatar: const Icon(Icons.error,
                      size: 16, color: Colors.red),
                  onSelected: (_) =>
                      setState(() => _statusFilter = 'expired'),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: professionalsAsync.when(
              data: (professionals) {
                var filtered = professionals;
                if (_sectorFilter != null) {
                  filtered = filtered
                      .where((p) =>
                          p.workingSector == _sectorFilter)
                      .toList();
                }
                if (_statusFilter != null) {
                  filtered = filtered
                      .where((p) =>
                          p.certificateStatus == _statusFilter)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return const EmptyState(
                    message: 'No professionals found',
                    icon: Icons.person_search,
                    actionLabel: 'Add Professional',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(professionalsProvider),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _ProfessionalTile(
                            professional: filtered[index]),
                  ),
                );
              },
              loading: () => const LoadingIndicator(
                  message: 'Loading professionals...'),
              error: (error, st) => AppErrorWidget(
                message: 'Failed to load: $error',
                onRetry: () =>
                    ref.invalidate(professionalsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalTile extends ConsumerWidget {
  final ProfessionalModel professional;
  const _ProfessionalTile({required this.professional});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpired =
        professional.certificateStatus == 'expired';
    final isExpiring = professional.isExpiringSoon;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isExpired ? Colors.red.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpired
              ? Colors.red.withAlpha(30)
              : Colors.blue.withAlpha(30),
          child: Icon(
            Icons.person,
            color: isExpired ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          professional.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${professional.typeOfCertificate} · '
                '${professional.sectorLabel}'),
            if (professional.certifiedBy != null)
              Text(
                'Certified by: ${professional.certifiedBy}',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExpiring)
              const Tooltip(
                message: 'Expiring soon',
                child: Icon(Icons.warning_amber,
                    color: Colors.orange, size: 18),
              ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              tooltip: 'Edit professional',
              onPressed: () =>
                  context.push('/professionals/${professional.id}/edit'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isExpired
                    ? Colors.red.withAlpha(25)
                    : Colors.green.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                professional.certificateStatus.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isExpired ? Colors.red : Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context
            .push('/professionals/${professional.id}'),
      ),
    );
  }
}

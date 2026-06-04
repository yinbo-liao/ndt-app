import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/professional_model.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import 'professional_controller.dart';

/// Detail page for a single NDT Professional.
class ProfessionalDetailPage extends ConsumerWidget {
  final String professionalId;

  const ProfessionalDetailPage({
    super.key,
    required this.professionalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(professionalDetailProvider(professionalId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => context.push(
                '/professionals/$professionalId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (professional) {
          if (professional == null) {
            return const AppErrorWidget(
                message: 'Professional not found');
          }
          return _DetailContent(professional: professional);
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading details...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load: $error',
          onRetry: () => ref
              .invalidate(professionalDetailProvider(professionalId)),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Professional'),
        content: const Text(
            'This will soft-delete the professional record. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(professionalRepoProvider)
                  .softDelete(professionalId);
              if (context.mounted) {
                ref.invalidate(professionalsProvider);
                ref.invalidate(
                    professionalDetailProvider(professionalId));
                if (context.canPop()) context.pop();
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ProfessionalModel professional;
  const _DetailContent({required this.professional});

  @override
  Widget build(BuildContext context) {
    final isExpired =
        professional.certificateStatus == 'expired';
    final daysLeft =
        professional.expiryDate.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isExpired
                        ? Colors.red.withAlpha(30)
                        : Colors.blue.withAlpha(30),
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: isExpired ? Colors.red : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    professional.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${professional.typeOfCertificate} · '
                    '${professional.sectorLabel}',
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _statusBadge(professional.certificateStatus),
                  if (professional.isExpiringSoon)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Expires in $daysLeft days',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Certificate',
                  value: professional.typeOfCertificate,
                  icon: Icons.verified,
                  iconColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Sector',
                  value: professional.sectorLabel,
                  icon: Icons.category,
                  iconColor: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Certificate Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                  _detailRow('Issued Date',
                      professional.issuedDate.toIso8601String().split('T')[0]),
                  _detailRow('Expiry Date',
                      professional.expiryDate.toIso8601String().split('T')[0]),
                  if (professional.certifiedBy != null)
                    _detailRow('Certified By', professional.certifiedBy!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'valid':
        color = Colors.green;
        break;
      case 'expired':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'revoked':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

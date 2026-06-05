import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/summary_card.dart';
import '../../providers/auth_provider.dart';
import 'summary_controller.dart';

/// Professional register summary page.
///
/// Displays compliance statistics for NDT professionals linked
/// to the current user's company via the professional_register_summary RPC.
class ProfessionalSummaryPage extends ConsumerWidget {
  const ProfessionalSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(currentUserCompanyIdProvider);

    if (companyId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Professional Summary')),
        body: const Center(child: Text('No company assigned')),
      );
    }

    final summaryAsync = ref.watch(professionalSummaryProvider(companyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Professional Summary')),
      body: summaryAsync.when(
        data: (summary) {
          if (summary == null) {
            return const EmptyState(
              message: 'No professional register data available',
              icon: Icons.people_outline,
            );
          }

          final total = (summary['total'] as num?)?.toInt() ?? 0;
          final validCount = (summary['valid_count'] as num?)?.toInt() ?? 0;
          final expiredCount =
              (summary['expired_count'] as num?)?.toInt() ?? 0;
          final pendingCount =
              (summary['pending_count'] as num?)?.toInt() ?? 0;
          final revokedCount =
              (summary['revoked_count'] as num?)?.toInt() ?? 0;
          final marineCount =
              (summary['marine_count'] as num?)?.toInt() ?? 0;
          final industryCount =
              (summary['industry_count'] as num?)?.toInt() ?? 0;
          final expiringSoon =
              (summary['expiring_soon'] as num?)?.toInt() ?? 0;
          final complianceRate =
              (summary['compliance_rate'] as num?)?.toDouble() ?? 0.0;

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(professionalSummaryProvider(companyId)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Professional Register Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total professionals: $total',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      SummaryCard(
                        title: 'Valid',
                        value: validCount.toString(),
                        icon: Icons.verified,
                        color: Colors.green,
                      ),
                      SummaryCard(
                        title: 'Expired',
                        value: expiredCount.toString(),
                        icon: Icons.warning_amber,
                        color: Colors.red,
                      ),
                      SummaryCard(
                        title: 'Pending',
                        value: pendingCount.toString(),
                        icon: Icons.hourglass_empty,
                        color: Colors.orange,
                      ),
                      SummaryCard(
                        title: 'Revoked',
                        value: revokedCount.toString(),
                        icon: Icons.cancel,
                        color: Colors.red.shade700,
                      ),
                      SummaryCard(
                        title: 'Marine Sector',
                        value: marineCount.toString(),
                        icon: Icons.directions_boat,
                        color: Colors.blue,
                      ),
                      SummaryCard(
                        title: 'Industry Sector',
                        value: industryCount.toString(),
                        icon: Icons.factory,
                        color: Colors.indigo,
                      ),
                      SummaryCard(
                        title: 'Expiring Soon',
                        value: expiringSoon.toString(),
                        icon: Icons.schedule,
                        color: Colors.orange.shade700,
                      ),
                      SummaryCard(
                        title: 'Compliance Rate',
                        value: '${complianceRate.toStringAsFixed(1)}%',
                        icon: Icons.trending_up,
                        color:
                            complianceRate >= 80 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading professional summary...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load: $error',
          onRetry: () =>
              ref.invalidate(professionalSummaryProvider(companyId)),
        ),
      ),
    );
  }
}

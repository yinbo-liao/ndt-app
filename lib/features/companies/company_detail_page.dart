import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/company_repository.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';

/// Detail page for an NDT Company / Contractor.
///
/// Shows company info, address, supervisor, and linked items count.
class CompanyDetailPage extends ConsumerStatefulWidget {
  final String companyId;

  const CompanyDetailPage({super.key, required this.companyId});

  @override
  ConsumerState<CompanyDetailPage> createState() =>
      _CompanyDetailPageState();
}

class _CompanyDetailPageState extends ConsumerState<CompanyDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company Detail')),
      body: FutureBuilder(
        future: CompanyRepository().getById(widget.companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading company...');
          }
          if (snapshot.hasError || snapshot.data == null) {
            return AppErrorWidget(
              message: 'Company not found',
              onRetry: () => setState(() {}),
            );
          }

          final company = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.blue.withAlpha(30),
                          child: const Icon(Icons.business,
                              size: 36, color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        Text(company.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        if (company.registrationNo != null) ...[
                          const SizedBox(height: 4),
                          Text('Reg: ${company.registrationNo}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const Divider(),
                        _infoRow('Contact Email', company.contactEmail),
                        _infoRow('Contact Phone', company.contactPhone),
                        _infoRow('Address', company.address),
                        _infoRow('Supervisor', company.supervisor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const Divider(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: company.active
                                    ? Colors.green.withAlpha(25)
                                    : Colors.red.withAlpha(25),
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                    color: company.active
                                        ? Colors.green
                                            .withAlpha(100)
                                        : Colors.red.withAlpha(100)),
                              ),
                              child: Text(
                                company.active ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  color: company.active
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value ?? '—',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

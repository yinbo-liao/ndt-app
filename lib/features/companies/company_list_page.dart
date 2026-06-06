import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/company_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'company_controller.dart';

/// List page for NDT Companies.
class CompanyListPage extends ConsumerWidget {
  const CompanyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(allCompaniesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('NDT Companies')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-company',
        onPressed: () => context.push('/companies/create'),
        child: const Icon(Icons.add),
      ),
      body: companiesAsync.when(
        data: (companies) {
          if (companies.isEmpty) {
            return const EmptyState(
              message: 'No companies found',
              icon: Icons.business_outlined,
              actionLabel: 'Add Company',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allCompaniesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: companies.length,
              itemBuilder: (_, i) => _CompanyTile(company: companies[i]),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading companies...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load: $e',
          onRetry: () => ref.invalidate(allCompaniesProvider),
        ),
      ),
    );
  }
}

class _CompanyTile extends ConsumerWidget {
  final CompanyModel company;
  const _CompanyTile({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withAlpha(30),
          child: const Icon(Icons.business, color: Colors.blue),
        ),
        title: Text(company.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(company.registrationNo ?? 'No registration'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => context.push('/companies/${company.id}/edit'),
            ),
            company.active
                ? const Chip(label: Text('Active', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white))
                : const Chip(label: Text('Inactive', style: TextStyle(fontSize: 10))),
          ],
        ),
      ),
    );
  }
}

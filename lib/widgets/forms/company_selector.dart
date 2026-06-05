import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/company_repository.dart';
import '../../features/summaries/summary_controller.dart';

/// A dropdown that lets admin users pick a company for report viewing.
///
/// Reads [selectedReportCompanyIdProvider] — when the user picks a company,
/// it updates that provider so all report pages react.
class CompanySelectorWidget extends ConsumerStatefulWidget {
  final String? initialCompanyId;

  const CompanySelectorWidget({super.key, this.initialCompanyId});

  @override
  ConsumerState<CompanySelectorWidget> createState() =>
      _CompanySelectorWidgetState();
}

class _CompanySelectorWidgetState extends ConsumerState<CompanySelectorWidget> {
  List<CompanyModel> _companies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final repo = CompanyRepository();
      final list = await repo.getAll();
      if (mounted) setState(() { _companies = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedReportCompanyIdProvider);

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_companies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No companies found in the database.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey(selectedId),
        initialValue: selectedId,
        decoration: const InputDecoration(
          labelText: 'Select Company',
          prefixIcon: Icon(Icons.business),
          border: OutlineInputBorder(),
        ),
        hint: const Text('Choose a company to view reports'),
        items: _companies
            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
            .toList(),
        onChanged: (v) {
          ref.read(selectedReportCompanyIdProvider.notifier).state = v;
        },
      ),
    );
  }
}

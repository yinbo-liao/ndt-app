import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/contractor_model.dart';
import '../../data/dto/contractor_dto.dart';
import '../../core/theme/color_palette.dart';
import '../../core/utils/extensions.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'contractor_controller.dart';
import 'contractor_form_page.dart';

/// List page for NDT Contractor Register entries.
///
/// Displays a DataTable with columns for NDT type, certificate info,
/// dates, and status. Expired entries (expire_date < today) are
/// highlighted with a light red row background.
class ContractorListPage extends ConsumerStatefulWidget {
  const ContractorListPage({super.key});

  @override
  ConsumerState<ContractorListPage> createState() =>
      _ContractorListPageState();
}

class _ContractorListPageState extends ConsumerState<ContractorListPage> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final contractorsAsync =
        ref.watch(contractorsByMonthDtoProvider(_selectedMonth));
    final summaryAsync =
        ref.watch(contractorSummaryProvider(_selectedMonth));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Register'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-contractor',
        onPressed: () => context.push('/professional-register/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Month Filter ──────────────────────────────────
          _buildMonthFilter(),
          // ── Summary Row ───────────────────────────────────
          summaryAsync.when(
            data: (summary) => _buildSummaryRow(summary),
            loading: () => const SizedBox(height: 8),
            error: (_, __) => const SizedBox(height: 8),
          ),
          // ── Data Table ────────────────────────────────────
          Expanded(
            child: contractorsAsync.when(
              data: (contractors) {
                if (contractors.isEmpty) {
                  return const EmptyState(
                    message: 'No contractors registered yet',
                    icon: Icons.assignment_outlined,
                    actionLabel: 'Add Contractor',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(
                      contractorsByMonthDtoProvider(
                          _selectedMonth)),
                  child: _buildDataTable(contractors),
                );
              },
              loading: () =>
                  const LoadingIndicator(message: 'Loading contractors...'),
              error: (error, st) => AppErrorWidget(
                message: 'Failed to load: $error',
                onRetry: () =>
                    ref.invalidate(contractorsByMonthDtoProvider(_selectedMonth)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthFilter() {
    final monthLabel =
        '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            tooltip: 'Previous month',
          ),
          Text(
            monthLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(Map<String, dynamic>? summary) {
    if (summary == null) return const SizedBox(height: 8);
    final total = (summary['total'] as num?)?.toInt() ?? 0;
    final valid = (summary['valid_count'] as num?)?.toInt() ?? 0;
    final expired = (summary['expired_count'] as num?)?.toInt() ?? 0;
    final expiringSoon =
        (summary['expiring_soon'] as num?)?.toInt() ?? 0;
    final compliance =
        (summary['compliance_rate'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _summaryChip('Total', '$total', Colors.blue),
          const SizedBox(width: 8),
          _summaryChip('Valid', '$valid', Colors.green),
          const SizedBox(width: 8),
          _summaryChip('Expired', '$expired', Colors.red),
          const SizedBox(width: 8),
          _summaryChip('Expiring', '$expiringSoon', Colors.orange),
          const SizedBox(width: 8),
          _summaryChip(
              'Compliance', '${compliance.toStringAsFixed(1)}%',
              compliance > 80 ? Colors.green : Colors.orange),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withAlpha(40),
        radius: 10,
        child: Text(
          value,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildDataTable(List<ContractorDTO> dtos) {
    final today = DateTime.now();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            const Color(0xFF1A56DB).withAlpha(15),
          ),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
          columns: const [
            DataColumn(label: Text('NDT Type', style: _headerStyle)),
            DataColumn(label: Text('Certificate', style: _headerStyle)),
            DataColumn(label: Text('Cert No', style: _headerStyle)),
            DataColumn(label: Text('Technician Name', style: _headerStyle)),
            DataColumn(label: Text('Company', style: _headerStyle)),
            DataColumn(label: Text('NDT Professional Name', style: _headerStyle)),
            DataColumn(label: Text('Tech ID', style: _headerStyle)),
            DataColumn(label: Text('Issue Date', style: _headerStyle)),
            DataColumn(label: Text('Expire Date', style: _headerStyle)),
            DataColumn(label: Text('Status', style: _headerStyle)),
            DataColumn(label: Text('', style: _headerStyle)),
          ],
          rows: dtos.map((dto) {
            final c = dto.contractor;
            final isExpired = c.expireDate.isBefore(today);
            final isExpiring = c.isExpiringSoon;
            return DataRow(
              color: isExpired
                  ? const WidgetStatePropertyAll(Color(0xFFFFEBEE))
                  : null,
              onSelectChanged: (_) => _openDetail(c),
              cells: [
                DataCell(Text(c.typeOfNdt)),
                DataCell(Text(c.typeOfNdtCertificate)),
                DataCell(Text(c.certificateNo)),
                DataCell(Text(c.technicianName ?? '—',
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(dto.companyLabel,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[700]))),
                DataCell(Text(dto.professionalLabel,
                    style: TextStyle(fontSize: 12))),
                DataCell(Text(c.techId ?? '—',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13))),
                DataCell(Text(c.issueDate.toIsoDateString)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.expireDate.toIsoDateString),
                      if (isExpiring) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.warning_amber,
                            size: 16, color: Colors.orange[700]),
                      ],
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorPalette.forValidationStatus(
                              c.validationStatus)
                          .withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorPalette.forValidationStatus(
                            c.validationStatus),
                      ),
                    ),
                    child: Text(
                      c.validationStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.forValidationStatus(
                            c.validationStatus),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit contractor',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ContractorFormPage(existing: c),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          ref.invalidate(contractorsByMonthDtoProvider);
                          ref.invalidate(contractorsProvider);
                          ref.invalidate(contractorsByMonthProvider);
                        }
                      });
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openDetail(ContractorModel contractor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ContractorDetailWrapper(contractor: contractor),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month];
  }

  static const _headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: Color(0xFF1A56DB),
  );
}

// ─────────────────────────────────────────────────────────────
// Detail wrapper that provides Riverpod context for the detail
// page's edit/delete operations.
// ─────────────────────────────────────────────────────────────

class _ContractorDetailWrapper extends ConsumerWidget {
  final ContractorModel contractor;

  const _ContractorDetailWrapper({required this.contractor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(contractorRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(contractor.typeOfNdt),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.pop(context);
              context.push('/professional-register/${contractor.id}/edit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Contractor'),
                  content: const Text(
                    'This will soft-delete this contractor record.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await repository.softDelete(contractor.id);
                if (context.mounted) {
                  ref.invalidate(contractorsProvider);
                  ref.invalidate(contractorsByMonthProvider);
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorPalette.forValidationStatus(
                        contractor.validationStatus)
                    .withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorPalette.forValidationStatus(
                      contractor.validationStatus),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    contractor.validationStatus == 'valid'
                        ? Icons.check_circle
                        : Icons.warning,
                    color: ColorPalette.forValidationStatus(
                        contractor.validationStatus),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Status: ${contractor.validationStatus.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.forValidationStatus(
                          contractor.validationStatus),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _statTile('Certificate No', contractor.certificateNo,
                Icons.badge),
            _statTile('Certificate issued by',
                contractor.certificateType ?? 'N/A', Icons.class_),
            _statTile('Issue Date',
                contractor.issueDate.toIsoDateString, Icons.event),
            _statTile(
              'Expiry Date',
              contractor.expireDate.toIsoDateString,
              contractor.isExpiringSoon
                  ? Icons.warning_amber
                  : Icons.event_available,
              iconColor:
                  contractor.isExpiringSoon ? Colors.orange : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(
    String label,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF1A56DB)),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        subtitle: Text(value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

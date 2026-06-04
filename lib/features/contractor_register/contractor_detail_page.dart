import 'package:flutter/material.dart';
import '../../data/models/contractor_model.dart';
import '../../core/theme/color_palette.dart';
import '../../core/utils/extensions.dart';
import '../../widgets/cards/stat_card.dart';

/// Detail page showing a contractor register entry.
class ContractorDetailPage extends StatelessWidget {
  final ContractorModel contractor;

  const ContractorDetailPage({super.key, required this.contractor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contractor.typeOfNdt),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit form
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
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
              if (confirmed == true && context.mounted) {
                Navigator.pop(context);
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

            StatCard(
              label: 'Certificate No',
              value: contractor.certificateNo,
              icon: Icons.badge,
            ),
            StatCard(
              label: 'Certificate Type',
              value: contractor.certificateType ?? 'N/A',
              icon: Icons.class_,
            ),
            StatCard(
              label: 'Issue Date',
              value: contractor.issueDate.toIsoDateString,
              icon: Icons.event,
            ),
            StatCard(
              label: 'Expiry Date',
              value: contractor.expireDate.toIsoDateString,
              icon: contractor.isExpiringSoon
                  ? Icons.warning_amber
                  : Icons.event_available,
              iconColor: contractor.isExpiringSoon ? Colors.orange : null,
            ),
          ],
        ),
      ),
    );
  }
}

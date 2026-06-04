import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Reports navigation hub page.
///
/// Lists available reports and charts that the user can navigate to.
class ReportsHubPage extends ConsumerWidget {
  const ReportsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _reportTile(
            context,
            icon: Icons.calendar_today,
            title: 'Daily Summary',
            subtitle: 'View daily deployment summary by project',
            onTap: () => context.push('/reports/daily'),
          ),
          _reportTile(
            context,
            icon: Icons.business,
            title: 'Company Summary',
            subtitle: 'Daily company-wide deployment overview',
            onTap: () => context.push('/reports/company'),
          ),
          _reportTile(
            context,
            icon: Icons.assessment,
            title: 'Project NDT Status',
            subtitle: 'Per-project NDT completion status',
            onTap: () => context.push('/reports/project-status'),
          ),
          _reportTile(
            context,
            icon: Icons.trending_up,
            title: 'Charts & Trends',
            subtitle: 'Weekly deployment trend analysis',
            onTap: () => context.push('/reports/charts'),
          ),
        ],
      ),
    );
  }

  Widget _reportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A56DB).withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1A56DB)),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing:
            Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

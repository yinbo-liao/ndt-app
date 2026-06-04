import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_controller.dart';
import '../projects/project_controller.dart';
import '../user_update/user_controller.dart';

/// Root dashboard with bottom tab navigation:
/// [Tables] (admin) | [Home] | [Reports]
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    final isAdmin = role == AppConstants.roleAdmin;
    final user = ref.watch(currentUserProvider);

    final userName = user?.userMetadata?['full_name'] as String? ??
        user?.email ??
        'User';

    // Non-admin starts on Home tab (index 1)
    if (!isAdmin && _selectedTab == 0) {
      _selectedTab = 1;
    }

    final tabs = <Widget>[
      // Tab 0: Tables (admin only)
      if (isAdmin) _buildAdminTablesGrid(context),

      // Tab 1: Home (navigation cards)
      _buildHomeTab(context, ref, role, userName),

      // Tab 2: Reports hub
      _buildReportsTab(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: isAdmin ? _selectedTab : (_selectedTab == 0 ? 1 : _selectedTab),
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isAdmin ? _selectedTab : (_selectedTab == 0 ? 1 : _selectedTab),
        onTap: (i) => setState(() => _selectedTab = i),
        selectedItemColor: const Color(0xFF1A56DB),
        items: [
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Tables',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  // ── TAB 0: Admin Tables Grid ─────────────────────────────────

  Widget _buildAdminTablesGrid(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Stats row
        _AdminStatsRow(),
        const SizedBox(height: 16),
        Text(
          'Database Tables',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _tableCards(context),
        ),
      ],
    );
  }

  List<Widget> _tableCards(BuildContext context) {
    const tables = [
      _TableInfo('NDT Companies', Icons.business, '/companies', 'ndt_companies'),
      _TableInfo('Users', Icons.people, '/users', 'users'),
      _TableInfo('Contractors', Icons.verified_user, '/contractors', 'ndt_contractor_register'),
      _TableInfo('Projects', Icons.apartment, '/projects', 'projects'),
      _TableInfo('NDT Planning', Icons.assignment_turned_in, '/planning', 'project_ndt_planning'),
      _TableInfo('Deployments', Icons.engineering, '/deployments', 'ndt_team_deployments'),
      _TableInfo('Assignments', Icons.assignment_ind, '/assignments', 'ndt_team_assignments'),
      _TableInfo('Audit Logs', Icons.history, '/audit-logs', 'audit_logs'),
      _TableInfo('Notifications', Icons.notifications, '/notifications', 'notifications'),
    ];

    return tables.map((t) => _tableCard(context, t)).toList();
  }

  Widget _tableCard(BuildContext context, _TableInfo table) {
    final width = (MediaQuery.of(context).size.width - 34) / 2;
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => GoRouter.of(context).go(table.route),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(table.icon, color: const Color(0xFF1A56DB), size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  table.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  table.tableName,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => GoRouter.of(context).go(table.route),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: const Color(0xFF1A56DB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB 1: Home (Navigation Cards) ───────────────────────────

  Widget _buildHomeTab(BuildContext context, WidgetRef ref, String role, String userName) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
              const SizedBox(height: 4),
              Text('$userName ⸻ ${_roleLabel(role)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (role == AppConstants.roleAdmin) _AdminStatsRow(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Quick Actions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  )),
        ),
        const SizedBox(height: 4),
        ..._navItemsForRole(role, context),
      ],
    );
  }

  List<Widget> _navItemsForRole(String role, BuildContext context) {
    final items = <_NavItem>[];
    if (role == AppConstants.roleAdmin) {
      items.addAll([
        _NavItem(Icons.assignment_turned_in, 'NDT RFI Review', 'Manage NDT planning requests', '/planning'),
        _NavItem(Icons.groups, 'NDT Teams Update', 'Contractor register & team assignments', '/contractors'),
        _NavItem(Icons.person_search, 'NDT Professionals', 'Manage NDT professional register', '/professionals'),
        _NavItem(Icons.engineering, 'NDT Deployment Review', 'View and manage team deployments', '/deployments'),
        _NavItem(Icons.business, 'Project Management', 'Create and manage projects', '/projects'),
        _NavItem(Icons.manage_accounts, 'User Update', 'Manage users and access roles', '/users'),
        _NavItem(Icons.assessment, 'Reports', 'Daily summaries and performance charts', '/reports'),
      ]);
    } else if (role == AppConstants.roleNdtCompany) {
      items.addAll([
        _NavItem(Icons.groups, 'NDT Teams Update', 'Contractor register & team assignments', '/contractors'),
        _NavItem(Icons.person_search, 'NDT Professionals', 'Manage NDT professional register', '/professionals'),
        _NavItem(Icons.engineering, 'NDT Deployment Review', 'View and update team deployments', '/deployments'),
        _NavItem(Icons.assignment, 'NDT RFI Register', 'View and manage NDT RFIs', '/planning'),
        _NavItem(Icons.assessment, 'Reports', 'Daily summaries and performance charts', '/reports'),
      ]);
    } else {
      items.addAll([
        _NavItem(Icons.engineering, 'NDT Deployment Review', 'View my team deployments', '/deployments'),
        _NavItem(Icons.assignment, 'My Assignments', 'View my assigned projects', '/my-assignments'),
      ]);
    }
    return items.map((item) => _navCard(context, item)).toList();
  }

  Widget _navCard(BuildContext context, _NavItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A56DB).withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: const Color(0xFF1A56DB), size: 24),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(item.subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => GoRouter.of(context).go(item.route),
      ),
    );
  }

  // ── TAB 2: Reports Hub ───────────────────────────────────────

  Widget _buildReportsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _reportTile(context, Icons.calendar_today, 'Daily Summary', 'Daily deployment summary by project', '/reports/daily'),
        _reportTile(context, Icons.business, 'Company Summary', 'Daily company-wide deployment overview', '/reports/company'),
        _reportTile(context, Icons.assessment, 'Project NDT Status', 'Per-project NDT completion status', '/reports/project-status'),
        _reportTile(context, Icons.trending_up, 'Charts & Trends', 'Weekly deployment trend analysis', '/reports/charts'),
      ],
    );
  }

  Widget _reportTile(BuildContext context, IconData icon, String title, String subtitle, String route) {
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => GoRouter.of(context).go(route),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case AppConstants.roleAdmin: return 'Administrator';
      case AppConstants.roleNdtCompany: return 'NDT Company';
      case AppConstants.roleNdtTeam: return 'NDT Team';
      default: return role;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Admin Stats & Helpers
// ─────────────────────────────────────────────────────────────

class _AdminStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final projectsAsync = ref.watch(projectsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _miniStatCard(Icons.people, 'Users', usersAsync.when(data: (u) => '${u.length}', loading: () => '...', error: (_, __) => '--'), Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _miniStatCard(Icons.business, 'Projects', projectsAsync.when(data: (p) => '${p.length}', loading: () => '...', error: (_, __) => '--'), Colors.green)),
          const SizedBox(width: 8),
          Expanded(child: _miniStatCard(Icons.assignment_turned_in, 'RFIs', '—', Colors.orange)),
        ],
      ),
    );
  }

  Widget _miniStatCard(IconData icon, String label, String value, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ]),
      ),
    );
  }
}

class _TableInfo {
  final String label;
  final IconData icon;
  final String route;
  final String tableName;
  const _TableInfo(this.label, this.icon, this.route, this.tableName);
}

class _NavItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  const _NavItem(this.icon, this.title, this.subtitle, this.route);
}

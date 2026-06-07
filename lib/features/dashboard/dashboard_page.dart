import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/change_password_dialog.dart';
import '../auth/auth_controller.dart';
import '../projects/project_controller.dart';
import '../user_update/user_controller.dart';

/// Root dashboard with bottom tab navigation and user status in AppBar:
/// [Tables] (admin) | [Home] | [Reports]
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedTab = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Support ?view=tables to pre-select the admin Tables tab via the
      // persistent bottom nav bar provided by AppShell.
      final viewParam = GoRouterState.of(context).uri.queryParameters['view'];
      if (viewParam == 'tables') {
        _selectedTab = 0;
      } else if (viewParam == 'home') {
        _selectedTab = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    final isAdmin = role == AppConstants.roleAdmin;
    final user = ref.watch(currentUserProvider);

    final userName = user?.userMetadata?['full_name'] as String? ??
        user?.email ??
        'User';
    if (!isAdmin && _selectedTab == 0) _selectedTab = 1;

    final tabs = <Widget>[
      if (isAdmin) _buildAdminTablesGrid(context),
      _buildHomeTab(context, ref, role, userName),
      _buildReportsTab(context),
    ];

    final tabIndex = isAdmin ? _selectedTab : (_selectedTab == 0 ? 1 : _selectedTab);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT Management'),
        actions: [
          // ── User status pill ──
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              onSelected: (value) async {
                switch (value) {
                  case 'password':
                    await showDialog(
                      context: context,
                      builder: (_) => const ChangePasswordDialog(),
                    );
                    break;
                  case 'logout':
                    ref.read(authNotifierProvider.notifier).signOut();
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'password',
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline, color: Color(0xFF1A56DB)),
                    title: const Text('Change Password'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Sign Out'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF1A56DB),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        userName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor(role),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _roleLabel(role),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: tabIndex, children: tabs),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case AppConstants.roleAdmin: return Colors.red.shade700;
      case AppConstants.roleNdtCompany: return Colors.blue.shade700;
      default: return Colors.green.shade700;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case AppConstants.roleAdmin: return 'Admin';
      case AppConstants.roleNdtCompany: return 'Company';
      case AppConstants.roleNdtTeam: return 'Team';
      default: return role;
    }
  }

  // ── TAB 0: Admin Tables Grid ────────────────
  Widget _buildAdminTablesGrid(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _AdminStatsRow(),
        const SizedBox(height: 16),
        Text('Database Tables',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _tableCards(context),
        ),
      ],
    );
  }

  List<Widget> _tableCards(BuildContext context) {
    const tables = [
      _TableInfo('NDT Companies', Icons.business, '/companies', 'ndt_companies', createRoute: '/companies/create'),
      _TableInfo('Projects', Icons.apartment, '/projects', 'projects', createRoute: '/projects/create'),
      _TableInfo('Contractor Register', Icons.verified_user, '/professional-register', 'ndt_contractor_register', createRoute: '/professional-register/create'),
      _TableInfo('NDT Planning (RFI)', Icons.assignment_turned_in, '/planning', 'project_ndt_planning', createRoute: '/planning/create'),
      _TableInfo('Deployments', Icons.engineering, '/deployments', 'ndt_team_deployments', createRoute: '/deployments/create'),
      _TableInfo('Professional Register', Icons.person_search, '/professionals', 'ndt_professional_register', createRoute: '/professionals/create'),
      _TableInfo('Team Assignments', Icons.assignment_ind, '/assignments', 'ndt_team_assignments', createRoute: '/assignments/create'),
      _TableInfo('Reports Hub', Icons.assessment, '/reports', 'reports'), // popup sub-menu
      _TableInfo('Audit Logs', Icons.history, '/audit-logs', 'audit_logs'),
      _TableInfo('Notifications', Icons.notifications, '/notifications', 'notifications'),
      _TableInfo('Users', Icons.people, '/users', 'users', createRoute: '/users/create'),
      _TableInfo('My Assignments', Icons.person, '/my-assignments', 'ndt_team_assignments'),
    ];
    return tables.map((t) => _tableCard(context, t)).toList();
  }

  Widget _tableCard(BuildContext context, _TableInfo table) {
    final width = (MediaQuery.of(context).size.width - 34) / 2;
    final isReports = table.route == '/reports';
    final hasCreate = table.createRoute != null;

    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 8),
              Text(table.label, textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(table.tableName, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              const SizedBox(height: 8),
              if (isReports)
                _reportsMenuButton(context)
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => GoRouter.of(context).go(table.route),
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('View', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        side: const BorderSide(color: Color(0xFF1A56DB)),
                        foregroundColor: const Color(0xFF1A56DB),
                      ),
                    ),
                    if (hasCreate) ...[
                      const SizedBox(width: 5),
                      FilledButton.icon(
                        onPressed: () => GoRouter.of(context).go(table.createRoute!),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Add', style: TextStyle(fontSize: 11)),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: const Color(0xFF1A56DB),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportsMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (route) => GoRouter.of(context).go(route),
      offset: const Offset(0, 32),
      child: FilledButton.icon(
        onPressed: () {}, // PopupMenuButton handles the tap
        icon: const Icon(Icons.bar_chart, size: 14),
        label: const Text('Open', style: TextStyle(fontSize: 11)),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 30),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: const Color(0xFF1A56DB),
        ),
      ),
      itemBuilder: (_) => const [
        PopupMenuItem(value: '/reports/daily', child: ListTile(leading: Icon(Icons.calendar_today), title: Text('Daily Summary'), dense: true, contentPadding: EdgeInsets.zero)),
        PopupMenuItem(value: '/reports/company', child: ListTile(leading: Icon(Icons.business), title: Text('Company Summary'), dense: true, contentPadding: EdgeInsets.zero)),
        PopupMenuItem(value: '/reports/project-status', child: ListTile(leading: Icon(Icons.assessment), title: Text('Project Status'), dense: true, contentPadding: EdgeInsets.zero)),
        PopupMenuItem(value: '/reports/charts', child: ListTile(leading: Icon(Icons.trending_up), title: Text('Charts & Trends'), dense: true, contentPadding: EdgeInsets.zero)),
        PopupMenuItem(value: '/reports/professional', child: ListTile(leading: Icon(Icons.person), title: Text('Professional Summary'), dense: true, contentPadding: EdgeInsets.zero)),
      ],
    );
  }

  // ── TAB 1: Home ─────────────────────────────
  Widget _buildHomeTab(BuildContext context, WidgetRef ref, String role, String userName) {
    final isSupervisor = role == AppConstants.roleAdmin || role == AppConstants.roleNdtCompany;

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
              const SizedBox(height: 4),
              Text('$userName  ${_roleLabel(role)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (role == AppConstants.roleAdmin) _AdminStatsRow(),
        const SizedBox(height: 8),
        // ── NDT-Supervisor Section (Admin + NDT Company) ──
        if (isSupervisor) ...[
          _buildSupervisorSection(),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Quick Actions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 4),
        ..._navItemsForRole(role, context),
      ],
    );
  }

  // ── NDT-Supervisor Quick Actions ─────────────────────
  Widget _buildSupervisorSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFFF8E1), // amber tint background
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('NDT-Supervisor Quick Actions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFE65100))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _supervisorActionBtn(
                    Icons.person_search,
                    'Professional\nRegister',
                    '/professionals/create',
                    Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _supervisorActionBtn(
                    Icons.assignment_ind,
                    'Team\nAssignment',
                    '/assignments/create',
                    Colors.amber.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _supervisorActionBtn(
                    Icons.verified_user,
                    'Contractor\nRegister',
                    '/professional-register/create',
                    Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _supervisorActionBtn(IconData icon, String label, String route, Color color) {
    return InkWell(
      onTap: () => GoRouter.of(context).go(route),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color,
                    height: 1.3)),
            const SizedBox(height: 2),
            Icon(Icons.add_circle, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  List<Widget> _navItemsForRole(String role, BuildContext context) {
    final items = <_NavItem>[];
    if (role == AppConstants.roleAdmin) {
      items.addAll([
        _NavItem(Icons.assignment_turned_in, 'NDT RFI Review', 'Manage NDT planning requests', '/planning'),
        _NavItem(Icons.groups, 'Professional Register', 'Technician certificates & team assignments', '/professional-register'),
        _NavItem(Icons.person_search, 'NDT Professionals', 'Manage NDT professional register', '/professionals'),
        _NavItem(Icons.engineering, 'NDT Deployment Review', 'View and manage team deployments', '/deployments'),
        _NavItem(Icons.business, 'Project Management', 'Create and manage projects', '/projects'),
        _NavItem(Icons.manage_accounts, 'User Update', 'Manage users and access roles', '/users'),
        _NavItem(Icons.assessment, 'Reports', 'Daily summaries and performance charts', '/reports'),
      ]);
    } else if (role == AppConstants.roleNdtCompany) {
      items.addAll([
        _NavItem(Icons.assignment, 'NDT RFI Register', 'View and manage NDT RFIs for your projects', '/planning'),
        _NavItem(Icons.engineering, 'NDT Deployment Review', 'View and update team deployments', '/deployments'),
        _NavItem(Icons.groups, 'Contractor Register', 'Manage technician certificates', '/professional-register'),
        _NavItem(Icons.person_search, 'NDT Professionals', 'Manage NDT professional register', '/professionals'),
        _NavItem(Icons.assessment, 'Reports', 'Daily summaries and performance charts', '/reports'),
        _NavItem(Icons.assignment_ind, 'Team Assignments', 'Manage team-project assignments', '/assignments'),
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

  // ── TAB 2: Reports ──────────────────────────
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
}

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
          Expanded(child: _miniStatCard(Icons.assignment_turned_in, 'RFIs', '', Colors.orange)),
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
  final String? createRoute; // null = no create form (e.g. audit logs, notifications)
  const _TableInfo(this.label, this.icon, this.route, this.tableName, {this.createRoute});
}

class _NavItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  const _NavItem(this.icon, this.title, this.subtitle, this.route);
}

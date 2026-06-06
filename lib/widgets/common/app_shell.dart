import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/role_provider.dart';

/// Persistent shell scaffold that wraps all authenticated pages with
/// a bottom navigation bar for quick access to Tables (admin), Home, and Reports.
///
/// Each child page provides its own Scaffold + AppBar; this shell only
/// adds the shared [BottomNavigationBar]. The outermost Scaffold is
/// provided by [MaterialApp.router] via GoRouter.
class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final isAdmin = role == AppConstants.roleAdmin;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    // Determine which tab is active based on the current route.
    // 'reports' → Reports tab; everything else → Home/Tables tab.
    final isReports = currentRoute.startsWith('/reports');
    // Admin has 3 tabs, non-admin has 2. Adjust index:
    // Admin: 0=Tables, 1=Home, 2=Reports
    // Others: 0=Home, 1=Reports
    int currentIndex;
    if (isReports) {
      currentIndex = isAdmin ? 2 : 1;
    } else {
      // Distinguish Tables vs Home for admin:
      // Tables = the dashboard's admin grid view
      // Home  = the dashboard's quick-actions view
      // We use a query param ?view=tables to select the Tables tab.
      final viewParam = GoRouterState.of(context).uri.queryParameters['view'];
      if (isAdmin && viewParam == 'tables') {
        currentIndex = 0; // Tables
      } else {
        currentIndex = isAdmin ? 1 : 0; // Home
      }
      // Note: when user navigates to /projects, /contractors, etc.,
      // they came from the Home context, so Home stays highlighted.
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTabTapped(context, isAdmin, i),
        selectedItemColor: const Color(0xFF1A56DB),
        items: [
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Tables',
            ),
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            )
          else
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

  void _onTabTapped(BuildContext context, bool isAdmin, int index) {
    if (isAdmin) {
      switch (index) {
        case 0: // Tables
          context.go('/dashboard?view=tables');
          break;
        case 1: // Home
          context.go('/dashboard');
          break;
        case 2: // Reports
          context.go('/reports');
          break;
      }
    } else {
      switch (index) {
        case 0: // Home
          context.go('/dashboard');
          break;
        case 1: // Reports
          context.go('/reports');
          break;
      }
    }
  }
}

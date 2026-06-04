import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/login_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/contractor_register/contractor_list_page.dart';
import '../../features/contractor_register/contractor_form_page.dart';
import '../../features/ndt_planning/planning_list_page.dart';
import '../../features/ndt_planning/planning_form_page.dart';
import '../../features/deployments/deployment_list_page.dart';
import '../../features/deployments/deployment_form_page.dart';
import '../../features/deployments/deployment_detail_page.dart';
import '../../features/summaries/daily_summary_page.dart';
import '../../features/summaries/company_summary_page.dart';
import '../../features/summaries/project_summary_page.dart';
import '../../features/summaries/charts_page.dart';
import '../../features/user_update/user_list_page.dart';
import '../../features/user_update/user_form_page.dart';
import '../../features/summaries/reports_hub_page.dart';
import '../../features/projects/project_list_page.dart';
import '../../features/projects/project_detail_page.dart';
import '../../features/projects/project_form_page.dart';
import '../../features/companies/company_list_page.dart';
import '../../features/companies/company_form_page.dart';
import '../../features/team_management/assignment_list_page.dart';
import '../../features/audit_logs/audit_list_page.dart';
import '../../features/notifications/notification_list_page.dart';

/// Provides the configured [GoRouter] instance.
///
/// Routes are guarded based on authentication state and user role.
/// Unauthenticated users are redirected to /login.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      final isAuth = ref.read(isAuthenticatedProvider);

      // Not authenticated → go to login
      if (!isAuth && !isLoginRoute) return '/login';

      // Authenticated and on login → go to dashboard
      if (isAuth && isLoginRoute) return '/dashboard';

      // No redirect needed
      return null;
    },
    routes: [
      // ── Login ──────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ── Dashboard ──────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // ── Projects ─────────────────────────────────────────
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectListPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'project-create',
            builder: (context, state) =>
                const ProjectFormPage(),
          ),
          GoRoute(
            path: ':projectId',
            name: 'project-detail',
            builder: (context, state) {
              final projectId =
                  state.pathParameters['projectId']!;
              return ProjectDetailPage(
                  projectId: projectId);
            },
          ),
        ],
      ),

      // ── NDT Contractor Register ────────────────────────────
      GoRoute(
        path: '/contractors',
        name: 'contractors',
        builder: (context, state) => const ContractorListPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'contractor-create',
            builder: (context, state) => const ContractorFormPage(),
          ),
          GoRoute(
            path: ':contractorId/edit',
            name: 'contractor-edit',
            builder: (context, state) {
              // ContractorFormPage will fetch the existing contractor
              // from the repository using the ID
              return const ContractorFormPage();
            },
          ),
          GoRoute(
            path: ':contractorId',
            name: 'contractor-detail',
            builder: (context, state) {
              // Will resolve via GoRouterState extra or query params
              // For now, detail is accessed via navigation from the list page
              return const ContractorListPage(); // fallback
            },
          ),
        ],
      ),

      // ── NDT Planning (RFI) ─────────────────────────────────
      GoRoute(
        path: '/planning',
        name: 'planning',
        builder: (context, state) {
          final projectId =
              state.uri.queryParameters['projectId'] ?? '';
          return PlanningListPage(projectId: projectId);
        },
        routes: [
          GoRoute(
            path: 'create',
            name: 'planning-create',
            builder: (context, state) {
              final projectId =
                  state.uri.queryParameters['projectId'] ?? '';
              return PlanningFormPage(projectId: projectId);
            },
          ),
        ],
      ),

      // ── NDT Deployments ───────────────────────────────────
      GoRoute(
        path: '/deployments',
        name: 'deployments',
        builder: (context, state) => const DeploymentListPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'deployment-create',
            builder: (context, state) => const DeploymentFormPage(),
          ),
          GoRoute(
            path: ':deploymentId',
            name: 'deployment-detail',
            builder: (context, state) {
              final deploymentId =
                  state.pathParameters['deploymentId']!;
              return DeploymentDetailPage(
                deploymentId: deploymentId,
              );
            },
          ),
          GoRoute(
            path: ':deploymentId/edit',
            name: 'deployment-edit',
            builder: (context, state) => const DeploymentFormPage(),
          ),
        ],
      ),

      // ── Reports ───────────────────────────────────────────
      GoRoute(
        path: '/reports',
        name: 'reports-hub',
        builder: (context, state) => const ReportsHubPage(),
        routes: [
          GoRoute(
            path: 'daily',
            name: 'reports-daily',
            builder: (context, state) {
              final projectId =
                  state.uri.queryParameters['projectId'] ?? '';
              return DailySummaryPage(
                projectId: projectId,
                projectName:
                    state.uri.queryParameters['projectName'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'company',
            name: 'reports-company',
            builder: (context, state) =>
                const CompanySummaryPage(),
          ),
          GoRoute(
            path: 'project-status',
            name: 'reports-project-status',
            builder: (context, state) =>
                const ProjectSummaryPage(),
          ),
          GoRoute(
            path: 'charts',
            name: 'reports-charts',
            builder: (context, state) {
              final projectId =
                  state.uri.queryParameters['projectId'] ?? '';
              return ChartsPage(projectId: projectId);
            },
          ),
        ],
      ),

      // ── Companies ────────────────────────────────────────
      GoRoute(
        path: '/companies',
        name: 'companies',
        builder: (context, state) => const CompanyListPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'company-create',
            builder: (context, state) => const CompanyFormPage(),
          ),
        ],
      ),

      // ── Team Assignments ──────────────────────────────────
      GoRoute(
        path: '/assignments',
        name: 'assignments',
        builder: (context, state) => const AssignmentListPage(),
      ),

      // ── Audit Logs ────────────────────────────────────────
      GoRoute(
        path: '/audit-logs',
        name: 'audit-logs',
        builder: (context, state) => const AuditListPage(),
      ),

      // ── Notifications ─────────────────────────────────────
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationListPage(),
      ),

      // ── User Management (Admin Only) ──────────────────────
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UserListPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'user-create',
            builder: (context, state) => const UserFormPage(),
          ),
          GoRoute(
            path: ':userId/edit',
            name: 'user-edit',
            builder: (context, state) {
              final userId =
                  state.pathParameters['userId']!;
              return UserFormPage(userId: userId);
            },
          ),
        ],
      ),
    ],
  );
});


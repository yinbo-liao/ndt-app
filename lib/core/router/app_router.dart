import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../data/models/company_model.dart';
import '../../data/models/contractor_model.dart';
import '../../data/models/professional_model.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/company_repository.dart';
import '../../data/repositories/contractor_repository.dart';
import '../../data/repositories/professional_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../widgets/common/app_shell.dart';
import 'route_guards.dart';
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
import '../../features/summaries/professional_summary_page.dart';
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
import '../../features/professional_register/professional_list_page.dart';
import '../../features/professional_register/professional_form_page.dart';
import '../../features/professional_register/professional_detail_page.dart';
import '../../features/ndt_planning/planning_detail_page.dart';
import '../../features/companies/company_detail_page.dart';
import '../../features/team_management/my_assignments_page.dart';
import '../../features/team_management/team_assignment_page.dart';
import '../../features/team_management/professional_assignment_list_page.dart';

/// Provides the configured [GoRouter] instance.
///
/// Routes are guarded based on authentication state and user role.
/// Unauthenticated users are redirected to /login.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Role-based route access map.
  // 'admin' = admin only, 'company' = admin + ndt_company, 'any' = authenticated.
  const adminOnly = ['/users', '/companies', '/audit-logs', '/professional-assignments'];
  const companyPlus = ['/professional-register', '/professionals'];

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoginRoute = location == '/login';
      final isAuth = ref.read(isAuthenticatedProvider);
      final role = ref.read(userRoleProvider);

      // Not authenticated → go to login
      if (!isAuth && !isLoginRoute) return '/login';

      // Authenticated and on login → go to dashboard
      if (isAuth && isLoginRoute) return '/dashboard';

      // Role-based access enforcement
      if (isAuth) {
        // Admin-only routes
        if (adminOnly.any((r) => location.startsWith(r)) &&
            !RouteGuards.canAccessAdmin(role)) {
          return '/dashboard';
        }
        // Admin + NDT Company routes
        if (companyPlus.any((r) => location.startsWith(r)) &&
            !RouteGuards.canAccessCompany(role)) {
          return '/dashboard';
        }
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ── Login (no shell — standalone page) ─────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ── Shell: persistent bottom nav (Tables | Home | Reports) ─
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // ── Dashboard ──────────────────────────────────────
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
              GoRoute(
                path: ':projectId/edit',
                name: 'project-edit',
                builder: (context, state) {
                  final projectId =
                      state.pathParameters['projectId']!;
                  return _FetchEditPage<ProjectModel>(
                    id: projectId,
                    entityLabel: 'Project',
                    fetcher: (id) => ProjectRepository().getById(id),
                    builder: (model) => ProjectFormPage(existing: model),
                  );
                },
              ),
            ],
          ),

          // ── NDT Contractor Register (Technician/Professional Register) ──
          GoRoute(
            path: '/professional-register',
            name: 'professional-register',
            builder: (context, state) => const ContractorListPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'professional-register-create',
                builder: (context, state) => const ContractorFormPage(),
              ),
              GoRoute(
                path: ':contractorId/edit',
                name: 'professional-register-edit',
                builder: (context, state) {
                  final contractorId =
                      state.pathParameters['contractorId']!;
                  return _FetchEditPage<ContractorModel>(
                    id: contractorId,
                    entityLabel: 'Contractor',
                    fetcher: (id) => ContractorRepository().getById(id),
                    builder: (model) => ContractorFormPage(existing: model),
                  );
                },
              ),
              GoRoute(
                path: ':contractorId',
                name: 'professional-register-detail',
                builder: (context, state) {
                  return const ContractorListPage();
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
              GoRoute(
                path: ':planningId',
                name: 'planning-detail',
                builder: (context, state) {
                  final planningId =
                      state.pathParameters['planningId']!;
                  return PlanningDetailPage(planningId: planningId);
                },
              ),
              GoRoute(
                path: ':planningId/edit',
                name: 'planning-edit',
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
              GoRoute(
                path: 'professional',
                name: 'reports-professional',
                builder: (context, state) =>
                    const ProfessionalSummaryPage(),
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
              GoRoute(
                path: ':companyId',
                name: 'company-detail',
                builder: (context, state) {
                  final companyId =
                      state.pathParameters['companyId']!;
                  return CompanyDetailPage(companyId: companyId);
                },
              ),
              GoRoute(
                path: ':companyId/edit',
                name: 'company-edit',
                builder: (context, state) {
                  final companyId =
                      state.pathParameters['companyId']!;
                  return _FetchEditPage<CompanyModel>(
                    id: companyId,
                    entityLabel: 'Company',
                    fetcher: (id) => CompanyRepository().getById(id),
                    builder: (model) => CompanyFormPage(existing: model),
                  );
                },
              ),
            ],
          ),

          // ── NDT Professional Register ────────────────────────
          GoRoute(
            path: '/professionals',
            name: 'professionals',
            builder: (context, state) => const ProfessionalListPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'professional-create',
                builder: (context, state) =>
                    const ProfessionalFormPage(),
              ),
              GoRoute(
                path: ':professionalId',
                name: 'professional-detail',
                builder: (context, state) {
                  final professionalId =
                      state.pathParameters['professionalId']!;
                  return ProfessionalDetailPage(
                      professionalId: professionalId);
                },
              ),
              GoRoute(
                path: ':professionalId/edit',
                name: 'professional-edit',
                builder: (context, state) {
                  final professionalId =
                      state.pathParameters['professionalId']!;
                  return _FetchEditPage<ProfessionalModel>(
                    id: professionalId,
                    entityLabel: 'Professional',
                    fetcher: (id) => ProfessionalRepository().getById(id),
                    builder: (model) => ProfessionalFormPage(existing: model),
                  );
                },
              ),
            ],
          ),

          // ── My Assignments (Team) ──────────────────────────────
          GoRoute(
            path: '/my-assignments',
            name: 'my-assignments',
            builder: (context, state) => const MyAssignmentsPage(),
          ),

          // ── Team Assignments ──────────────────────────────────
          GoRoute(
            path: '/assignments',
            name: 'assignments',
            builder: (context, state) => const AssignmentListPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'assignment-create',
                builder: (context, state) =>
                    const TeamAssignmentPage(),
              ),
              GoRoute(
                path: ':assignmentId/edit',
                name: 'assignment-edit',
                builder: (context, state) =>
                    const TeamAssignmentPage(),
              ),
            ],
          ),

          // ── Audit Logs ────────────────────────────────────────
          GoRoute(
            path: '/audit-logs',
            name: 'audit-logs',
            builder: (context, state) => const AuditListPage(),
          ),

          // ── Professional Assignments (Admin Only) ──────────────
          GoRoute(
            path: '/professional-assignments',
            name: 'professional-assignments',
            builder: (context, state) =>
                const ProfessionalAssignmentListPage(),
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
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────
// Edit Route Wrapper (Generic)
//
// Fetches a model by ID and passes it to a form page's `existing`
// parameter. This keeps form page constructors unchanged while
// enabling GoRouter-based edit navigation.
// ─────────────────────────────────────────────────────────────

/// Generic widget that fetches a model of type [T] by ID, shows a loading
/// spinner while waiting, an error state on failure, and renders [builder]
/// with the fetched model on success.
class _FetchEditPage<T> extends StatelessWidget {
  final String id;
  final String entityLabel;
  final Future<T?> Function(String id) fetcher;
  final Widget Function(T model) builder;

  const _FetchEditPage({
    required this.id,
    required this.entityLabel,
    required this.fetcher,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T?>(
      future: fetcher(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Edit $entityLabel')),
            body: Center(child: Text('$entityLabel not found')),
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }
}


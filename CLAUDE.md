# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NDT (Non-Destructive Testing) Management Mobile App — a Flutter application for managing NDT operations including contractor registration, project management, NDT planning, team deployments (day/night shifts), and reporting dashboards with charts.

**Stack:** Flutter 3.x + Dart 3.12+ + Supabase (PostgreSQL) + Riverpod + GoRouter + fl_chart

## Build Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (only if freezed/json_serializable models are added)
dart run build_runner build --delete-conflicting-outputs

# Run static analysis
flutter analyze

# Run tests
flutter test

# Build for Android
flutter build apk --debug      # Debug APK
flutter build apk --release     # Release APK

# Build for iOS (macOS only)
flutter build ios --no-codesign # Debug without signing

# Run on connected device
flutter run
```

## Architecture

### Layered Architecture (Clean Architecture Lite)

```
lib/
├── app.dart                  # MaterialApp.router entry widget
├── main.dart                 # Supabase init → ProviderScope → NdtManagementApp
├── core/                     # Cross-cutting infrastructure
│   ├── constants/            # App-wide string constants, Supabase config
│   ├── router/               # GoRouter config with role-based guards
│   ├── theme/                # Light/dark ThemeData, color palette
│   ├── utils/                # Date helpers, validators, extensions
│   └── services/             # Supabase client wrapper, AuthService, NotificationService
├── data/                     # Data layer (models, repositories, DTOs)
│   ├── models/               # 8 domain models with equatable + manual JSON
│   ├── repositories/         # 6 repositories for Supabase CRUD + RPC calls
│   └── dto/                  # Denormalized DTOs for UI consumption
├── features/                 # Feature-first UI modules
│   ├── auth/                 # Login page + auth controller
│   ├── dashboard/            # Role-based dashboard (admin/company/team)
│   ├── contractor_register/  # CRUD for NDT certificates
│   ├── projects/             # Project list + detail
│   ├── ndt_planning/         # NDT planning CRUD
│   ├── deployments/          # Team deployments with shift selector
│   ├── team_management/      # Team member list + assignments
│   └── summaries/            # Daily/company/project summaries + charts
├── widgets/                  # Reusable UI components
│   ├── common/               # app_bar, loading_indicator, error_widget, empty_state
│   ├── forms/                # date_picker_field, dropdown_field, text_input_field
│   ├── cards/                # summary_card, stat_card, deployment_card
│   ├── tables/               # data_table_widget, paginated_table
│   └── charts/               # bar_chart, line_chart, pie_chart, shift_comparison
└── providers/                # Global Riverpod providers (auth, role, barrel export)
```

### Key Design Patterns

1. **Models** use `equatable` for value equality and manual `fromJson`/`toJson` factory methods (no freezed/code generation). JSON keys are snake_case to match database columns.

2. **Repositories** wrap `Supabase.instance.client` calls. They never handle auth state — that's the provider layer's job. Repository methods return domain models, not raw JSON.

3. **Providers** (Riverpod) are the single source of truth for state. Feature controllers define `FutureProvider.family` and `StateProvider` instances. All providers use `autoDispose` to prevent memory leaks.

4. **Router** uses `go_router` with `redirect` guards: unauthenticated → `/login`, authenticated on login → `/dashboard`. Role-based navigation is handled in `dashboard_page.dart` via a switch on the user's role.

5. **Table names** are centralized in `SupabaseClientWrapper` as string constants. Always use these constants, never hardcode table names.

### Database — Supabase Backend

The complete schema is at `supabase/migrations/001_initial_schema.sql`. Key tables:
- `ndt_companies`, `users` (extends `auth.users`), `projects`
- `ndt_contractor_register` (soft-delete with `deleted_at`, certificate validation)
- `project_ndt_planning` (links projects to NDT companies)
- `ndt_team_deployments` (shift-aware with `shift_type` enum, JSONB `team_members`, soft-delete)
- `ndt_team_assignments` (users to projects)
- `audit_logs` (change tracking)

Three roles govern RLS: `admin` (full access), `ndt_company` (own data), `ndt_team` (assigned projects only).

Five SQL functions provide summary data (called via `_client.rpc()`):
- `daily_deployment_summary_by_project(p_project_id, p_date)`
- `daily_deployment_summary_by_company(p_company_id, p_date)`
- `weekly_deployment_trend(p_project_id, p_start_date, p_end_date)`
- `contractor_register_summary(p_company_id, p_month_start)`
- `project_ndt_status_summary(p_company_id)`

## Important Conventions

### Naming
- Model classes: PascalCase (`DeploymentModel`, `ContractorModel`)
- File names: snake_case (`deployment_model.dart`, `contractor_list_page.dart`)
- Provider variables: camelCase ending in `Provider` (`deploymentsProvider`, `selectedDateProvider`)
- Repository classes: PascalCase ending in `Repository` (`DeploymentRepository`)
- JSON keys: snake_case to match DB columns (`ndt_company_id`, `validation_status`)

### DateTime Handling
- DATE columns: serialize as `yyyy-MM-dd` string — use `DateTimeExtension.toIsoDateString`
- TIMESTAMPTZ columns: serialize as ISO 8601 string — use `DateTime.toUtc().toIso8601String()`
- Never send `DateTime` objects directly to Supabase; always convert to string

### Soft Delete
- Tables with `deleted_at`: `ndt_contractor_register`, `ndt_team_deployments`
- All queries on these tables MUST include `.isFilter('deleted_at', null)`
- Use repository `softDelete(id)` methods; never hard-delete

### JWT & Auth
- Role and company_id are embedded in JWT claims via a `handle_new_user()` trigger
- `auth.jwt()->>'role'` and `auth.jwt()->>'ndt_company_id'` drive all RLS policies
- Supabase config (`url`, `anonKey`) lives in `lib/core/constants/supabase_config.dart`

### Team Members JSONB
- Format: `[{"user_id": "uuid", "name": "Full Name", "role": "technician"}]`
- The `TeamMember` model handles serialization; the `DeploymentModel` stores as `List<TeamMember>`

### Tests
Tests are in `test/`. Run with `flutter test`. To test repositories, mock `SupabaseClient` — do not connect to a real database in unit tests.

## Flutter Design Agent (MCP Subagent)

This project includes a **Claude subagent** (`flutter-design-agent`) that automates Flutter code generation with security validation, layer enforcement, and testing.

### Starting the MCP Server

```bash
cd mcp_server
dart pub get
dart run bin/server.dart ../
```

To compile a standalone binary:

```bash
cd mcp_server
dart compile exe bin/server.dart -o build/flutter-mcp-server.exe
./build/flutter-mcp-server.exe ../
```

### Available MCP Tools

| Tool | Use |
|------|-----|
| `read_file` | Read project files with size limits + secret scanning |
| `write_file` | Atomic writes with SHA-256 checksum + backup + secret scan |
| `multi_edit` | Batch operations with rollback on failure |
| `run_command` | Whitelisted flutter/dart/git commands in sandbox |
| `validate_ui_layer` | Enforce architectural rules on generated code |
| `scan_secrets` | Shannon entropy + regex detection before writes |
| `analyze_project` | `flutter analyze --fatal-warnings` on target files |
| `health_check` | Server diagnostics + circuit breaker state |

### Using the Agent

When making significant UI changes or adding features, invoke the agent workflow:

1. **Analyze** existing code with `read_file` on relevant files
2. **Generate** the component following the project's feature-based structure
3. **Validate** with `analyze_project` for static errors
4. **Scan** with `scan_secrets` to prevent credential leakage
5. **Write** with `write_file` using checksum for integrity
6. **Test** by running `flutter test` on the generated test files

### Security

- **Never** hardcode Supabase keys — use `supabase_config.dart` constants
- MCP server sandboxes all file ops to `lib/`, `test/`, `assets/`
- Secret scanning runs on every `write_file` operation
- Circuit breaker opens after 10 consecutive failures (60s cooldown)
- Rate limiter: 100 requests/minute per tool

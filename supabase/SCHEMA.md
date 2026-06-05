# NDT App — Database Schema Reference

Single source of truth mapping every table, column, migration origin, and Dart model.

## Table Inventory

| # | Table | Migration | Dart Model | Repository |
|---|-------|-----------|------------|------------|
| 1 | `ndt_companies` | 001 + 003 | `CompanyModel` | `CompanyRepository` |
| 2 | `users` | 001 | `UserModel` | `UserRepository` |
| 3 | `ndt_contractor_register` | 001 | `ContractorModel` | `ContractorRepository` |
| 4 | `projects` | 001 + 003 | `ProjectModel` | `ProjectRepository` |
| 5 | `project_ndt_planning` | 001 + 002 + 003 | `PlanningModel` | `PlanningRepository` |
| 6 | `ndt_team_deployments` | 001 | `DeploymentModel` | `DeploymentRepository` |
| 7 | `ndt_team_assignments` | 001 | `AssignmentModel` | `AssignmentRepository` |
| 8 | `audit_logs` | 001 | `AuditLogModel` | `AuditRepository` |
| 9 | `notifications` | 002 | `NotificationModel` | `NotificationRepository` |
| 10 | `ndt_professional_register` | 003 | `ProfessionalModel` | `ProfessionalRepository` |
| 11 | `ndt_professional_assignments` | 004 | `ProfessionalAssignmentModel` | `ProfessionalAssignmentRepository` |

---

## Column Details

### 1. ndt_companies

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 001 | `id` |
| `name` | TEXT | YES | — | 001 | `name` |
| `registration_no` | TEXT UNIQUE | NO | — | 001 | `registrationNo` |
| `contact_email` | TEXT | NO | — | 001 | `contactEmail` |
| `contact_phone` | TEXT | NO | — | 001 | `contactPhone` |
| `active` | BOOLEAN | NO | true | 001 | `active` |
| `address` | TEXT | NO | — | 003 | `address` |
| `supervisor` | TEXT | NO | — | 003 | `supervisor` |
| `created_at` | TIMESTAMPTZ | NO | now() | 001 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 001 | `updatedAt` |

### 2. users

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK → auth.users | YES | — | 001 | `id` |
| `full_name` | TEXT | YES | — | 001 | `fullName` |
| `email` | TEXT UNIQUE | YES | — | 001 | `email` |
| `role` | TEXT CHECK(admin,ndt_company,ndt_team) | YES | — | 001 | `role` |
| `ndt_company_id` | UUID FK → ndt_companies | NO | — | 001 | `ndtCompanyId` |
| `phone` | TEXT | NO | — | 001 | `phone` |
| `employee_id` | TEXT | NO | — | 001 | `employeeId` |
| `active` | BOOLEAN | NO | true | 001 | `active` |
| `created_at` | TIMESTAMPTZ | NO | now() | 001 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 001 | `updatedAt` |

FK `ndt_company_id` → ON DELETE SET NULL (004).

### 3. ndt_contractor_register

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 001 | `id` |
| `ndt_company_id` | UUID FK | YES | — | 001 | `ndtCompanyId` |
| `type_of_ndt` | TEXT | YES | — | 001 | `typeOfNdt` |
| `type_of_ndt_certificate` | TEXT | YES | — | 001 | `typeOfNdtCertificate` |
| `certificate_no` | TEXT | YES | — | 001 | `certificateNo` |
| `certificate_type` | TEXT | NO | — | 001 | `certificateType` |
| `issue_date` | DATE | YES | — | 001 | `issueDate` |
| `expire_date` | DATE | YES | — | 001 | `expireDate` |
| `validation_status` | TEXT CHECK(valid,expired,pending,revoked) | NO | 'pending' | 001 | `validationStatus` |
| `report_month` | DATE | YES | — | 001 | `reportMonth` |
| `created_by` | UUID FK → users | NO | — | 001 | `createdBy` |
| `created_at` | TIMESTAMPTZ | NO | now() | 001 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 001 | `updatedAt` |
| `deleted_at` | TIMESTAMPTZ | NO | NULL (soft delete) | 001 | `deletedAt` |

FK `ndt_company_id` → CASCADE (004), `created_by` → SET NULL (004). Always filter `deleted_at IS NULL`.

### 4. projects

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 001 | `id` |
| `project_name` | TEXT | YES | — | 001 | `projectName` |
| `project_code` | TEXT UNIQUE | YES | — | 001 | `projectCode` |
| `job_trade` | TEXT | NO | — | 001 | `jobTrade` |
| `location` | TEXT | YES | — | 001 | `location` |
| `client_name` | TEXT | NO | — | 001 | `clientName` |
| `classification` | TEXT | NO | — | 003 | `classification` |
| `qa_incharge_id` | UUID FK → users | NO | — | 003 | `qaInchargeId` |
| `ndt_company_id` | UUID FK → ndt_companies | NO | — | 003 | `ndtCompanyId` |
| `start_date` | DATE | NO | — | 001 | `startDate` |
| `end_date` | DATE | NO | — | 001 | `endDate` |
| `active` | BOOLEAN | NO | true | 001 | `active` |
| `created_at` | TIMESTAMPTZ | NO | now() | 001 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 001 | `updatedAt` |

FK `qa_incharge_id` → SET NULL (004), `ndt_company_id` → SET NULL (004).

### 5. project_ndt_planning

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 001 | `id` |
| `project_id` | UUID FK → projects | YES | — | 001 | `projectId` |
| `ndt_company_id` | UUID FK → ndt_companies | YES | — | 001 | `ndtCompanyId` |
| `ndt_rfi_date` | DATE | NO | — | 001 | `ndtRfiDate` |
| `ndt_company_task` | TEXT | YES | — | 001 | `ndtCompanyTask` |
| `planned_start_date` | DATE | NO | — | 001 | `plannedStartDate` |
| `planned_end_date` | DATE | NO | — | 001 | `plannedEndDate` |
| `testing_status` | TEXT CHECK(planned,in_progress,completed,rejected,on_hold) | NO | 'planned' | 001 | `testingStatus` |
| `test_length` | NUMERIC(10,2) | NO | 0 | 001 | `testLength` |
| `reject_length` | NUMERIC(10,2) | NO | 0 | 001 | `rejectLength` |
| `priority` | TEXT CHECK(low,normal,high,urgent) | NO | 'normal' | 001 | `priority` |
| `rfi_sent_to_team` | BOOLEAN | NO | false | **002** | `rfiSentToTeam` |
| `type_of_testing` | TEXT | NO | — | 003 | `typeOfTesting` |
| `discipline` | TEXT CHECK(structure,piping,mechanical,electrical) | NO | — | 003 | `discipline` |
| `job_description` | TEXT | NO | — | 003 | `jobDescription` |
| `site_contact` | TEXT | NO | — | 003 | `siteContact` |
| `subcontractor` | TEXT | NO | — | 003 | `subcontractor` |
| `job_location` | TEXT | NO | — | 003 | `jobLocation` |
| `team_deploy_status` | TEXT CHECK(not_deployed,deployed,in_progress,completed) | NO | 'not_deployed' | 003 | `teamDeployStatus` |
| `accept_status` | TEXT CHECK(accept,reject,pending) | NO | 'pending' | 003 | `acceptStatus` |
| `created_at` | TIMESTAMPTZ | NO | now() | 001 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 001 | `updatedAt` |

> **Note on `job_location` duplication:** This column also exists on `ndt_team_deployments` (001, NOT NULL). The planning-level `job_location` (nullable) represents the RFI-level job location, while the deployment-level `job_location` represents where a deployed team is physically working. They serve different granularities and are intentionally separate.

### 6. ndt_team_deployments

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 001 | `id` |
| `project_ndt_planning_id` | UUID FK | YES | — | 001 | `projectNdtPlanningId` |
| `ndt_company_id` | UUID FK | YES | — | 001 | `ndtCompanyId` |
| `ndt_supervisor_id` | UUID FK → users | NO | — | 001 | `ndtSupervisorId` |
| `shift` | shift_type ENUM(day,night) | NO | 'day' | 001 | `shift` |
| `deployment_date` | DATE | YES | — | 001 | `deploymentDate` |
| `deployment_start_time` | TIMESTAMPTZ | NO | — | 001 | `deploymentStartTime` |
| `deployment_end_time` | TIMESTAMPTZ | NO | — | 001 | `deploymentEndTime` |
| `team_deployment` | TEXT | YES | — | 001 | `teamDeployment` |
| `team_members` | JSONB | NO | '[]' | 001 | `teamMembers` |
| `job_location` | TEXT | YES | — | 001 | `jobLocation` |
| `testing_status` | TEXT CHECK(not_started,in_progress,completed,rejected) | NO | 'not_started' | 001 | `testingStatus` |
| `test_length` | NUMERIC(10,2) | NO | 0 | 001 | `testLength` |
| `reject_length` | NUMERIC(10,2) | NO | 0 | 001 | `rejectLength` |
| `equipment_used` | JSONB | NO | '[]' | 001 | `equipmentUsed` |
| `daily_notes` | TEXT | NO | — | 001 | `dailyNotes` |
| `weather_conditions` | TEXT | NO | — | 001 | `weatherConditions` |
| `created_by` | UUID FK → users | NO | — | 001 | `createdBy` |
| `created_at` | TIMESTAMPTZ | NO | now() | 001 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 001 | `updatedAt` |
| `deleted_at` | TIMESTAMPTZ | NO | NULL (soft delete) | 001 | `deletedAt` |

Always filter `deleted_at IS NULL`.

### 7. ndt_team_assignments

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 001 | `id` |
| `user_id` | UUID FK → users | YES | — | 001 | `userId` |
| `project_id` | UUID FK → projects | YES | — | 001 | `projectId` |
| `ndt_company_id` | UUID FK → ndt_companies | YES | — | 001 | `ndtCompanyId` |
| `assigned_role` | TEXT CHECK(supervisor,technician,inspector,helper) | NO | 'technician' | 001 | `assignedRole` |
| `status` | TEXT CHECK(active,completed,on_hold,removed) | NO | 'active' | 001 | `status` |
| `assigned_from` | DATE | NO | — | 001 | `assignedFrom` |
| `assigned_to` | DATE | NO | — | 001 | `assignedTo` |
| `created_at` | TIMESTAMPTZ | NO | now() | 001 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 001 | `updatedAt` |

UNIQUE(user_id, project_id, assigned_role). No soft delete (hard delete via `remove()`).

### 8. audit_logs

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 001 | `id` |
| `table_name` | TEXT | YES | — | 001 | `tableName` |
| `record_id` | UUID | YES | — | 001 | `recordId` |
| `action` | TEXT CHECK(INSERT,UPDATE,DELETE) | YES | — | 001 | `action` |
| `old_data` | JSONB | NO | — | 001 | `oldData` |
| `new_data` | JSONB | NO | — | 001 | `newData` |
| `changed_by` | UUID FK → users | NO | — | 001 | `changedBy` |
| `changed_at` | TIMESTAMPTZ | NO | now() | 001 | `changedAt` |
| `ip_address` | INET | NO | — | 001 | `ipAddress` |

Admin-only RLS. FK `changed_by` → SET NULL (004).

### 9. notifications

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 002 | `id` |
| `user_id` | UUID FK → users CASCADE | YES | — | 002 | `userId` |
| `title` | TEXT | YES | — | 002 | `title` |
| `body` | TEXT | NO | — | 002 | `body` |
| `type` | TEXT CHECK(cert_expiry,approval_needed,rfi_dispatched,deployment_assigned) | NO | — | 002 | `type` |
| `read` | BOOLEAN | NO | false | 002 | `read` |
| `created_at` | TIMESTAMPTZ | NO | now() | 002 | `createdAt` |

No `updated_at` column (notifications are immutable after creation aside from the `read` flag).

### 10. ndt_professional_register

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 003 | `id` |
| `name` | TEXT | YES | — | 003 | `name` |
| `type_of_certificate` | TEXT | YES | — | 003 | `typeOfCertificate` |
| `certified_by` | TEXT | NO | — | 003 | `certifiedBy` |
| `issued_date` | DATE | YES | — | 003 | `issuedDate` |
| `expiry_date` | DATE | YES | — | 003 | `expiryDate` |
| `certificate_status` | TEXT CHECK(valid,expired,pending,revoked) | NO | 'valid' | 003 | `certificateStatus` |
| `working_sector` | TEXT CHECK(marine_section,industry_section) | YES | — | 003 | `workingSector` |
| `ndt_company_id` | UUID FK | NO | — | 003 | `ndtCompanyId` |
| `created_by` | UUID FK → users | NO | — | 003 | `createdBy` |
| `created_at` | TIMESTAMPTZ | NO | now() | 003 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 003 | `updatedAt` |
| `deleted_at` | TIMESTAMPTZ | NO | NULL (soft delete) | 003 | `deletedAt` |

Always filter `deleted_at IS NULL`.

### 11. ndt_professional_assignments

| Column | Type | Required | Default | Migration | Dart Field |
|--------|------|----------|---------|-----------|------------|
| `id` | UUID PK | YES | gen_random_uuid() | 004 | `id` |
| `planning_id` | UUID FK → project_ndt_planning CASCADE | YES | — | 004 | `planningId` |
| `professional_id` | UUID FK → ndt_professional_register CASCADE | YES | — | 004 | `professionalId` |
| `assigned_role` | TEXT CHECK(technician,inspector,helper,supervisor) | NO | 'technician' | 004 | `assignedRole` |
| `status` | TEXT CHECK(assigned,active,completed,removed) | NO | 'assigned' | 004 | `status` |
| `assigned_at` | TIMESTAMPTZ | NO | now() | 004 | `assignedAt` |
| `created_by` | UUID FK → users SET NULL | NO | — | 004 | `createdBy` |
| `created_at` | TIMESTAMPTZ | NO | now() | 004 | `createdAt` |
| `updated_at` | TIMESTAMPTZ | NO | now() | 004 | `updatedAt` |

UNIQUE(planning_id, professional_id).

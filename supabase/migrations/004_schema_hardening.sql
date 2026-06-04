-- =============================================================================
-- NDT Management App — Schema Hardening (Migration 004)
--
-- Addresses 6 verified issues from independent audit:
--   1. 17 FK columns missing ON DELETE rules
--   2.  4 FK audit columns missing indexes
--   3.  2 tables missing updated_at triggers (ndt_companies, users)
--   4.  2 tables missing RLS policies (ndt_companies ndt_team,
--      ndt_team_assignments ndt_team)
--   5.  0 existing CHECK constraints have valid syntax (no changes needed)
--   6. NEW: ndt_professional_assignments junction table
-- =============================================================================


-- 1. ADD ON DELETE RULES TO FOREIGN KEYS
-- PostgreSQL requires dropping and re-adding constraints to change ON DELETE.
-- We use a DO block to find auto-generated constraint names dynamically.
-- =============================================================================

DO $$
DECLARE
    constraint_name_var TEXT;
BEGIN
    -- 1.1 users.ndt_company_id → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'users'::regclass
        AND confrelid = 'ndt_companies'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE users DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE users ADD CONSTRAINT %I FOREIGN KEY (ndt_company_id) REFERENCES ndt_companies(id) ON DELETE SET NULL', constraint_name_var);
    END IF;

    -- 1.2 ndt_contractor_register.ndt_company_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_contractor_register'::regclass
        AND confrelid = 'ndt_companies'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_contractor_register DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_contractor_register ADD CONSTRAINT %I FOREIGN KEY (ndt_company_id) REFERENCES ndt_companies(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.3 ndt_contractor_register.created_by → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_contractor_register'::regclass
        AND confrelid = 'users'::regclass
        AND conkey @> ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = 'ndt_contractor_register'::regclass AND attname = 'created_by')];
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_contractor_register DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_contractor_register ADD CONSTRAINT %I FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL', constraint_name_var);
    END IF;

    -- 1.4 ndt_professional_register.ndt_company_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_professional_register'::regclass
        AND confrelid = 'ndt_companies'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_professional_register DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_professional_register ADD CONSTRAINT %I FOREIGN KEY (ndt_company_id) REFERENCES ndt_companies(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.5 ndt_professional_register.created_by → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_professional_register'::regclass
        AND confrelid = 'users'::regclass
        AND conkey @> ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = 'ndt_professional_register'::regclass AND attname = 'created_by')];
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_professional_register DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_professional_register ADD CONSTRAINT %I FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL', constraint_name_var);
    END IF;

    -- 1.6 projects.qa_incharge_id → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'projects'::regclass
        AND confrelid = 'users'::regclass
        AND conkey @> ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = 'projects'::regclass AND attname = 'qa_incharge_id')];
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE projects DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE projects ADD CONSTRAINT %I FOREIGN KEY (qa_incharge_id) REFERENCES users(id) ON DELETE SET NULL', constraint_name_var);
    END IF;

    -- 1.7 projects.ndt_company_id → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'projects'::regclass
        AND confrelid = 'ndt_companies'::regclass
        AND conkey @> ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = 'projects'::regclass AND attname = 'ndt_company_id')];
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE projects DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE projects ADD CONSTRAINT %I FOREIGN KEY (ndt_company_id) REFERENCES ndt_companies(id) ON DELETE SET NULL', constraint_name_var);
    END IF;

    -- 1.8 project_ndt_planning.project_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'project_ndt_planning'::regclass
        AND confrelid = 'projects'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE project_ndt_planning DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE project_ndt_planning ADD CONSTRAINT %I FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.9 project_ndt_planning.ndt_company_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'project_ndt_planning'::regclass
        AND confrelid = 'ndt_companies'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE project_ndt_planning DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE project_ndt_planning ADD CONSTRAINT %I FOREIGN KEY (ndt_company_id) REFERENCES ndt_companies(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.10 ndt_team_deployments.project_ndt_planning_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_team_deployments'::regclass
        AND confrelid = 'project_ndt_planning'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_team_deployments DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_team_deployments ADD CONSTRAINT %I FOREIGN KEY (project_ndt_planning_id) REFERENCES project_ndt_planning(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.11 ndt_team_deployments.ndt_company_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_team_deployments'::regclass
        AND confrelid = 'ndt_companies'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_team_deployments DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_team_deployments ADD CONSTRAINT %I FOREIGN KEY (ndt_company_id) REFERENCES ndt_companies(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.12 ndt_team_deployments.ndt_supervisor_id → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_team_deployments'::regclass
        AND confrelid = 'users'::regclass
        AND conkey @> ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = 'ndt_team_deployments'::regclass AND attname = 'ndt_supervisor_id')];
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_team_deployments DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_team_deployments ADD CONSTRAINT %I FOREIGN KEY (ndt_supervisor_id) REFERENCES users(id) ON DELETE SET NULL', constraint_name_var);
    END IF;

    -- 1.13 ndt_team_deployments.created_by → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_team_deployments'::regclass
        AND confrelid = 'users'::regclass
        AND conkey @> ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = 'ndt_team_deployments'::regclass AND attname = 'created_by')];
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_team_deployments DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_team_deployments ADD CONSTRAINT %I FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL', constraint_name_var);
    END IF;

    -- 1.14 ndt_team_assignments.user_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_team_assignments'::regclass
        AND confrelid = 'users'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_team_assignments DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_team_assignments ADD CONSTRAINT %I FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.15 ndt_team_assignments.project_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_team_assignments'::regclass
        AND confrelid = 'projects'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_team_assignments DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_team_assignments ADD CONSTRAINT %I FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.16 ndt_team_assignments.ndt_company_id → CASCADE
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'ndt_team_assignments'::regclass
        AND confrelid = 'ndt_companies'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE ndt_team_assignments DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE ndt_team_assignments ADD CONSTRAINT %I FOREIGN KEY (ndt_company_id) REFERENCES ndt_companies(id) ON DELETE CASCADE', constraint_name_var);
    END IF;

    -- 1.17 audit_logs.changed_by → SET NULL
    SELECT conname INTO constraint_name_var
        FROM pg_constraint WHERE conrelid = 'audit_logs'::regclass
        AND confrelid = 'users'::regclass AND contype = 'f';
    IF constraint_name_var IS NOT NULL THEN
        EXECUTE format('ALTER TABLE audit_logs DROP CONSTRAINT %I', constraint_name_var);
        EXECUTE format('ALTER TABLE audit_logs ADD CONSTRAINT %I FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL', constraint_name_var);
    END IF;
END $$;


-- 2. ADD MISSING INDEXES ON FK AUDIT COLUMNS
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_contractor_created_by
    ON ndt_contractor_register(created_by);

CREATE INDEX IF NOT EXISTS idx_professional_created_by
    ON ndt_professional_register(created_by);

CREATE INDEX IF NOT EXISTS idx_deployments_created_by
    ON ndt_team_deployments(created_by);

CREATE INDEX IF NOT EXISTS idx_audit_changed_by
    ON audit_logs(changed_by);


-- 3. ADD MISSING updated_at TRIGGERS
-- Both ndt_companies and users have updated_at columns but no auto-update trigger.
-- =============================================================================

CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON ndt_companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- 4. ADD MISSING RLS POLICIES
-- =============================================================================

-- 4.1 ndt_team can now view their own company row
-- Previously ndt_team had NO policy on ndt_companies (zero rows visible).
-- This broke company name resolution on team member dashboards.
DROP POLICY IF EXISTS "team_view_own_company" ON ndt_companies;
CREATE POLICY "team_view_own_company"
    ON ndt_companies FOR SELECT
    USING (
        auth.jwt()->>'role' = 'ndt_team'
        AND id = get_user_company_id()
    );

-- 4.2 ndt_team can now view their own assignments
-- Previously ndt_team had NO policy on ndt_team_assignments.
-- This caused team_view_assigned_projects subqueries to return empty results,
-- silently breaking the team member's assigned project/planning/deployment views.
DROP POLICY IF EXISTS "team_view_own_assignments" ON ndt_team_assignments;
CREATE POLICY "team_view_own_assignments"
    ON ndt_team_assignments FOR SELECT
    USING (
        auth.jwt()->>'role' = 'ndt_team'
        AND user_id = auth.uid()
    );

-- Note: audit_logs intentionally remains admin-only.
-- Exposing audit trails to company/team roles would leak cross-company data.


-- 5. NEW TABLE: ndt_professional_assignments
-- Junction table linking NDT professionals to specific RFI/planning entries.
-- This is the missing link in the QA → Contractor → Supervisor → Professional workflow.
-- =============================================================================

CREATE TABLE IF NOT EXISTS ndt_professional_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    planning_id UUID NOT NULL REFERENCES project_ndt_planning(id) ON DELETE CASCADE,
    professional_id UUID NOT NULL REFERENCES ndt_professional_register(id) ON DELETE CASCADE,
    assigned_role TEXT NOT NULL DEFAULT 'technician'
        CHECK (assigned_role IN ('technician', 'inspector', 'helper', 'supervisor')),
    status TEXT NOT NULL DEFAULT 'assigned'
        CHECK (status IN ('assigned', 'active', 'completed', 'removed')),
    assigned_at TIMESTAMPTZ DEFAULT now(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(planning_id, professional_id)
);

COMMENT ON TABLE ndt_professional_assignments IS
    'Junction table: assigns NDT professionals to specific RFI/planning entries. Enables the supervisor-to-professional tasking workflow.';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_prof_assign_planning
    ON ndt_professional_assignments(planning_id);
CREATE INDEX IF NOT EXISTS idx_prof_assign_professional
    ON ndt_professional_assignments(professional_id);
CREATE INDEX IF NOT EXISTS idx_prof_assign_status
    ON ndt_professional_assignments(status);

-- Updated_at trigger
CREATE TRIGGER update_prof_assignments_updated_at
    BEFORE UPDATE ON ndt_professional_assignments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Audit trigger
CREATE TRIGGER audit_prof_assignments
    AFTER INSERT OR UPDATE OR DELETE ON ndt_professional_assignments
    FOR EACH ROW EXECUTE FUNCTION audit_trigger();

-- RLS
ALTER TABLE ndt_professional_assignments ENABLE ROW LEVEL SECURITY;

-- Admin: full access
CREATE POLICY "admin_all_prof_assignments"
    ON ndt_professional_assignments FOR ALL
    USING (auth.jwt()->>'role' = 'admin')
    WITH CHECK (auth.jwt()->>'role' = 'admin');

-- Company: own data (via planning → ndt_company_id chain)
CREATE POLICY "company_own_prof_assignments"
    ON ndt_professional_assignments FOR ALL
    USING (
        auth.jwt()->>'role' = 'ndt_company'
        AND EXISTS (
            SELECT 1 FROM project_ndt_planning p
            WHERE p.id = ndt_professional_assignments.planning_id
            AND p.ndt_company_id = get_user_company_id()
        )
    )
    WITH CHECK (
        auth.jwt()->>'role' = 'ndt_company'
        AND EXISTS (
            SELECT 1 FROM project_ndt_planning p
            WHERE p.id = ndt_professional_assignments.planning_id
            AND p.ndt_company_id = get_user_company_id()
        )
    );

-- Team: view assignments for professionals in their company
CREATE POLICY "team_view_company_prof_assignments"
    ON ndt_professional_assignments FOR SELECT
    USING (
        auth.jwt()->>'role' = 'ndt_team'
        AND EXISTS (
            SELECT 1 FROM project_ndt_planning p
            WHERE p.id = ndt_professional_assignments.planning_id
            AND p.ndt_company_id = get_user_company_id()
        )
    );

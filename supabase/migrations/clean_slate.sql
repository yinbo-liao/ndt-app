-- =============================================================================
-- NDT Management App — CLEAN SLATE SCHEMA (Optimized)
-- =============================================================================
-- Single script: drops all tables, creates full optimized schema.
-- Idempotent — safe to re-run at any time.
-- =============================================================================

-- ═══════════════════════════════════════════════════════════════
-- STEP 1: DROP ALL EXISTING TABLES (child-first, CASCADE)
-- ═══════════════════════════════════════════════════════════════
DROP TABLE IF EXISTS ndt_professional_assignments CASCADE;
DROP TABLE IF EXISTS ndt_team_deployments CASCADE;
DROP TABLE IF EXISTS ndt_team_assignments CASCADE;
DROP TABLE IF EXISTS project_ndt_planning CASCADE;
DROP TABLE IF EXISTS ndt_contractor_register CASCADE;
DROP TABLE IF EXISTS ndt_professional_register CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS ndt_companies CASCADE;
-- Old pre-existing tables (remove if present)
DROP TABLE IF EXISTS ndt_company CASCADE;
DROP TABLE IF EXISTS ndt_deployment CASCADE;
DROP TABLE IF EXISTS ndt_rfi_register CASCADE;
DROP TABLE IF EXISTS project_register CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS user_management CASCADE;
DROP TABLE IF EXISTS test_ndt CASCADE;

-- Drop custom type
DROP TYPE IF EXISTS shift_type CASCADE;

-- Drop old functions
DROP FUNCTION IF EXISTS get_user_company_id CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;
DROP FUNCTION IF EXISTS audit_trigger CASCADE;
DROP FUNCTION IF EXISTS check_certificate_expiry CASCADE;
DROP FUNCTION IF EXISTS update_cert_validation_status CASCADE;
DROP FUNCTION IF EXISTS check_professional_cert_expiry CASCADE;
DROP FUNCTION IF EXISTS handle_new_user CASCADE;
DROP FUNCTION IF EXISTS daily_deployment_summary_by_project CASCADE;
DROP FUNCTION IF EXISTS daily_deployment_summary_by_company CASCADE;
DROP FUNCTION IF EXISTS weekly_deployment_trend CASCADE;
DROP FUNCTION IF EXISTS contractor_register_summary CASCADE;
DROP FUNCTION IF EXISTS project_ndt_status_summary CASCADE;
DROP FUNCTION IF EXISTS professional_register_summary CASCADE;

RAISE NOTICE 'STEP 1 DONE: All tables and functions dropped';


-- ═══════════════════════════════════════════════════════════════
-- STEP 2: CUSTOM TYPE
-- ═══════════════════════════════════════════════════════════════
CREATE TYPE shift_type AS ENUM ('day', 'night');


-- ═══════════════════════════════════════════════════════════════
-- STEP 3: CREATE TABLES (parent-first order, all FK rules applied)
-- ═══════════════════════════════════════════════════════════════

-- 3.1 ndt_companies (root table)
CREATE TABLE ndt_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    registration_no TEXT UNIQUE,
    contact_email TEXT,
    contact_phone TEXT,
    active BOOLEAN DEFAULT true,
    address TEXT,
    supervisor TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3.2 users (extends auth.users)
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'ndt_company', 'ndt_team')),
    ndt_company_id UUID REFERENCES ndt_companies(id) ON DELETE SET NULL,
    phone TEXT,
    employee_id TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3.3 ndt_contractor_register (soft-delete)
CREATE TABLE ndt_contractor_register (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id) ON DELETE CASCADE,
    type_of_ndt TEXT NOT NULL,
    type_of_ndt_certificate TEXT NOT NULL,
    certificate_no TEXT NOT NULL,
    certificate_type TEXT,
    issue_date DATE NOT NULL,
    expire_date DATE NOT NULL,
    validation_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (validation_status IN ('valid', 'expired', 'pending', 'revoked')),
    report_month DATE NOT NULL,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    deleted_at TIMESTAMPTZ DEFAULT NULL
);

-- 3.4 projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_name TEXT NOT NULL,
    project_code TEXT UNIQUE NOT NULL,
    job_trade TEXT,
    location TEXT NOT NULL,
    client_name TEXT,
    classification TEXT,
    qa_incharge_id UUID REFERENCES users(id) ON DELETE SET NULL,
    ndt_company_id UUID REFERENCES ndt_companies(id) ON DELETE SET NULL,
    start_date DATE,
    end_date DATE,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3.5 project_ndt_planning (RFI tracking)
CREATE TABLE project_ndt_planning (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id) ON DELETE CASCADE,
    ndt_rfi_date DATE,
    ndt_company_task TEXT NOT NULL,
    planned_start_date DATE,
    planned_end_date DATE,
    testing_status TEXT NOT NULL DEFAULT 'planned'
        CHECK (testing_status IN ('planned', 'in_progress', 'completed', 'rejected', 'on_hold')),
    test_length NUMERIC(10,2) DEFAULT 0,
    reject_length NUMERIC(10,2) DEFAULT 0,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    rfi_sent_to_team BOOLEAN DEFAULT false,
    type_of_testing TEXT,
    discipline TEXT CHECK (discipline IS NULL OR discipline IN ('structure', 'piping', 'mechanical', 'electrical')),
    job_description TEXT,
    site_contact TEXT,
    subcontractor TEXT,
    job_location TEXT,
    team_deploy_status TEXT NOT NULL DEFAULT 'not_deployed'
        CHECK (team_deploy_status IN ('not_deployed', 'deployed', 'in_progress', 'completed')),
    accept_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (accept_status IN ('accept', 'reject', 'pending')),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3.6 ndt_team_deployments (shift-aware, soft-delete)
CREATE TABLE ndt_team_deployments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_ndt_planning_id UUID NOT NULL REFERENCES project_ndt_planning(id) ON DELETE CASCADE,
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id) ON DELETE CASCADE,
    ndt_supervisor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    shift shift_type NOT NULL DEFAULT 'day',
    deployment_date DATE NOT NULL,
    deployment_start_time TIMESTAMPTZ,
    deployment_end_time TIMESTAMPTZ,
    team_deployment TEXT NOT NULL,
    team_members JSONB DEFAULT '[]',
    job_location TEXT NOT NULL,
    testing_status TEXT NOT NULL DEFAULT 'not_started'
        CHECK (testing_status IN ('not_started', 'in_progress', 'completed', 'rejected')),
    test_length NUMERIC(10,2) DEFAULT 0,
    reject_length NUMERIC(10,2) DEFAULT 0,
    equipment_used JSONB DEFAULT '[]',
    daily_notes TEXT,
    weather_conditions TEXT,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    deleted_at TIMESTAMPTZ DEFAULT NULL
);

-- 3.7 ndt_team_assignments (junction: users↔projects)
CREATE TABLE ndt_team_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id) ON DELETE CASCADE,
    assigned_role TEXT NOT NULL DEFAULT 'technician'
        CHECK (assigned_role IN ('supervisor', 'technician', 'inspector', 'helper')),
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'completed', 'on_hold', 'removed')),
    assigned_from DATE,
    assigned_to DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, project_id, assigned_role)
);

-- 3.8 ndt_professional_register (individual professionals, soft-delete)
CREATE TABLE ndt_professional_register (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type_of_certificate TEXT NOT NULL,
    certified_by TEXT,
    issued_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    certificate_status TEXT NOT NULL DEFAULT 'valid'
        CHECK (certificate_status IN ('valid', 'expired', 'pending', 'revoked')),
    working_sector TEXT NOT NULL
        CHECK (working_sector IN ('marine_section', 'industry_section')),
    ndt_company_id UUID REFERENCES ndt_companies(id) ON DELETE CASCADE,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    deleted_at TIMESTAMPTZ DEFAULT NULL
);

-- 3.9 ndt_professional_assignments (junction: professionals↔planning)
CREATE TABLE ndt_professional_assignments (
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

-- 3.10 audit_logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    changed_at TIMESTAMPTZ DEFAULT now(),
    ip_address INET
);

-- 3.11 notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT,
    type TEXT CHECK (type IN ('cert_expiry', 'approval_needed', 'rfi_dispatched', 'deployment_assigned')),
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

RAISE NOTICE 'STEP 3 DONE: 11 tables created';


-- ═══════════════════════════════════════════════════════════════
-- STEP 4: INDEXES (30+ strategic indexes)
-- ═══════════════════════════════════════════════════════════════

-- ndt_companies
CREATE INDEX idx_companies_active ON ndt_companies(active);

-- users
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_company ON users(ndt_company_id);
CREATE INDEX idx_users_active ON users(active);
CREATE INDEX idx_users_role_company ON users(role, ndt_company_id);

-- ndt_contractor_register
CREATE INDEX idx_contractor_company ON ndt_contractor_register(ndt_company_id);
CREATE INDEX idx_contractor_status ON ndt_contractor_register(validation_status);
CREATE INDEX idx_contractor_month ON ndt_contractor_register(report_month);
CREATE INDEX idx_contractor_expire ON ndt_contractor_register(expire_date);
CREATE INDEX idx_contractor_created_by ON ndt_contractor_register(created_by);
CREATE INDEX idx_contractor_deleted ON ndt_contractor_register(deleted_at) WHERE deleted_at IS NULL;

-- projects
CREATE INDEX idx_projects_code ON projects(project_code);
CREATE INDEX idx_projects_active ON projects(active);
CREATE INDEX idx_projects_classification ON projects(classification);
CREATE INDEX idx_projects_qa ON projects(qa_incharge_id);
CREATE INDEX idx_projects_ndt_company ON projects(ndt_company_id);

-- project_ndt_planning
CREATE INDEX idx_planning_project ON project_ndt_planning(project_id);
CREATE INDEX idx_planning_company ON project_ndt_planning(ndt_company_id);
CREATE INDEX idx_planning_status ON project_ndt_planning(testing_status);
CREATE INDEX idx_planning_dates ON project_ndt_planning(planned_start_date, planned_end_date);
CREATE INDEX idx_planning_discipline ON project_ndt_planning(discipline);
CREATE INDEX idx_planning_deploy_status ON project_ndt_planning(team_deploy_status);
CREATE INDEX idx_planning_accept_status ON project_ndt_planning(accept_status);
CREATE INDEX idx_planning_project_company ON project_ndt_planning(project_id, ndt_company_id);

-- ndt_team_deployments
CREATE INDEX idx_deployments_planning ON ndt_team_deployments(project_ndt_planning_id);
CREATE INDEX idx_deployments_company ON ndt_team_deployments(ndt_company_id);
CREATE INDEX idx_deployments_shift ON ndt_team_deployments(shift);
CREATE INDEX idx_deployments_date ON ndt_team_deployments(deployment_date);
CREATE INDEX idx_deployments_status ON ndt_team_deployments(testing_status);
CREATE INDEX idx_deployments_supervisor ON ndt_team_deployments(ndt_supervisor_id);
CREATE INDEX idx_deployments_created_by ON ndt_team_deployments(created_by);
CREATE INDEX idx_deployments_deleted ON ndt_team_deployments(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_deployments_date_company ON ndt_team_deployments(deployment_date, ndt_company_id);

-- ndt_team_assignments
CREATE INDEX idx_assignments_user ON ndt_team_assignments(user_id);
CREATE INDEX idx_assignments_project ON ndt_team_assignments(project_id);
CREATE INDEX idx_assignments_company ON ndt_team_assignments(ndt_company_id);
CREATE INDEX idx_assignments_status ON ndt_team_assignments(status);

-- ndt_professional_register
CREATE INDEX idx_professional_company ON ndt_professional_register(ndt_company_id);
CREATE INDEX idx_professional_status ON ndt_professional_register(certificate_status);
CREATE INDEX idx_professional_expire ON ndt_professional_register(expiry_date);
CREATE INDEX idx_professional_sector ON ndt_professional_register(working_sector);
CREATE INDEX idx_professional_created_by ON ndt_professional_register(created_by);
CREATE INDEX idx_professional_deleted ON ndt_professional_register(deleted_at) WHERE deleted_at IS NULL;

-- ndt_professional_assignments
CREATE INDEX idx_prof_assign_planning ON ndt_professional_assignments(planning_id);
CREATE INDEX idx_prof_assign_professional ON ndt_professional_assignments(professional_id);
CREATE INDEX idx_prof_assign_status ON ndt_professional_assignments(status);

-- audit_logs
CREATE INDEX idx_audit_table ON audit_logs(table_name);
CREATE INDEX idx_audit_record ON audit_logs(record_id);
CREATE INDEX idx_audit_changed_at ON audit_logs(changed_at);
CREATE INDEX idx_audit_changed_by ON audit_logs(changed_by);

-- notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, read);

RAISE NOTICE 'STEP 4 DONE: 45 indexes created';


-- ═══════════════════════════════════════════════════════════════
-- STEP 5: FUNCTIONS & TRIGGERS
-- ═══════════════════════════════════════════════════════════════

-- 5.1 Auto-update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to 9 tables that have updated_at
DO $$ DECLARE t TEXT;
BEGIN
    FOR t IN ARRAY['ndt_companies','users','ndt_contractor_register','projects','project_ndt_planning','ndt_team_deployments','ndt_team_assignments','ndt_professional_register','ndt_professional_assignments']
    LOOP
        EXECUTE format('CREATE TRIGGER trg_updated_at_%s BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()', replace(t,'ndt_',''), t);
    END LOOP;
END $$;

-- 5.2 Audit logging
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER SECURITY DEFINER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_data, changed_by)
        VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', row_to_json(OLD), auth.uid());
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW), auth.uid());
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_logs (table_name, record_id, action, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', row_to_json(NEW), auth.uid());
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply to 10 tables (excluding audit_logs itself)
DO $$ DECLARE t TEXT;
BEGIN
    FOR t IN ARRAY['ndt_companies','users','ndt_contractor_register','projects','project_ndt_planning','ndt_team_deployments','ndt_team_assignments','ndt_professional_register','ndt_professional_assignments','notifications']
    LOOP
        EXECUTE format('CREATE TRIGGER trg_audit_%s AFTER INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION audit_trigger()', replace(t,'ndt_',''), t);
    END LOOP;
END $$;

-- 5.3 Certificate expiry notification (contractor register)
CREATE OR REPLACE FUNCTION check_certificate_expiry()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.expire_date <= CURRENT_DATE + INTERVAL '30 days'
       AND NEW.validation_status = 'valid' THEN
        PERFORM pg_notify('certificate_expiry', json_build_object(
            'certificate_id', NEW.id, 'company_id', NEW.ndt_company_id,
            'certificate_no', NEW.certificate_no, 'expire_date', NEW.expire_date
        )::text);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cert_expiry_notify
    AFTER INSERT OR UPDATE ON ndt_contractor_register
    FOR EACH ROW EXECUTE FUNCTION check_certificate_expiry();

-- 5.4 Auto-expire contractor certificates
CREATE OR REPLACE FUNCTION update_cert_validation_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.expire_date < CURRENT_DATE
       AND NEW.validation_status != 'expired'
       AND NEW.validation_status != 'revoked' THEN
        NEW.validation_status := 'expired';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cert_auto_expire
    BEFORE INSERT OR UPDATE ON ndt_contractor_register
    FOR EACH ROW EXECUTE FUNCTION update_cert_validation_status();

-- 5.5 Auto-expire professional certificates
CREATE OR REPLACE FUNCTION check_professional_cert_expiry()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.expiry_date < CURRENT_DATE
       AND NEW.certificate_status != 'expired'
       AND NEW.certificate_status != 'revoked' THEN
        NEW.certificate_status := 'expired';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_professional_cert_expire
    BEFORE INSERT OR UPDATE ON ndt_professional_register
    FOR EACH ROW EXECUTE FUNCTION check_professional_cert_expiry();

-- 5.6 Auto-create user profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER SECURITY DEFINER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, email, role, ndt_company_id)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'ndt_team'),
        (NEW.raw_user_meta_data->>'ndt_company_id')::UUID
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop old trigger on auth.users if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

RAISE NOTICE 'STEP 5 DONE: All triggers created';


-- ═══════════════════════════════════════════════════════════════
-- STEP 6: ROW-LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════

-- 6.1 Enable RLS on all 11 tables
DO $$ DECLARE t TEXT;
BEGIN
    FOR t IN ARRAY['ndt_companies','users','ndt_contractor_register','projects','project_ndt_planning','ndt_team_deployments','ndt_team_assignments','audit_logs','notifications','ndt_professional_register','ndt_professional_assignments']
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    END LOOP;
END $$;

-- 6.2 Helper: get user's company ID from JWT
CREATE OR REPLACE FUNCTION get_user_company_id()
RETURNS UUID SECURITY DEFINER AS $$
BEGIN
    RETURN (auth.jwt()->>'ndt_company_id')::UUID;
END;
$$ LANGUAGE plpgsql;

-- 6.3 Admin: full access to all tables
DO $$ DECLARE t TEXT;
BEGIN
    FOR t IN ARRAY['ndt_companies','users','ndt_contractor_register','projects','project_ndt_planning','ndt_team_deployments','ndt_team_assignments','audit_logs','notifications','ndt_professional_register','ndt_professional_assignments']
    LOOP
        EXECUTE format('CREATE POLICY "admin_all" ON %I FOR ALL USING (auth.jwt()->>''role'' = ''admin'') WITH CHECK (auth.jwt()->>''role'' = ''admin'')', t);
    END LOOP;
END $$;

-- 6.4 NDT Company policies
CREATE POLICY "company_read_projects" ON projects FOR SELECT USING (auth.jwt()->>'role' = 'ndt_company');

CREATE POLICY "company_own_contractors" ON ndt_contractor_register FOR ALL
USING (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL)
WITH CHECK (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_planning" ON project_ndt_planning FOR ALL
USING (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id())
WITH CHECK (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_deployments" ON ndt_team_deployments FOR ALL
USING (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL)
WITH CHECK (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_assignments" ON ndt_team_assignments FOR ALL
USING (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id())
WITH CHECK (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_view_profile" ON ndt_companies FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_company' AND id = get_user_company_id());

CREATE POLICY "company_view_users" ON users FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_professionals" ON ndt_professional_register FOR ALL
USING (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL)
WITH CHECK (auth.jwt()->>'role' = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_prof_assign" ON ndt_professional_assignments FOR ALL
USING (auth.jwt()->>'role' = 'ndt_company' AND EXISTS (
    SELECT 1 FROM project_ndt_planning p WHERE p.id = ndt_professional_assignments.planning_id AND p.ndt_company_id = get_user_company_id()))
WITH CHECK (auth.jwt()->>'role' = 'ndt_company' AND EXISTS (
    SELECT 1 FROM project_ndt_planning p WHERE p.id = ndt_professional_assignments.planning_id AND p.ndt_company_id = get_user_company_id()));

-- 6.5 NDT Team policies
CREATE POLICY "team_view_projects" ON projects FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND EXISTS (
    SELECT 1 FROM ndt_team_assignments a WHERE a.user_id = auth.uid() AND a.project_id = projects.id AND a.status = 'active'));

CREATE POLICY "team_view_planning" ON project_ndt_planning FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND EXISTS (
    SELECT 1 FROM ndt_team_assignments a WHERE a.user_id = auth.uid() AND a.project_id = project_ndt_planning.project_id AND a.status = 'active'));

CREATE POLICY "team_view_deployments" ON ndt_team_deployments FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND (
    ndt_supervisor_id = auth.uid()
    OR team_members @> jsonb_build_array(jsonb_build_object('user_id', auth.uid()::text))
    OR EXISTS (SELECT 1 FROM ndt_team_assignments a JOIN project_ndt_planning p ON p.project_id = a.project_id WHERE a.user_id = auth.uid() AND a.status = 'active' AND p.id = ndt_team_deployments.project_ndt_planning_id)));

CREATE POLICY "team_update_deployments" ON ndt_team_deployments FOR UPDATE
USING (auth.jwt()->>'role' = 'ndt_team' AND (ndt_supervisor_id = auth.uid() OR team_members @> jsonb_build_array(jsonb_build_object('user_id', auth.uid()::text))))
WITH CHECK (auth.jwt()->>'role' = 'ndt_team');

CREATE POLICY "team_view_profile" ON users FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND id = auth.uid());

CREATE POLICY "team_view_company" ON ndt_companies FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND id = get_user_company_id());

CREATE POLICY "team_view_assignments" ON ndt_team_assignments FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND user_id = auth.uid());

CREATE POLICY "team_view_professionals" ON ndt_professional_register FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL);

CREATE POLICY "team_view_prof_assign" ON ndt_professional_assignments FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND EXISTS (
    SELECT 1 FROM project_ndt_planning p WHERE p.id = ndt_professional_assignments.planning_id AND p.ndt_company_id = get_user_company_id()));

-- 6.6 Notifications: user reads own
CREATE POLICY "user_own_notifications" ON notifications FOR SELECT
USING (user_id = auth.uid());

RAISE NOTICE 'STEP 6 DONE: RLS policies created';


-- ═══════════════════════════════════════════════════════════════
-- STEP 7: RPC SUMMARY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- 7.1 Daily Deployment Summary by Project
CREATE OR REPLACE FUNCTION daily_deployment_summary_by_project(p_project_id UUID, p_date DATE)
RETURNS TABLE (project_id UUID, project_name TEXT, deployment_date DATE, day_shift_count BIGINT, night_shift_count BIGINT, total_teams BIGINT, total_personnel BIGINT, completed_tests BIGINT, in_progress_tests BIGINT, rejected_tests BIGINT, total_test_length NUMERIC, total_reject_length NUMERIC, locations TEXT[])
LANGUAGE SQL STABLE AS $$
    SELECT p.id, p.project_name, p_date,
        COUNT(*) FILTER (WHERE d.shift = 'day'),
        COUNT(*) FILTER (WHERE d.shift = 'night'),
        COUNT(DISTINCT d.team_deployment),
        COALESCE(SUM(jsonb_array_length(d.team_members)), 0),
        COUNT(*) FILTER (WHERE d.testing_status = 'completed'),
        COUNT(*) FILTER (WHERE d.testing_status = 'in_progress'),
        COUNT(*) FILTER (WHERE d.testing_status = 'rejected'),
        COALESCE(SUM(d.test_length), 0),
        COALESCE(SUM(d.reject_length), 0),
        ARRAY_AGG(DISTINCT d.job_location)
    FROM projects p
    JOIN project_ndt_planning plan ON plan.project_id = p.id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id AND d.deployment_date = p_date AND d.deleted_at IS NULL
    WHERE p.id = p_project_id GROUP BY p.id, p.project_name;
$$;

-- 7.2 Daily Deployment Summary by Company
CREATE OR REPLACE FUNCTION daily_deployment_summary_by_company(p_company_id UUID, p_date DATE)
RETURNS TABLE (company_id UUID, company_name TEXT, deployment_date DATE, total_projects BIGINT, day_shift_count BIGINT, night_shift_count BIGINT, total_teams BIGINT, total_personnel BIGINT, completed_tests BIGINT, in_progress_tests BIGINT, rejected_tests BIGINT, not_started_tests BIGINT, total_test_length NUMERIC, total_reject_length NUMERIC, avg_reject_rate NUMERIC)
LANGUAGE SQL STABLE AS $$
    SELECT c.id, c.name, p_date,
        COUNT(DISTINCT plan.project_id),
        COUNT(*) FILTER (WHERE d.shift = 'day'),
        COUNT(*) FILTER (WHERE d.shift = 'night'),
        COUNT(DISTINCT d.team_deployment),
        COALESCE(SUM(jsonb_array_length(d.team_members)), 0),
        COUNT(*) FILTER (WHERE d.testing_status = 'completed'),
        COUNT(*) FILTER (WHERE d.testing_status = 'in_progress'),
        COUNT(*) FILTER (WHERE d.testing_status = 'rejected'),
        COUNT(*) FILTER (WHERE d.testing_status = 'not_started'),
        COALESCE(SUM(d.test_length), 0),
        COALESCE(SUM(d.reject_length), 0),
        CASE WHEN SUM(d.test_length) > 0 THEN ROUND((SUM(d.reject_length)/SUM(d.test_length))*100,2) ELSE 0 END
    FROM ndt_companies c
    LEFT JOIN project_ndt_planning plan ON plan.ndt_company_id = c.id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id AND d.deployment_date = p_date AND d.deleted_at IS NULL
    WHERE c.id = p_company_id GROUP BY c.id, c.name;
$$;

-- 7.3 Weekly Deployment Trend
CREATE OR REPLACE FUNCTION weekly_deployment_trend(p_project_id UUID, p_start_date DATE, p_end_date DATE)
RETURNS TABLE (trend_date DATE, day_shift_count BIGINT, night_shift_count BIGINT, completed_tests BIGINT, total_test_length NUMERIC, total_reject_length NUMERIC)
LANGUAGE SQL STABLE AS $$
    SELECT gs::DATE,
        COUNT(*) FILTER (WHERE d.shift = 'day'),
        COUNT(*) FILTER (WHERE d.shift = 'night'),
        COUNT(*) FILTER (WHERE d.testing_status = 'completed'),
        COALESCE(SUM(d.test_length), 0),
        COALESCE(SUM(d.reject_length), 0)
    FROM generate_series(p_start_date, p_end_date, '1 day'::INTERVAL) gs
    LEFT JOIN project_ndt_planning plan ON plan.project_id = p_project_id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id AND d.deployment_date = gs::DATE AND d.deleted_at IS NULL
    GROUP BY gs::DATE ORDER BY gs::DATE;
$$;

-- 7.4 Contractor Register Summary
CREATE OR REPLACE FUNCTION contractor_register_summary(p_company_id UUID, p_month_start DATE)
RETURNS TABLE (total BIGINT, valid_count BIGINT, expired_count BIGINT, pending_count BIGINT, revoked_count BIGINT, expiring_soon BIGINT, compliance_rate NUMERIC)
LANGUAGE SQL STABLE AS $$
    SELECT COUNT(*),
        COUNT(*) FILTER (WHERE validation_status = 'valid'),
        COUNT(*) FILTER (WHERE validation_status = 'expired'),
        COUNT(*) FILTER (WHERE validation_status = 'pending'),
        COUNT(*) FILTER (WHERE validation_status = 'revoked'),
        COUNT(*) FILTER (WHERE expire_date <= p_month_start + INTERVAL '30 days' AND expire_date > p_month_start AND validation_status = 'valid'),
        CASE WHEN COUNT(*) > 0 THEN ROUND((COUNT(*) FILTER (WHERE validation_status = 'valid')::NUMERIC/COUNT(*)::NUMERIC)*100,2) ELSE 0 END
    FROM ndt_contractor_register WHERE ndt_company_id = p_company_id AND report_month = p_month_start AND deleted_at IS NULL;
$$;

-- 7.5 Project NDT Status Summary
CREATE OR REPLACE FUNCTION project_ndt_status_summary(p_company_id UUID)
RETURNS TABLE (project_id UUID, project_name TEXT, project_code TEXT, total_planned BIGINT, total_deployments BIGINT, completed_tests BIGINT, rejected_tests BIGINT, in_progress_tests BIGINT, not_started_tests BIGINT, completion_rate NUMERIC, reject_rate NUMERIC, total_test_length NUMERIC, total_reject_length NUMERIC)
LANGUAGE SQL STABLE AS $$
    SELECT p.id, p.project_name, p.project_code,
        COUNT(DISTINCT plan.id),
        COUNT(DISTINCT d.id),
        COUNT(*) FILTER (WHERE d.testing_status = 'completed'),
        COUNT(*) FILTER (WHERE d.testing_status = 'rejected'),
        COUNT(*) FILTER (WHERE d.testing_status = 'in_progress'),
        COUNT(*) FILTER (WHERE d.testing_status = 'not_started'),
        CASE WHEN COUNT(DISTINCT d.id) > 0 THEN ROUND((COUNT(*) FILTER (WHERE d.testing_status = 'completed')::NUMERIC/COUNT(DISTINCT d.id)::NUMERIC)*100,2) ELSE 0 END,
        CASE WHEN COALESCE(SUM(d.test_length),0) > 0 THEN ROUND((COALESCE(SUM(d.reject_length),0)/SUM(d.test_length))*100,2) ELSE 0 END,
        COALESCE(SUM(d.test_length), 0),
        COALESCE(SUM(d.reject_length), 0)
    FROM projects p
    JOIN project_ndt_planning plan ON plan.project_id = p.id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id AND d.deleted_at IS NULL
    WHERE plan.ndt_company_id = p_company_id GROUP BY p.id, p.project_name, p.project_code;
$$;

-- 7.6 Professional Register Summary
CREATE OR REPLACE FUNCTION professional_register_summary(p_company_id UUID)
RETURNS TABLE (total BIGINT, valid_count BIGINT, expired_count BIGINT, pending_count BIGINT, revoked_count BIGINT, marine_count BIGINT, industry_count BIGINT, expiring_soon BIGINT, compliance_rate NUMERIC)
LANGUAGE SQL STABLE AS $$
    SELECT COUNT(*),
        COUNT(*) FILTER (WHERE certificate_status = 'valid'),
        COUNT(*) FILTER (WHERE certificate_status = 'expired'),
        COUNT(*) FILTER (WHERE certificate_status = 'pending'),
        COUNT(*) FILTER (WHERE certificate_status = 'revoked'),
        COUNT(*) FILTER (WHERE working_sector = 'marine_section'),
        COUNT(*) FILTER (WHERE working_sector = 'industry_section'),
        COUNT(*) FILTER (WHERE expiry_date <= CURRENT_DATE + INTERVAL '30 days' AND expiry_date > CURRENT_DATE AND certificate_status = 'valid'),
        CASE WHEN COUNT(*) > 0 THEN ROUND((COUNT(*) FILTER (WHERE certificate_status = 'valid')::NUMERIC/COUNT(*)::NUMERIC)*100,2) ELSE 0 END
    FROM ndt_professional_register WHERE ndt_company_id = p_company_id AND deleted_at IS NULL;
$$;

RAISE NOTICE 'STEP 7 DONE: 6 RPC functions created';


-- ═══════════════════════════════════════════════════════════════
-- STEP 8: VERIFICATION
-- ═══════════════════════════════════════════════════════════════
SELECT 'Tables:' as check, count(*)::text as result FROM information_schema.tables WHERE table_schema='public';
SELECT 'Indexes:' as check, count(*)::text as result FROM pg_indexes WHERE schemaname='public';
SELECT 'Triggers:' as check, count(*)::text as result FROM information_schema.triggers WHERE event_object_schema='public';
SELECT 'RPC Functions:' as check, count(*)::text as result FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f';

RAISE NOTICE '========================================';
RAISE NOTICE 'CLEAN SLATE SCHEMA — COMPLETE';
RAISE NOTICE '========================================';

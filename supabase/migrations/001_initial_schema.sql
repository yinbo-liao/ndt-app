-- =============================================================================
-- NDT Management App — Initial Database Schema
-- Supabase Migration 001
-- =============================================================================

-- 1. CUSTOM ENUM TYPE
-- ---------------------------------------------------------------------------
CREATE TYPE shift_type AS ENUM ('day', 'night');
CREATE TYPE ndt_status AS ENUM ('active', 'inactive', 'pending');
CREATE TYPE user_role AS ENUM ('admin', 'ndt_company', 'ndt_team','QA');
CREATE TYPE type_of_ndt AS ENUM ('UT', 'MT', 'PT', 'RT', 'ET');
CREATE TYPE validation_status AS ENUM ('valid', 'expired', 'pending', 'revoked');
CREATE TYPE testing_status AS ENUM ('planned', 'in_progress', 'completed', 'rejected', 'on_hold', 'not_started');
CREATE TYPE priority_level AS ENUM ('low', 'normal', 'high', 'urgent');
CREATE TYPE assigned_role AS ENUM ('supervisor', 'technician', 'inspector', 'helper');
CREATE TYPE assignment_status AS ENUM ('active', 'completed','on_hold', 'removed');
-- 2. CORE TABLES
-- =============================================================================

-- 2.1 ndt_companies
CREATE TABLE ndt_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    registration_no TEXT UNIQUE,
    contact_email TEXT,
    contact_phone TEXT,
    type_of_ndt_services TEXT[],
    type_of_certificates TEXT[],
    certification_bodies TEXT[],
    cetification_issued_date DATE,
    certification_expire_date DATE,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_ndt_companies_active ON ndt_companies(active);


-- 2.2 users (profile extension for auth.users)
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'ndt_company', 'ndt_team')),
    ndt_company_id UUID REFERENCES ndt_companies(id),
    phone TEXT,
    employee_id TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_company ON users(ndt_company_id);
CREATE INDEX idx_users_active ON users(active);


-- 2.3 ndt_contractor_register
CREATE TABLE ndt_contractor_register (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id),
    technician_name TEXT NOT NULL,
    technician_id_last4digit TEXT NOT NULL,
    type_of_ndt TEXT NOT NULL,
    type_of_ndt_certificate TEXT NOT NULL,
    certificate_no TEXT NOT NULL,
    certificate_party TEXT,
    issue_date DATE NOT NULL,
    expire_date DATE NOT NULL,
    validation_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (validation_status IN ('valid', 'expired', 'pending', 'revoked')),
    report_month DATE NOT NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    deleted_at TIMESTAMPTZ DEFAULT NULL
);
CREATE INDEX idx_contractor_company ON ndt_contractor_register(ndt_company_id);
CREATE INDEX idx_contractor_status ON ndt_contractor_register(validation_status);
CREATE INDEX idx_contractor_month ON ndt_contractor_register(report_month);
CREATE INDEX idx_contractor_expire ON ndt_contractor_register(expire_date);
CREATE INDEX idx_contractor_deleted ON ndt_contractor_register(deleted_at)
    WHERE deleted_at IS NULL;


-- 2.4 projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_name TEXT NOT NULL,
    project_code TEXT UNIQUE NOT NULL,
    job_trade TEXT,
    location TEXT NOT NULL,
    client_name TEXT,
    start_date DATE,
    end_date DATE,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_projects_code ON projects(project_code);
CREATE INDEX idx_projects_active ON projects(active);


-- 2.5 project_ndt_planning
CREATE TABLE project_ndt_planning (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id),
    ndt_rfi_date DATE,
    ndt_company_task TEXT NOT NULL,
    planned_start_date DATE,
    planned_end_date DATE,
    testing_status TEXT NOT NULL DEFAULT 'planned'
        CHECK (testing_status IN ('planned', 'in_progress', 'completed', 'rejected', 'on_hold')),
    test_length NUMERIC(10,2) DEFAULT 0,
    reject_length NUMERIC(10,2) DEFAULT 0,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_planning_project ON project_ndt_planning(project_id);
CREATE INDEX idx_planning_company ON project_ndt_planning(ndt_company_id);
CREATE INDEX idx_planning_status ON project_ndt_planning(testing_status);
CREATE INDEX idx_planning_dates ON project_ndt_planning(planned_start_date, planned_end_date);


-- 2.6 ndt_team_deployments (with shift support)
CREATE TABLE ndt_team_deployments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_ndt_planning_id UUID NOT NULL REFERENCES project_ndt_planning(id),
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id),
    ndt_supervisor_id UUID REFERENCES users(id),

    -- SHIFT MANAGEMENT
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

    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    deleted_at TIMESTAMPTZ DEFAULT NULL
);
CREATE INDEX idx_deployments_planning ON ndt_team_deployments(project_ndt_planning_id);
CREATE INDEX idx_deployments_company ON ndt_team_deployments(ndt_company_id);
CREATE INDEX idx_deployments_shift ON ndt_team_deployments(shift);
CREATE INDEX idx_deployments_date ON ndt_team_deployments(deployment_date);
CREATE INDEX idx_deployments_status ON ndt_team_deployments(testing_status);
CREATE INDEX idx_deployments_supervisor ON ndt_team_deployments(ndt_supervisor_id);
CREATE INDEX idx_deployments_deleted ON ndt_team_deployments(deleted_at)
    WHERE deleted_at IS NULL;


-- 2.7 ndt_team_assignments
CREATE TABLE ndt_team_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id),
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
CREATE INDEX idx_assignments_user ON ndt_team_assignments(user_id);
CREATE INDEX idx_assignments_project ON ndt_team_assignments(project_id);
CREATE INDEX idx_assignments_company ON ndt_team_assignments(ndt_company_id);
CREATE INDEX idx_assignments_status ON ndt_team_assignments(status);


-- 2.8 audit_logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMPTZ DEFAULT now(),
    ip_address INET
);
CREATE INDEX idx_audit_table ON audit_logs(table_name);
CREATE INDEX idx_audit_record ON audit_logs(record_id);
CREATE INDEX idx_audit_changed_at ON audit_logs(changed_at);


-- 3. ROW-LEVEL SECURITY (RLS)
-- =============================================================================

-- 3.1 Enable RLS on all tables
ALTER TABLE ndt_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE ndt_contractor_register ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_ndt_planning ENABLE ROW LEVEL SECURITY;
ALTER TABLE ndt_team_deployments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ndt_team_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- 3.2 Helper function: get user's company ID from JWT
CREATE OR REPLACE FUNCTION get_user_company_id()
RETURNS UUID AS $$
BEGIN
    RETURN (auth.jwt()->>'ndt_company_id')::UUID;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 3.3 Admin policies (full access to all tables)
CREATE POLICY "admin_all_ndt_companies"
ON ndt_companies FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

CREATE POLICY "admin_all_users"
ON users FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

CREATE POLICY "admin_all_contractor_register"
ON ndt_contractor_register FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

CREATE POLICY "admin_all_projects"
ON projects FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

CREATE POLICY "admin_all_planning"
ON project_ndt_planning FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

CREATE POLICY "admin_all_deployments"
ON ndt_team_deployments FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

CREATE POLICY "admin_all_assignments"
ON ndt_team_assignments FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

CREATE POLICY "admin_all_audit"
ON audit_logs FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');


-- 3.4 NDT Company policies (own data only)
CREATE POLICY "company_read_projects"
ON projects FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_company');

CREATE POLICY "company_own_contractor_register"
ON ndt_contractor_register FOR ALL
USING (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
    AND deleted_at IS NULL
)
WITH CHECK (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
);

CREATE POLICY "company_own_planning"
ON project_ndt_planning FOR ALL
USING (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
)
WITH CHECK (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
);

CREATE POLICY "company_own_deployments"
ON ndt_team_deployments FOR ALL
USING (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
    AND deleted_at IS NULL
)
WITH CHECK (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
);

CREATE POLICY "company_own_assignments"
ON ndt_team_assignments FOR ALL
USING (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
)
WITH CHECK (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
);

CREATE POLICY "company_view_own_profile"
ON ndt_companies FOR SELECT
USING (
    auth.jwt()->>'role' = 'ndt_company'
    AND id = get_user_company_id()
);

CREATE POLICY "company_view_own_users"
ON users FOR SELECT
USING (
    auth.jwt()->>'role' = 'ndt_company'
    AND ndt_company_id = get_user_company_id()
);


-- 3.5 NDT Team policies (assigned projects only)
CREATE POLICY "team_view_assigned_projects"
ON projects FOR SELECT
USING (
    auth.jwt()->>'role' = 'ndt_team'
    AND EXISTS (
        SELECT 1 FROM ndt_team_assignments a
        WHERE a.user_id = auth.uid()
        AND a.project_id = projects.id
        AND a.status = 'active'
    )
);

CREATE POLICY "team_view_assigned_planning"
ON project_ndt_planning FOR SELECT
USING (
    auth.jwt()->>'role' = 'ndt_team'
    AND EXISTS (
        SELECT 1 FROM ndt_team_assignments a
        WHERE a.user_id = auth.uid()
        AND a.project_id = project_ndt_planning.project_id
        AND a.status = 'active'
    )
);

CREATE POLICY "team_view_own_deployments"
ON ndt_team_deployments FOR SELECT
USING (
    auth.jwt()->>'role' = 'ndt_team'
    AND (
        ndt_supervisor_id = auth.uid()
        OR team_members @> jsonb_build_array(jsonb_build_object('user_id', auth.uid()::text))
        OR EXISTS (
            SELECT 1 FROM ndt_team_assignments a
            JOIN project_ndt_planning p ON p.project_id = a.project_id
            WHERE a.user_id = auth.uid()
            AND a.status = 'active'
            AND p.id = ndt_team_deployments.project_ndt_planning_id
        )
    )
);

CREATE POLICY "team_update_own_deployments"
ON ndt_team_deployments FOR UPDATE
USING (
    auth.jwt()->>'role' = 'ndt_team'
    AND (
        ndt_supervisor_id = auth.uid()
        OR team_members @> jsonb_build_array(jsonb_build_object('user_id', auth.uid()::text))
    )
)
WITH CHECK (auth.jwt()->>'role' = 'ndt_team');

CREATE POLICY "team_view_own_profile"
ON users FOR SELECT
USING (auth.jwt()->>'role' = 'ndt_team' AND id = auth.uid());


-- 4. TRIGGERS
-- =============================================================================

-- 4.1 Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_contractor_register_updated_at
    BEFORE UPDATE ON ndt_contractor_register
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_planning_updated_at
    BEFORE UPDATE ON project_ndt_planning
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deployments_updated_at
    BEFORE UPDATE ON ndt_team_deployments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assignments_updated_at
    BEFORE UPDATE ON ndt_team_assignments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- 4.2 Audit log trigger
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_contractor_register
    AFTER INSERT OR UPDATE OR DELETE ON ndt_contractor_register
    FOR EACH ROW EXECUTE FUNCTION audit_trigger();

CREATE TRIGGER audit_deployments
    AFTER INSERT OR UPDATE OR DELETE ON ndt_team_deployments
    FOR EACH ROW EXECUTE FUNCTION audit_trigger();


-- 4.3 Certificate expiry notification trigger
CREATE OR REPLACE FUNCTION check_certificate_expiry()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.expire_date <= CURRENT_DATE + INTERVAL '30 days'
       AND NEW.validation_status = 'valid' THEN
        PERFORM pg_notify('certificate_expiry', json_build_object(
            'certificate_id', NEW.id,
            'company_id', NEW.ndt_company_id,
            'certificate_no', NEW.certificate_no,
            'expire_date', NEW.expire_date
        )::text);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_certificate_expiry
    AFTER INSERT OR UPDATE ON ndt_contractor_register
    FOR EACH ROW EXECUTE FUNCTION check_certificate_expiry();


-- 5. SUMMARY & CHART FUNCTIONS
-- =============================================================================

-- 5.1 Daily Deployment Summary per Project
CREATE OR REPLACE FUNCTION daily_deployment_summary_by_project(
    p_project_id UUID,
    p_date DATE
)
RETURNS TABLE (
    project_id UUID,
    project_name TEXT,
    deployment_date DATE,
    day_shift_count BIGINT,
    night_shift_count BIGINT,
    total_teams BIGINT,
    total_personnel BIGINT,
    completed_tests BIGINT,
    in_progress_tests BIGINT,
    rejected_tests BIGINT,
    total_test_length NUMERIC,
    total_reject_length NUMERIC,
    locations TEXT[]
)
LANGUAGE SQL
STABLE
AS $$
    SELECT
        p.id AS project_id,
        p.project_name,
        p_date AS deployment_date,
        COUNT(*) FILTER (WHERE d.shift = 'day') AS day_shift_count,
        COUNT(*) FILTER (WHERE d.shift = 'night') AS night_shift_count,
        COUNT(DISTINCT d.team_deployment) AS total_teams,
        COALESCE(SUM(jsonb_array_length(d.team_members)), 0) AS total_personnel,
        COUNT(*) FILTER (WHERE d.testing_status = 'completed') AS completed_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'in_progress') AS in_progress_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'rejected') AS rejected_tests,
        COALESCE(SUM(d.test_length), 0) AS total_test_length,
        COALESCE(SUM(d.reject_length), 0) AS total_reject_length,
        ARRAY_AGG(DISTINCT d.job_location) AS locations
    FROM projects p
    JOIN project_ndt_planning plan ON plan.project_id = p.id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id
        AND d.deployment_date = p_date
        AND d.deleted_at IS NULL
    WHERE p.id = p_project_id
    GROUP BY p.id, p.project_name;
$$;


-- 5.2 Daily Deployment Summary per NDT Company
CREATE OR REPLACE FUNCTION daily_deployment_summary_by_company(
    p_company_id UUID,
    p_date DATE
)
RETURNS TABLE (
    company_id UUID,
    company_name TEXT,
    deployment_date DATE,
    total_projects BIGINT,
    day_shift_count BIGINT,
    night_shift_count BIGINT,
    total_teams BIGINT,
    total_personnel BIGINT,
    completed_tests BIGINT,
    in_progress_tests BIGINT,
    rejected_tests BIGINT,
    not_started_tests BIGINT,
    total_test_length NUMERIC,
    total_reject_length NUMERIC,
    avg_reject_rate NUMERIC
)
LANGUAGE SQL
STABLE
AS $$
    SELECT
        c.id AS company_id,
        c.name AS company_name,
        p_date AS deployment_date,
        COUNT(DISTINCT plan.project_id) AS total_projects,
        COUNT(*) FILTER (WHERE d.shift = 'day') AS day_shift_count,
        COUNT(*) FILTER (WHERE d.shift = 'night') AS night_shift_count,
        COUNT(DISTINCT d.team_deployment) AS total_teams,
        COALESCE(SUM(jsonb_array_length(d.team_members)), 0) AS total_personnel,
        COUNT(*) FILTER (WHERE d.testing_status = 'completed') AS completed_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'in_progress') AS in_progress_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'rejected') AS rejected_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'not_started') AS not_started_tests,
        COALESCE(SUM(d.test_length), 0) AS total_test_length,
        COALESCE(SUM(d.reject_length), 0) AS total_reject_length,
        CASE
            WHEN SUM(d.test_length) > 0
            THEN ROUND((SUM(d.reject_length) / SUM(d.test_length)) * 100, 2)
            ELSE 0
        END AS avg_reject_rate
    FROM ndt_companies c
    LEFT JOIN project_ndt_planning plan ON plan.ndt_company_id = c.id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id
        AND d.deployment_date = p_date
        AND d.deleted_at IS NULL
    WHERE c.id = p_company_id
    GROUP BY c.id, c.name;
$$;


-- 5.3 Weekly Deployment Trend per Project
CREATE OR REPLACE FUNCTION weekly_deployment_trend(
    p_project_id UUID,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    trend_date DATE,
    day_shift_count BIGINT,
    night_shift_count BIGINT,
    completed_tests BIGINT,
    total_test_length NUMERIC,
    total_reject_length NUMERIC
)
LANGUAGE SQL
STABLE
AS $$
    SELECT
        gs::DATE AS trend_date,
        COUNT(*) FILTER (WHERE d.shift = 'day') AS day_shift_count,
        COUNT(*) FILTER (WHERE d.shift = 'night') AS night_shift_count,
        COUNT(*) FILTER (WHERE d.testing_status = 'completed') AS completed_tests,
        COALESCE(SUM(d.test_length), 0) AS total_test_length,
        COALESCE(SUM(d.reject_length), 0) AS total_reject_length
    FROM generate_series(p_start_date, p_end_date, '1 day'::INTERVAL) gs
    LEFT JOIN project_ndt_planning plan ON plan.project_id = p_project_id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id
        AND d.deployment_date = gs::DATE
        AND d.deleted_at IS NULL
    GROUP BY gs::DATE
    ORDER BY gs::DATE;
$$;


-- 5.4 Contractor Register Summary
CREATE OR REPLACE FUNCTION contractor_register_summary(
    p_company_id UUID,
    p_month_start DATE
)
RETURNS TABLE (
    total BIGINT,
    valid_count BIGINT,
    expired_count BIGINT,
    pending_count BIGINT,
    revoked_count BIGINT,
    expiring_soon BIGINT,
    compliance_rate NUMERIC
)
LANGUAGE SQL
STABLE
AS $$
    SELECT
        COUNT(*) AS total,
        COUNT(*) FILTER (WHERE validation_status = 'valid') AS valid_count,
        COUNT(*) FILTER (WHERE validation_status = 'expired') AS expired_count,
        COUNT(*) FILTER (WHERE validation_status = 'pending') AS pending_count,
        COUNT(*) FILTER (WHERE validation_status = 'revoked') AS revoked_count,
        COUNT(*) FILTER (WHERE expire_date <= p_month_start + INTERVAL '30 days'
                         AND expire_date > p_month_start
                         AND validation_status = 'valid') AS expiring_soon,
        CASE
            WHEN COUNT(*) > 0
            THEN ROUND((COUNT(*) FILTER (WHERE validation_status = 'valid')::NUMERIC / COUNT(*)::NUMERIC) * 100, 2)
            ELSE 0
        END AS compliance_rate
    FROM ndt_contractor_register
    WHERE ndt_company_id = p_company_id
    AND report_month = p_month_start
    AND deleted_at IS NULL;
$$;


-- 5.5 Project NDT Status Summary
CREATE OR REPLACE FUNCTION project_ndt_status_summary(
    p_company_id UUID
)
RETURNS TABLE (
    project_id UUID,
    project_name TEXT,
    project_code TEXT,
    total_planned BIGINT,
    total_deployments BIGINT,
    completed_tests BIGINT,
    rejected_tests BIGINT,
    in_progress_tests BIGINT,
    not_started_tests BIGINT,
    completion_rate NUMERIC,
    reject_rate NUMERIC,
    total_test_length NUMERIC,
    total_reject_length NUMERIC
)
LANGUAGE SQL
STABLE
AS $$
    SELECT
        p.id AS project_id,
        p.project_name,
        p.project_code,
        COUNT(DISTINCT plan.id) AS total_planned,
        COUNT(DISTINCT d.id) AS total_deployments,
        COUNT(*) FILTER (WHERE d.testing_status = 'completed') AS completed_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'rejected') AS rejected_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'in_progress') AS in_progress_tests,
        COUNT(*) FILTER (WHERE d.testing_status = 'not_started') AS not_started_tests,
        CASE
            WHEN COUNT(DISTINCT d.id) > 0
            THEN ROUND((COUNT(*) FILTER (WHERE d.testing_status = 'completed')::NUMERIC / COUNT(DISTINCT d.id)::NUMERIC) * 100, 2)
            ELSE 0
        END AS completion_rate,
        CASE
            WHEN COALESCE(SUM(d.test_length), 0) > 0
            THEN ROUND((COALESCE(SUM(d.reject_length), 0) / SUM(d.test_length)) * 100, 2)
            ELSE 0
        END AS reject_rate,
        COALESCE(SUM(d.test_length), 0) AS total_test_length,
        COALESCE(SUM(d.reject_length), 0) AS total_reject_length
    FROM projects p
    JOIN project_ndt_planning plan ON plan.project_id = p.id
    LEFT JOIN ndt_team_deployments d ON d.project_ndt_planning_id = plan.id
        AND d.deleted_at IS NULL
    WHERE plan.ndt_company_id = p_company_id
    GROUP BY p.id, p.project_name, p.project_code;
$$;


-- 6. HANDLE NEW USER (AUTO-CREATE PROFILE)
-- =============================================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, email, role, ndt_company_id)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'ndt_team'),
        (NEW.raw_user_meta_data->>'ndt_company_id')::UUID
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users to auto-create profile
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

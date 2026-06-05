-- =============================================================================
-- Complete schema fix — adds missing columns + creates remaining 8 tables
-- Run this in Supabase SQL Editor
-- =============================================================================

-- ═══ 1. Fix ndt_companies (minimal → full) ═══
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS registration_no TEXT UNIQUE;
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS contact_email TEXT;
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS contact_phone TEXT;
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS supervisor TEXT;
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE ndt_companies ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- ═══ 2. Fix users (minimal → full) ═══
ALTER TABLE users ADD COLUMN IF NOT EXISTS ndt_company_id UUID REFERENCES ndt_companies(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS employee_id TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- ═══ 3. Fix projects (minimal → full) ═══
ALTER TABLE projects ADD COLUMN IF NOT EXISTS job_trade TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS client_name TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS classification TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS qa_incharge_id UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS ndt_company_id UUID REFERENCES ndt_companies(id) ON DELETE SET NULL;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS end_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE projects ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- ═══ 4. Create remaining 8 tables ═══

CREATE TABLE IF NOT EXISTS ndt_contractor_register (
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

CREATE TABLE IF NOT EXISTS project_ndt_planning (
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
    priority TEXT DEFAULT 'normal',
    rfi_sent_to_team BOOLEAN DEFAULT false,
    type_of_testing TEXT,
    discipline TEXT,
    job_description TEXT,
    site_contact TEXT,
    subcontractor TEXT,
    job_location TEXT,
    team_deploy_status TEXT NOT NULL DEFAULT 'not_deployed',
    accept_status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

DO $$ BEGIN CREATE TYPE shift_type AS ENUM ('day', 'night'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS ndt_team_deployments (
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
    testing_status TEXT NOT NULL DEFAULT 'not_started',
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

CREATE TABLE IF NOT EXISTS ndt_team_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    ndt_company_id UUID NOT NULL REFERENCES ndt_companies(id) ON DELETE CASCADE,
    assigned_role TEXT NOT NULL DEFAULT 'technician',
    status TEXT NOT NULL DEFAULT 'active',
    assigned_from DATE,
    assigned_to DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, project_id, assigned_role)
);

CREATE TABLE IF NOT EXISTS audit_logs (
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

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT,
    type TEXT,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ndt_professional_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    planning_id UUID NOT NULL REFERENCES project_ndt_planning(id) ON DELETE CASCADE,
    professional_id UUID NOT NULL REFERENCES ndt_professional_register(id) ON DELETE CASCADE,
    assigned_role TEXT NOT NULL DEFAULT 'technician',
    status TEXT NOT NULL DEFAULT 'assigned',
    assigned_at TIMESTAMPTZ DEFAULT now(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(planning_id, professional_id)
);

-- ═══ 5. RPC Functions ═══

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

-- ═══ 6. Verify ═══
SELECT 'Total tables:' as check, count(*)::text as result FROM information_schema.tables WHERE table_schema='public';

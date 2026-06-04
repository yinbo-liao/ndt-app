-- =============================================================================
-- NDT Management App — RFI & Professional Register Enhancements (Migration 003)
-- Adds: ndt_professional_register table, missing columns to existing tables,
--        new RLS policies, triggers, and indexes.
-- =============================================================================

-- 1. NEW TABLE: ndt_professional_register
-- Tracks individual NDT professionals and their certifications per contractor.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ndt_professional_register (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type_of_certificate TEXT NOT NULL,           -- UT, MT, PT, RT, VT, etc.
    certified_by TEXT,                           -- certifying body
    issued_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    certificate_status TEXT NOT NULL DEFAULT 'valid'
        CHECK (certificate_status IN ('valid', 'expired', 'pending', 'revoked')),
    working_sector TEXT NOT NULL
        CHECK (working_sector IN ('marine_section', 'industry_section')),
    ndt_company_id UUID REFERENCES ndt_companies(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    deleted_at TIMESTAMPTZ DEFAULT NULL
);

COMMENT ON TABLE ndt_professional_register IS
  'Individual NDT professionals linked to a contractor company. Tracks certifications, expiry, and working sector.';

-- Indexes for professional_register
CREATE INDEX IF NOT EXISTS idx_professional_company
    ON ndt_professional_register(ndt_company_id);
CREATE INDEX IF NOT EXISTS idx_professional_status
    ON ndt_professional_register(certificate_status);
CREATE INDEX IF NOT EXISTS idx_professional_expire
    ON ndt_professional_register(expiry_date);
CREATE INDEX IF NOT EXISTS idx_professional_sector
    ON ndt_professional_register(working_sector);
CREATE INDEX IF NOT EXISTS idx_professional_deleted
    ON ndt_professional_register(deleted_at)
    WHERE deleted_at IS NULL;


-- 2. ALTER EXISTING TABLES
-- =============================================================================

-- 2.1 ndt_companies — add contractor details
ALTER TABLE ndt_companies
    ADD COLUMN IF NOT EXISTS address TEXT,
    ADD COLUMN IF NOT EXISTS supervisor TEXT;

COMMENT ON COLUMN ndt_companies.address IS
    'Contractor physical address';
COMMENT ON COLUMN ndt_companies.supervisor IS
    'Supervisor name for the NDT contractor company';


-- 2.2 projects — add classification, QA incharge, NDT contractor
ALTER TABLE projects
    ADD COLUMN IF NOT EXISTS classification TEXT,
    ADD COLUMN IF NOT EXISTS qa_incharge_id UUID REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS ndt_company_id UUID REFERENCES ndt_companies(id);

COMMENT ON COLUMN projects.classification IS
    'Project classification (e.g., marine, industrial, offshore)';
COMMENT ON COLUMN projects.qa_incharge_id IS
    'QA person responsible for this project';
COMMENT ON COLUMN projects.ndt_company_id IS
    'Primary NDT contractor assigned to this project';

CREATE INDEX IF NOT EXISTS idx_projects_classification
    ON projects(classification);
CREATE INDEX IF NOT EXISTS idx_projects_qa
    ON projects(qa_incharge_id);
CREATE INDEX IF NOT EXISTS idx_projects_ndt_company
    ON projects(ndt_company_id);


-- 2.3 project_ndt_planning — add RFI register fields
ALTER TABLE project_ndt_planning
    ADD COLUMN IF NOT EXISTS type_of_testing TEXT,
    ADD COLUMN IF NOT EXISTS discipline TEXT
        CHECK (discipline IS NULL OR discipline IN ('structure', 'piping', 'mechanical', 'electrical')),
    ADD COLUMN IF NOT EXISTS job_description TEXT,
    ADD COLUMN IF NOT EXISTS site_contact TEXT,
    ADD COLUMN IF NOT EXISTS subcontractor TEXT,
    ADD COLUMN IF NOT EXISTS job_location TEXT,
    ADD COLUMN IF NOT EXISTS team_deploy_status TEXT NOT NULL DEFAULT 'not_deployed'
        CHECK (team_deploy_status IN ('not_deployed', 'deployed', 'in_progress', 'completed')),
    ADD COLUMN IF NOT EXISTS accept_status TEXT NOT NULL DEFAULT 'pending'
        CHECK (accept_status IN ('accept', 'reject', 'pending'));

COMMENT ON COLUMN project_ndt_planning.type_of_testing IS
    'NDT testing method: UT, MT, PT, RT, VT';
COMMENT ON COLUMN project_ndt_planning.discipline IS
    'Engineering discipline: structure, piping, mechanical, electrical';
COMMENT ON COLUMN project_ndt_planning.job_description IS
    'Detailed description of the NDT job';
COMMENT ON COLUMN project_ndt_planning.site_contact IS
    'Site contact person name/phone';
COMMENT ON COLUMN project_ndt_planning.subcontractor IS
    'Subcontractor name if applicable';
COMMENT ON COLUMN project_ndt_planning.job_location IS
    'Physical job location for this RFI';
COMMENT ON COLUMN project_ndt_planning.team_deploy_status IS
    'Team deployment status tracked by NDT supervisor: not_deployed → deployed → in_progress → completed';
COMMENT ON COLUMN project_ndt_planning.accept_status IS
    'NDT test result: accept, reject, pending';

CREATE INDEX IF NOT EXISTS idx_planning_discipline
    ON project_ndt_planning(discipline);
CREATE INDEX IF NOT EXISTS idx_planning_deploy_status
    ON project_ndt_planning(team_deploy_status);
CREATE INDEX IF NOT EXISTS idx_planning_accept_status
    ON project_ndt_planning(accept_status);


-- 3. RLS POLICIES FOR NEW TABLE
-- =============================================================================
ALTER TABLE ndt_professional_register ENABLE ROW LEVEL SECURITY;

-- Admin: full access
CREATE POLICY "admin_all_professional_register"
    ON ndt_professional_register FOR ALL
    USING (auth.jwt()->>'role' = 'admin')
    WITH CHECK (auth.jwt()->>'role' = 'admin');

-- Company: own professionals, excluding soft-deleted
CREATE POLICY "company_own_professionals"
    ON ndt_professional_register FOR ALL
    USING (
        auth.jwt()->>'role' = 'ndt_company'
        AND ndt_company_id = get_user_company_id()
        AND deleted_at IS NULL
    )
    WITH CHECK (
        auth.jwt()->>'role' = 'ndt_company'
        AND ndt_company_id = get_user_company_id()
    );

-- Team: view professionals of their company
CREATE POLICY "team_view_company_professionals"
    ON ndt_professional_register FOR SELECT
    USING (
        auth.jwt()->>'role' = 'ndt_team'
        AND ndt_company_id = get_user_company_id()
        AND deleted_at IS NULL
    );


-- 4. TRIGGERS FOR NEW TABLE
-- =============================================================================

-- 4.1 Auto-update updated_at
CREATE TRIGGER update_professional_register_updated_at
    BEFORE UPDATE ON ndt_professional_register
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4.2 Audit log
CREATE TRIGGER audit_professional_register
    AFTER INSERT OR UPDATE OR DELETE ON ndt_professional_register
    FOR EACH ROW EXECUTE FUNCTION audit_trigger();

-- 4.3 Auto-set certificate_status to expired when past expiry_date
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

CREATE TRIGGER trigger_professional_cert_expiry
    BEFORE INSERT OR UPDATE ON ndt_professional_register
    FOR EACH ROW EXECUTE FUNCTION check_professional_cert_expiry();


-- 5. NEW RPC FUNCTION: Professional Register Summary
-- =============================================================================
CREATE OR REPLACE FUNCTION professional_register_summary(
    p_company_id UUID
)
RETURNS TABLE (
    total BIGINT,
    valid_count BIGINT,
    expired_count BIGINT,
    pending_count BIGINT,
    revoked_count BIGINT,
    marine_count BIGINT,
    industry_count BIGINT,
    expiring_soon BIGINT,
    compliance_rate NUMERIC
)
LANGUAGE SQL
STABLE
AS $$
    SELECT
        COUNT(*) AS total,
        COUNT(*) FILTER (WHERE certificate_status = 'valid') AS valid_count,
        COUNT(*) FILTER (WHERE certificate_status = 'expired') AS expired_count,
        COUNT(*) FILTER (WHERE certificate_status = 'pending') AS pending_count,
        COUNT(*) FILTER (WHERE certificate_status = 'revoked') AS revoked_count,
        COUNT(*) FILTER (WHERE working_sector = 'marine_section') AS marine_count,
        COUNT(*) FILTER (WHERE working_sector = 'industry_section') AS industry_count,
        COUNT(*) FILTER (
            WHERE expiry_date <= CURRENT_DATE + INTERVAL '30 days'
            AND expiry_date > CURRENT_DATE
            AND certificate_status = 'valid'
        ) AS expiring_soon,
        CASE
            WHEN COUNT(*) > 0
            THEN ROUND(
                (COUNT(*) FILTER (WHERE certificate_status = 'valid')::NUMERIC
                 / COUNT(*)::NUMERIC) * 100, 2
            )
            ELSE 0
        END AS compliance_rate
    FROM ndt_professional_register
    WHERE ndt_company_id = p_company_id
    AND deleted_at IS NULL;
$$;

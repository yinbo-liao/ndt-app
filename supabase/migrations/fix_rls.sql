-- FIX: RLS policies use auth.jwt()->>'role' but the JWT stores custom
-- claims in app_metadata, not at top level. In Supabase, the top-level
-- 'role' is always 'authenticated' for logged-in users.
--
-- Fix: use auth.jwt()->'app_metadata'->>'role' for role check
--      use auth.jwt()->'app_metadata'->>'ndt_company_id' for company check

-- Drop all old policies
DO $$ DECLARE pol RECORD;
BEGIN
    FOR pol IN SELECT policyname, tablename FROM pg_policies WHERE schemaname='public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- Helper: get user's company ID from JWT app_metadata
CREATE OR REPLACE FUNCTION get_user_company_id()
RETURNS UUID SECURITY DEFINER AS $$
BEGIN
    RETURN (auth.jwt()->'app_metadata'->>'ndt_company_id')::UUID;
END;
$$ LANGUAGE plpgsql;

-- Helper: get user's role from JWT app_metadata
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT SECURITY DEFINER AS $$
BEGIN
    RETURN COALESCE(auth.jwt()->'app_metadata'->>'role', 'ndt_team');
END;
$$ LANGUAGE plpgsql;

-- ADMIN: full access to all tables (checks app_metadata.role)
DO $$ DECLARE t TEXT;
BEGIN
    FOR t IN ARRAY['ndt_companies','users','ndt_contractor_register','projects','project_ndt_planning','ndt_team_deployments','ndt_team_assignments','audit_logs','notifications','ndt_professional_register','ndt_professional_assignments']
    LOOP
        EXECUTE format('CREATE POLICY "admin_all" ON %I FOR ALL USING (get_user_role() = ''admin'') WITH CHECK (get_user_role() = ''admin'')', t);
    END LOOP;
END $$;

-- NDT COMPANY policies
CREATE POLICY "company_read_projects" ON projects FOR SELECT USING (get_user_role() = 'ndt_company');

CREATE POLICY "company_own_contractors" ON ndt_contractor_register FOR ALL
USING (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL)
WITH CHECK (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_planning" ON project_ndt_planning FOR ALL
USING (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id())
WITH CHECK (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_deployments" ON ndt_team_deployments FOR ALL
USING (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL)
WITH CHECK (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_assignments" ON ndt_team_assignments FOR ALL
USING (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id())
WITH CHECK (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_view_profile" ON ndt_companies FOR SELECT
USING (get_user_role() = 'ndt_company' AND id = get_user_company_id());

CREATE POLICY "company_view_users" ON users FOR SELECT
USING (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_professionals" ON ndt_professional_register FOR ALL
USING (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL)
WITH CHECK (get_user_role() = 'ndt_company' AND ndt_company_id = get_user_company_id());

CREATE POLICY "company_own_prof_assign" ON ndt_professional_assignments FOR ALL
USING (get_user_role() = 'ndt_company' AND EXISTS (
    SELECT 1 FROM project_ndt_planning p WHERE p.id = ndt_professional_assignments.planning_id AND p.ndt_company_id = get_user_company_id()))
WITH CHECK (get_user_role() = 'ndt_company' AND EXISTS (
    SELECT 1 FROM project_ndt_planning p WHERE p.id = ndt_professional_assignments.planning_id AND p.ndt_company_id = get_user_company_id()));

-- NDT TEAM policies
CREATE POLICY "team_view_projects" ON projects FOR SELECT
USING (get_user_role() = 'ndt_team' AND EXISTS (
    SELECT 1 FROM ndt_team_assignments a WHERE a.user_id = auth.uid() AND a.project_id = projects.id AND a.status = 'active'));

CREATE POLICY "team_view_planning" ON project_ndt_planning FOR SELECT
USING (get_user_role() = 'ndt_team' AND EXISTS (
    SELECT 1 FROM ndt_team_assignments a WHERE a.user_id = auth.uid() AND a.project_id = project_ndt_planning.project_id AND a.status = 'active'));

CREATE POLICY "team_view_deployments" ON ndt_team_deployments FOR SELECT
USING (get_user_role() = 'ndt_team' AND (
    ndt_supervisor_id = auth.uid()
    OR team_members @> jsonb_build_array(jsonb_build_object('user_id', auth.uid()::text))
    OR EXISTS (SELECT 1 FROM ndt_team_assignments a JOIN project_ndt_planning p ON p.project_id = a.project_id WHERE a.user_id = auth.uid() AND a.status = 'active' AND p.id = ndt_team_deployments.project_ndt_planning_id)));

CREATE POLICY "team_update_deployments" ON ndt_team_deployments FOR UPDATE
USING (get_user_role() = 'ndt_team' AND (ndt_supervisor_id = auth.uid() OR team_members @> jsonb_build_array(jsonb_build_object('user_id', auth.uid()::text))))
WITH CHECK (get_user_role() = 'ndt_team');

CREATE POLICY "team_view_profile" ON users FOR SELECT
USING (get_user_role() = 'ndt_team' AND id = auth.uid());

CREATE POLICY "team_view_company" ON ndt_companies FOR SELECT
USING (get_user_role() = 'ndt_team' AND id = get_user_company_id());

CREATE POLICY "team_view_assignments" ON ndt_team_assignments FOR SELECT
USING (get_user_role() = 'ndt_team' AND user_id = auth.uid());

CREATE POLICY "team_view_professionals" ON ndt_professional_register FOR SELECT
USING (get_user_role() = 'ndt_team' AND ndt_company_id = get_user_company_id() AND deleted_at IS NULL);

CREATE POLICY "team_view_prof_assign" ON ndt_professional_assignments FOR SELECT
USING (get_user_role() = 'ndt_team' AND EXISTS (
    SELECT 1 FROM project_ndt_planning p WHERE p.id = ndt_professional_assignments.planning_id AND p.ndt_company_id = get_user_company_id()));

-- NOTIFICATIONS: user reads own
CREATE POLICY "user_own_notifications" ON notifications FOR SELECT USING (user_id = auth.uid());

SELECT 'RLS policies fixed — now uses app_metadata.role' as result;

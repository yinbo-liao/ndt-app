-- =============================================================================
-- NDT Management App — Audit Trigger Completion (Migration 005)
--
-- Adds audit triggers (AFTER INSERT/UPDATE/DELETE) to 6 tables that were
-- missing them. These tables already have the audit_logs infrastructure
-- and the audit_trigger() function from migration 001.
--
-- Tables receiving audit triggers:
--   1. projects              — track project create/update/delete
--   2. project_ndt_planning  — track RFI lifecycle changes
--   3. users                 — track profile changes (not auth.users)
--   4. ndt_companies         — track company profile changes
--   5. ndt_team_assignments  — track team member assignment changes
--   6. notifications         — track notification lifecycle
--
-- The 4 tables that already have audit triggers from migrations 001/003/004:
--   ndt_contractor_register, ndt_team_deployments,
--   ndt_professional_register, ndt_professional_assignments
-- =============================================================================

-- 1. projects audit trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers
        WHERE event_object_schema = 'public'
        AND event_object_table = 'projects'
        AND trigger_name = 'audit_projects'
    ) THEN
        CREATE TRIGGER audit_projects
            AFTER INSERT OR UPDATE OR DELETE ON projects
            FOR EACH ROW EXECUTE FUNCTION audit_trigger();
    END IF;
END $$;

-- 2. project_ndt_planning audit trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers
        WHERE event_object_schema = 'public'
        AND event_object_table = 'project_ndt_planning'
        AND trigger_name = 'audit_planning'
    ) THEN
        CREATE TRIGGER audit_planning
            AFTER INSERT OR UPDATE OR DELETE ON project_ndt_planning
            FOR EACH ROW EXECUTE FUNCTION audit_trigger();
    END IF;
END $$;

-- 3. users audit trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers
        WHERE event_object_schema = 'public'
        AND event_object_table = 'users'
        AND trigger_name = 'audit_users'
    ) THEN
        CREATE TRIGGER audit_users
            AFTER INSERT OR UPDATE OR DELETE ON users
            FOR EACH ROW EXECUTE FUNCTION audit_trigger();
    END IF;
END $$;

-- 4. ndt_companies audit trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers
        WHERE event_object_schema = 'public'
        AND event_object_table = 'ndt_companies'
        AND trigger_name = 'audit_companies'
    ) THEN
        CREATE TRIGGER audit_companies
            AFTER INSERT OR UPDATE OR DELETE ON ndt_companies
            FOR EACH ROW EXECUTE FUNCTION audit_trigger();
    END IF;
END $$;

-- 5. ndt_team_assignments audit trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers
        WHERE event_object_schema = 'public'
        AND event_object_table = 'ndt_team_assignments'
        AND trigger_name = 'audit_assignments'
    ) THEN
        CREATE TRIGGER audit_assignments
            AFTER INSERT OR UPDATE OR DELETE ON ndt_team_assignments
            FOR EACH ROW EXECUTE FUNCTION audit_trigger();
    END IF;
END $$;

-- 6. notifications audit trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers
        WHERE event_object_schema = 'public'
        AND event_object_table = 'notifications'
        AND trigger_name = 'audit_notifications'
    ) THEN
        CREATE TRIGGER audit_notifications
            AFTER INSERT OR UPDATE OR DELETE ON notifications
            FOR EACH ROW EXECUTE FUNCTION audit_trigger();
    END IF;
END $$;

-- Recreate all 6 RPC functions with SECURITY DEFINER for PostgREST compatibility

-- 1. Daily Deployment Summary by Project
DROP FUNCTION IF EXISTS daily_deployment_summary_by_project CASCADE;
CREATE OR REPLACE FUNCTION daily_deployment_summary_by_project(p_project_id UUID, p_date DATE)
RETURNS TABLE (project_id UUID, project_name TEXT, deployment_date DATE, day_shift_count BIGINT, night_shift_count BIGINT, total_teams BIGINT, total_personnel BIGINT, completed_tests BIGINT, in_progress_tests BIGINT, rejected_tests BIGINT, total_test_length NUMERIC, total_reject_length NUMERIC, locations TEXT[])
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = 'public' AS $$
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

-- 2. Daily Deployment Summary by Company
DROP FUNCTION IF EXISTS daily_deployment_summary_by_company CASCADE;
CREATE OR REPLACE FUNCTION daily_deployment_summary_by_company(p_company_id UUID, p_date DATE)
RETURNS TABLE (company_id UUID, company_name TEXT, deployment_date DATE, total_projects BIGINT, day_shift_count BIGINT, night_shift_count BIGINT, total_teams BIGINT, total_personnel BIGINT, completed_tests BIGINT, in_progress_tests BIGINT, rejected_tests BIGINT, not_started_tests BIGINT, total_test_length NUMERIC, total_reject_length NUMERIC, avg_reject_rate NUMERIC)
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = 'public' AS $$
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

-- 3. Weekly Deployment Trend
DROP FUNCTION IF EXISTS weekly_deployment_trend CASCADE;
CREATE OR REPLACE FUNCTION weekly_deployment_trend(p_project_id UUID, p_start_date DATE, p_end_date DATE)
RETURNS TABLE (trend_date DATE, day_shift_count BIGINT, night_shift_count BIGINT, completed_tests BIGINT, total_test_length NUMERIC, total_reject_length NUMERIC)
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = 'public' AS $$
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

-- 4. Contractor Register Summary
DROP FUNCTION IF EXISTS contractor_register_summary CASCADE;
CREATE OR REPLACE FUNCTION contractor_register_summary(p_company_id UUID, p_month_start DATE)
RETURNS TABLE (total BIGINT, valid_count BIGINT, expired_count BIGINT, pending_count BIGINT, revoked_count BIGINT, expiring_soon BIGINT, compliance_rate NUMERIC)
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = 'public' AS $$
    SELECT COUNT(*),
        COUNT(*) FILTER (WHERE validation_status = 'valid'),
        COUNT(*) FILTER (WHERE validation_status = 'expired'),
        COUNT(*) FILTER (WHERE validation_status = 'pending'),
        COUNT(*) FILTER (WHERE validation_status = 'revoked'),
        COUNT(*) FILTER (WHERE expire_date <= p_month_start + INTERVAL '30 days' AND expire_date > p_month_start AND validation_status = 'valid'),
        CASE WHEN COUNT(*) > 0 THEN ROUND((COUNT(*) FILTER (WHERE validation_status = 'valid')::NUMERIC/COUNT(*)::NUMERIC)*100,2) ELSE 0 END
    FROM ndt_contractor_register WHERE ndt_company_id = p_company_id AND report_month = p_month_start AND deleted_at IS NULL;
$$;

-- 5. Project NDT Status Summary
DROP FUNCTION IF EXISTS project_ndt_status_summary CASCADE;
CREATE OR REPLACE FUNCTION project_ndt_status_summary(p_company_id UUID)
RETURNS TABLE (project_id UUID, project_name TEXT, project_code TEXT, total_planned BIGINT, total_deployments BIGINT, completed_tests BIGINT, rejected_tests BIGINT, in_progress_tests BIGINT, not_started_tests BIGINT, completion_rate NUMERIC, reject_rate NUMERIC, total_test_length NUMERIC, total_reject_length NUMERIC)
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = 'public' AS $$
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

-- 6. Professional Register Summary
DROP FUNCTION IF EXISTS professional_register_summary CASCADE;
CREATE OR REPLACE FUNCTION professional_register_summary(p_company_id UUID)
RETURNS TABLE (total BIGINT, valid_count BIGINT, expired_count BIGINT, pending_count BIGINT, revoked_count BIGINT, marine_count BIGINT, industry_count BIGINT, expiring_soon BIGINT, compliance_rate NUMERIC)
LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = 'public' AS $$
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

SELECT 'All 6 RPC functions recreated with SECURITY DEFINER' as result;

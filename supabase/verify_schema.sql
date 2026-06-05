-- =============================================================================
-- NDT Management App — Schema Verification Script
-- Run against the live Supabase database to confirm all 4 migrations applied.
-- Each check reports independently; failures do not cascade.
-- =============================================================================

DO $$
DECLARE
    v_pass INT := 0;
    v_fail INT := 0;
    v_count INT;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SCHEMA VERIFICATION START';
    RAISE NOTICE '========================================';

    -- ── 1. TABLES ──────────────────────────────────────────────────
    RAISE NOTICE '--- Checking 11 tables exist ---';

    FOR t IN ARRAY[
        'ndt_companies','users','ndt_contractor_register','projects',
        'project_ndt_planning','ndt_team_deployments','ndt_team_assignments',
        'audit_logs','notifications','ndt_professional_register',
        'ndt_professional_assignments'
    ] LOOP
        EXECUTE format(
            'SELECT 1 FROM information_schema.tables WHERE table_schema = ''public'' AND table_name = %L',
            t
        ) INTO v_count;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: Table % exists', t;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: Table % is MISSING', t;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ── 2. CUSTOM TYPE ────────────────────────────────────────────
    RAISE NOTICE '--- Checking shift_type enum ---';
    EXECUTE 'SELECT 1 FROM pg_type WHERE typname = ''shift_type''' INTO v_count;
    IF v_count = 1 THEN
        RAISE NOTICE '  PASS: shift_type enum exists';
        v_pass := v_pass + 1;
    ELSE
        RAISE WARNING '  FAIL: shift_type enum is MISSING';
        v_fail := v_fail + 1;
    END IF;

    -- ── 3. COLUMNS per table ──────────────────────────────────────
    RAISE NOTICE '--- Checking columns ---';

    -- ndt_companies
    FOR c IN ARRAY[
        'id','name','registration_no','contact_email','contact_phone',
        'active','address','supervisor','created_at','updated_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='ndt_companies' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: ndt_companies.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: ndt_companies.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- users
    FOR c IN ARRAY[
        'id','full_name','email','role','ndt_company_id','phone','employee_id',
        'active','created_at','updated_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='users' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: users.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: users.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ndt_contractor_register
    FOR c IN ARRAY[
        'id','ndt_company_id','type_of_ndt','type_of_ndt_certificate',
        'certificate_no','certificate_type','issue_date','expire_date',
        'validation_status','report_month','created_by','created_at',
        'updated_at','deleted_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='ndt_contractor_register' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: ndt_contractor_register.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: ndt_contractor_register.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- projects
    FOR c IN ARRAY[
        'id','project_name','project_code','job_trade','location','client_name',
        'classification','qa_incharge_id','ndt_company_id','start_date','end_date',
        'active','created_at','updated_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='projects' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: projects.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: projects.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- project_ndt_planning
    FOR c IN ARRAY[
        'id','project_id','ndt_company_id','ndt_rfi_date','ndt_company_task',
        'planned_start_date','planned_end_date','testing_status','test_length',
        'reject_length','priority','rfi_sent_to_team','type_of_testing',
        'discipline','job_description','site_contact','subcontractor',
        'job_location','team_deploy_status','accept_status','created_at','updated_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='project_ndt_planning' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: project_ndt_planning.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: project_ndt_planning.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ndt_team_deployments
    FOR c IN ARRAY[
        'id','project_ndt_planning_id','ndt_company_id','ndt_supervisor_id',
        'shift','deployment_date','deployment_start_time','deployment_end_time',
        'team_deployment','team_members','job_location','testing_status',
        'test_length','reject_length','equipment_used','daily_notes',
        'weather_conditions','created_by','created_at','updated_at','deleted_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='ndt_team_deployments' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: ndt_team_deployments.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: ndt_team_deployments.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ndt_team_assignments
    FOR c IN ARRAY[
        'id','user_id','project_id','ndt_company_id','assigned_role',
        'status','assigned_from','assigned_to','created_at','updated_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='ndt_team_assignments' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: ndt_team_assignments.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: ndt_team_assignments.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- audit_logs
    FOR c IN ARRAY[
        'id','table_name','record_id','action','old_data','new_data',
        'changed_by','changed_at','ip_address'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='audit_logs' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: audit_logs.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: audit_logs.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- notifications
    FOR c IN ARRAY[
        'id','user_id','title','body','type','read','created_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='notifications' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: notifications.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: notifications.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ndt_professional_register
    FOR c IN ARRAY[
        'id','name','type_of_certificate','certified_by','issued_date',
        'expiry_date','certificate_status','working_sector','ndt_company_id',
        'created_by','created_at','updated_at','deleted_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='ndt_professional_register' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: ndt_professional_register.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: ndt_professional_register.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ndt_professional_assignments
    FOR c IN ARRAY[
        'id','planning_id','professional_id','assigned_role','status',
        'assigned_at','created_by','created_at','updated_at'
    ] LOOP
        SELECT COUNT(*) INTO v_count FROM information_schema.columns
            WHERE table_schema='public' AND table_name='ndt_professional_assignments' AND column_name=c;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: ndt_professional_assignments.%', c;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: ndt_professional_assignments.% is MISSING', c;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ── 4. RPC FUNCTIONS ──────────────────────────────────────────
    RAISE NOTICE '--- Checking 6 RPC functions ---';

    FOR f IN ARRAY[
        'daily_deployment_summary_by_project',
        'daily_deployment_summary_by_company',
        'weekly_deployment_trend',
        'contractor_register_summary',
        'project_ndt_status_summary',
        'professional_register_summary'
    ] LOOP
        SELECT COUNT(*) INTO v_count
            FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'public' AND p.proname = f;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: RPC % exists', f;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: RPC % is MISSING', f;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ── 5. TRIGGERS ───────────────────────────────────────────────
    RAISE NOTICE '--- Checking triggers ---';

    -- updated_at triggers (9 expected)
    FOR t IN ARRAY[
        'ndt_companies','users','ndt_contractor_register','projects',
        'project_ndt_planning','ndt_team_deployments','ndt_team_assignments',
        'ndt_professional_register','ndt_professional_assignments'
    ] LOOP
        SELECT COUNT(*) INTO v_count
            FROM information_schema.triggers
            WHERE event_object_schema='public'
            AND event_object_table=t
            AND trigger_name LIKE '%updated_at%';
        IF v_count >= 1 THEN
            RAISE NOTICE '  PASS: updated_at trigger on %', t;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: updated_at trigger on % is MISSING', t;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- audit triggers (10 expected after migration 005, including 4 pre-existing + 6 new)
    FOR t IN ARRAY[
        'ndt_contractor_register','ndt_team_deployments',
        'ndt_professional_register','ndt_professional_assignments',
        'projects','project_ndt_planning','users','ndt_companies',
        'ndt_team_assignments','notifications'
    ] LOOP
        SELECT COUNT(*) INTO v_count
            FROM information_schema.triggers
            WHERE event_object_schema='public'
            AND event_object_table=t
            AND trigger_name LIKE '%audit%';
        IF v_count >= 1 THEN
            RAISE NOTICE '  PASS: audit trigger on %', t;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: audit trigger on % is MISSING', t;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ── 6. RLS ────────────────────────────────────────────────────
    RAISE NOTICE '--- Checking RLS is enabled ---';

    FOR t IN ARRAY[
        'ndt_companies','users','ndt_contractor_register','projects',
        'project_ndt_planning','ndt_team_deployments','ndt_team_assignments',
        'audit_logs','notifications','ndt_professional_register',
        'ndt_professional_assignments'
    ] LOOP
        EXECUTE format(
            'SELECT 1 FROM pg_tables WHERE schemaname=''public'' AND tablename=%L AND rowsecurity=true',
            t
        ) INTO v_count;
        IF v_count = 1 THEN
            RAISE NOTICE '  PASS: RLS enabled on %', t;
            v_pass := v_pass + 1;
        ELSE
            RAISE WARNING '  FAIL: RLS NOT enabled on %', t;
            v_fail := v_fail + 1;
        END IF;
    END LOOP;

    -- ── REPORT ────────────────────────────────────────────────────
    RAISE NOTICE '========================================';
    RAISE NOTICE 'VERIFICATION COMPLETE: % checks passed, % checks failed', v_pass, v_fail;
    IF v_fail > 0 THEN
        RAISE WARNING 'SCHEMA HAS % FAILURES — review warnings above', v_fail;
    ELSE
        RAISE NOTICE 'ALL CHECKS PASSED — schema is complete ✓';
    END IF;
    RAISE NOTICE '========================================';
END $$;

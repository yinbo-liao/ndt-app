-- =============================================================================
-- NDT Management App — Seed Data for Development & Testing
-- =============================================================================
-- Run after all migrations (001-005) are applied.
-- Uses fixed UUIDs so test assertions can reference them.
-- =============================================================================

-- ═══════════════════════════════════════════════════════════════
-- 1. NDT COMPANIES (3)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO ndt_companies (id, name, registration_no, contact_email, contact_phone, active, address, supervisor) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'Alpha NDT Services',     'REG-001', 'alpha@ndt.test',   '+65-1111-0001', true,  '123 Tuas Ave 1, Singapore',    'John Tan'),
  ('c1000000-0000-0000-0000-000000000002', 'Beta Inspection Corp',   'REG-002', 'beta@ndt.test',    '+65-1111-0002', true,  '456 Woodlands Rd, Singapore',  'Sarah Lim'),
  ('c1000000-0000-0000-0000-000000000003', 'Gamma Testing Pte Ltd',  'REG-003', 'gamma@ndt.test',   '+65-1111-0003', false, '789 Jurong East, Singapore',   'Mike Wong');

-- ═══════════════════════════════════════════════════════════════
-- 2. USERS (7 — requires existing auth.users rows)
-- ═══════════════════════════════════════════════════════════════
-- NOTE: These users must already exist in auth.users before running this seed.
-- In a local dev setup, create auth.users entries first or use Supabase's
-- dashboard to create users, then run this seed script to create profiles.
-- For a fully automated flow, use supabase/seed.sql in conjunction with
-- supabase db reset which handles auth.users seeding through config.toml.

INSERT INTO users (id, full_name, email, role, ndt_company_id, phone, employee_id, active) VALUES
  ('u1000000-0000-0000-0000-000000000001', 'Admin User',      'admin@ndt.test',     'admin',       NULL,                                      NULL,            'ADM-001', true),
  ('u1000000-0000-0000-0000-000000000002', 'Alice Manager',   'alice@alpha.test',   'ndt_company', 'c1000000-0000-0000-0000-000000000001', '+65-2222-0001', 'ALP-001', true),
  ('u1000000-0000-0000-0000-000000000003', 'Bob Manager',     'bob@beta.test',      'ndt_company', 'c1000000-0000-0000-0000-000000000002', '+65-2222-0002', 'BET-001', true),
  ('u1000000-0000-0000-0000-000000000004', 'Charlie Tech',    'charlie@alpha.test', 'ndt_team',    'c1000000-0000-0000-0000-000000000001', '+65-3333-0001', 'ALP-T01', true),
  ('u1000000-0000-0000-0000-000000000005', 'Diana Inspector', 'diana@alpha.test',   'ndt_team',    'c1000000-0000-0000-0000-000000000001', '+65-3333-0002', 'ALP-T02', true),
  ('u1000000-0000-0000-0000-000000000006', 'Eve Helper',      'eve@beta.test',      'ndt_team',    'c1000000-0000-0000-0000-000000000002', '+65-3333-0003', 'BET-T01', true),
  ('u1000000-0000-0000-0000-000000000007', 'Frank Tech',      'frank@beta.test',    'ndt_team',    'c1000000-0000-0000-0000-000000000002', '+65-3333-0004', 'BET-T02', true);

-- ═══════════════════════════════════════════════════════════════
-- 3. PROJECTS (3)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO projects (id, project_name, project_code, job_trade, location, client_name, classification, qa_incharge_id, ndt_company_id, start_date, end_date, active) VALUES
  ('p1000000-0000-0000-0000-000000000001', 'Tuas Terminal Extension',  'PRJ-TTE-001', 'Civil/Structural', 'Tuas, Singapore',   'Port Authority SG',  'marine',    'u1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', '2026-01-15', '2026-12-31', true),
  ('p1000000-0000-0000-0000-000000000002', 'Woodlands Factory Audit',  'PRJ-WFA-002', 'Mechanical',       'Woodlands, Singapore', 'BuildCorp Ltd',  'industrial', 'u1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002', '2026-03-01', '2026-09-30', true),
  ('p1000000-0000-0000-0000-000000000003', 'Jurong Pipeline Phase 3',  'PRJ-JPP-003', 'Piping',           'Jurong Island, Singapore', 'PetroChem Inc', 'industrial', 'u1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', '2026-02-01', '2027-01-31', true);

-- ═══════════════════════════════════════════════════════════════
-- 4. CONTRACTOR REGISTER (5 certs)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO ndt_contractor_register (id, ndt_company_id, type_of_ndt, type_of_ndt_certificate, certificate_no, certificate_type, issue_date, expire_date, validation_status, report_month, created_by) VALUES
  ('r1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'UT', 'Ultrasonic Testing Level II', 'CERT-UT-001', 'ASNT',  '2025-06-01', '2026-06-01', 'valid',    '2026-01-01', 'u1000000-0000-0000-0000-000000000002'),
  ('r1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000001', 'MT', 'Magnetic Particle Level I',   'CERT-MT-002', 'PCN',   '2025-03-01', '2026-03-01', 'expired',  '2026-01-01', 'u1000000-0000-0000-0000-000000000002'),
  ('r1000000-0000-0000-0000-000000000003', 'c1000000-0000-0000-0000-000000000001', 'RT', 'Radiographic Testing Level III','CERT-RT-003', 'ASNT',  '2025-09-01', '2026-09-01', 'valid',    '2026-01-01', 'u1000000-0000-0000-0000-000000000002'),
  ('r1000000-0000-0000-0000-000000000004', 'c1000000-0000-0000-0000-000000000002', 'PT', 'Penetrant Testing Level II',   'CERT-PT-004', 'ISO 9712','2025-01-01','2025-07-01','expired',  '2026-01-01', 'u1000000-0000-0000-0000-000000000003'),
  ('r1000000-0000-0000-0000-000000000005', 'c1000000-0000-0000-0000-000000000002', 'VT', 'Visual Testing Level I',       'CERT-VT-005', 'ASNT',  '2025-11-01', '2026-11-01', 'pending',  '2026-01-01', 'u1000000-0000-0000-0000-000000000003');

-- ═══════════════════════════════════════════════════════════════
-- 5. PROFESSIONAL REGISTER (6 professionals, 3 per active company)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO ndt_professional_register (id, name, type_of_certificate, certified_by, issued_date, expiry_date, certificate_status, working_sector, ndt_company_id, created_by) VALUES
  ('f1000000-0000-0000-0000-000000000001', 'Raj Kumar',     'UT', 'ASNT',     '2025-06-15', '2026-06-15', 'valid',    'marine_section',  'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000002'),
  ('f1000000-0000-0000-0000-000000000002', 'Mei Ling',      'MT', 'PCN',      '2025-04-01', '2026-04-01', 'valid',    'marine_section',  'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000002'),
  ('f1000000-0000-0000-0000-000000000003', 'Ahmad Firdaus', 'RT', 'ISO 9712', '2025-08-01', '2026-08-01', 'valid',    'industry_section','c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000002'),
  ('f1000000-0000-0000-0000-000000000004', 'John Smith',    'PT', 'ASNT',     '2025-02-15', '2026-02-15', 'expired',  'industry_section','c1000000-0000-0000-0000-000000000002', 'u1000000-0000-0000-0000-000000000003'),
  ('f1000000-0000-0000-0000-000000000005', 'Lisa Chen',     'VT', 'ASNT',     '2025-10-01', '2026-10-01', 'valid',    'industry_section','c1000000-0000-0000-0000-000000000002', 'u1000000-0000-0000-0000-000000000003'),
  ('f1000000-0000-0000-0000-000000000006', 'Tom Baker',     'UT', 'PCN',      '2025-12-01', '2026-12-01', 'pending',  'marine_section',  'c1000000-0000-0000-0000-000000000002', 'u1000000-0000-0000-0000-000000000003');

-- ═══════════════════════════════════════════════════════════════
-- 6. NDT PLANNING / RFI (4 entries)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO project_ndt_planning (id, project_id, ndt_company_id, ndt_rfi_date, ndt_company_task, planned_start_date, planned_end_date, testing_status, priority, type_of_testing, discipline, job_description, site_contact, job_location, team_deploy_status, accept_status, rfi_sent_to_team) VALUES
  ('n1000000-0000-0000-0000-000000000001', 'p1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', '2026-02-01', 'Weld inspection on column beams',       '2026-02-15', '2026-03-15', 'completed',  'high',   'UT', 'structure',   'Inspect all column beam welds at Tuas Terminal', 'Site Eng: Mr. Tan 91234567', 'Tuas Block A',    'completed',    'accept', true),
  ('n1000000-0000-0000-0000-000000000002', 'p1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', '2026-03-01', 'Pipe thickness measurement',             '2026-03-20', '2026-04-20', 'in_progress','high',   'RT', 'piping',      'Measure pipe wall thickness for corrosion',      'QA: Ms. Lim 98765432',   'Tuas Block B',    'deployed',      'pending', true),
  ('n1000000-0000-0000-0000-000000000003', 'p1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000002', '2026-04-01', 'Surface crack detection on machinery',   '2026-04-10', '2026-05-10', 'planned',    'normal', 'MT', 'mechanical',  'Detect surface cracks in factory machinery',      'Site: Mr. Wong 81112233', 'Woodlands Factory', 'not_deployed', 'pending', false),
  ('n1000000-0000-0000-0000-000000000004', 'p1000000-0000-0000-0000-000000000003', 'c1000000-0000-0000-0000-000000000001', '2026-05-01', 'Pipeline girth weld inspection',         '2026-05-15', '2026-06-30', 'in_progress','urgent', 'UT', 'piping',      'Full girth weld inspection for Phase 3 pipeline', 'HSE: Mr. Ali 90001122', 'Jurong Island',   'deployed',      'pending', true);

-- ═══════════════════════════════════════════════════════════════
-- 7. TEAM ASSIGNMENTS (2)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO ndt_team_assignments (id, user_id, project_id, ndt_company_id, assigned_role, status, assigned_from, assigned_to) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000004', 'p1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'technician', 'active',   '2026-02-01', '2026-12-31'),
  ('a1000000-0000-0000-0000-000000000002', 'u1000000-0000-0000-0000-000000000005', 'p1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'inspector',  'active',   '2026-02-01', '2026-12-31');

-- ═══════════════════════════════════════════════════════════════
-- 8. TEAM DEPLOYMENTS (3 — 2 day, 1 night)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO ndt_team_deployments (id, project_ndt_planning_id, ndt_company_id, ndt_supervisor_id, shift, deployment_date, deployment_start_time, deployment_end_time, team_deployment, team_members, job_location, testing_status, test_length, reject_length, equipment_used, daily_notes, weather_conditions, created_by) VALUES
  ('d1000000-0000-0000-0000-000000000001', 'n1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000002', 'day',  '2026-06-05', '2026-06-05 08:00:00+08', '2026-06-05 17:00:00+08', 'Team Alpha',
    '[{"user_id": "u1000000-0000-0000-0000-000000000004", "name": "Charlie Tech", "role": "technician"}, {"user_id": "u1000000-0000-0000-0000-000000000005", "name": "Diana Inspector", "role": "inspector"}]',
    'Tuas Block A', 'in_progress', 120.5, 0, '["UT Probe", "Calibration Block"]', 'Completed 3 of 5 welds today. No issues.', 'Sunny, 32°C', 'u1000000-0000-0000-0000-000000000002'),
  ('d1000000-0000-0000-0000-000000000002', 'n1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000002', 'night','2026-06-05', '2026-06-05 19:00:00+08', '2026-06-06 06:00:00+08', 'Team Beta (Night)',
    '[{"user_id": "u1000000-0000-0000-0000-000000000004", "name": "Charlie Tech", "role": "technician"}]',
    'Tuas Block B', 'completed', 95.0, 2.5, '["UT Probe", "Flood Lights"]', 'Night shift completed remaining 2 welds. One minor rejection.', 'Clear, 28°C', 'u1000000-0000-0000-0000-000000000002'),
  ('d1000000-0000-0000-0000-000000000003', 'n1000000-0000-0000-0000-000000000004', 'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000002', 'day',  '2026-06-05', '2026-06-05 08:30:00+08', '2026-06-05 16:30:00+08', 'Team Gamma',
    '[{"user_id": "u1000000-0000-0000-0000-000000000005", "name": "Diana Inspector", "role": "inspector"}]',
    'Jurong Island', 'not_started', 0, 0, '["RT Source", "Film Processor"]', 'Equipment setup completed. Testing starts tomorrow.', 'Overcast, 30°C', 'u1000000-0000-0000-0000-000000000002');

-- ═══════════════════════════════════════════════════════════════
-- 9. NOTIFICATIONS (4)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO notifications (id, user_id, title, body, type, read) VALUES
  ('t1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000002', 'Certificate Expiring Soon', 'CERT-UT-001 expires on 2026-06-01. Please renew.', 'cert_expiry', false),
  ('t1000000-0000-0000-0000-000000000002', 'u1000000-0000-0000-0000-000000000002', 'RFI Dispatched',           'RFI #n1000000-0000-0000-0000-000000000001 dispatched to Alpha NDT team.', 'rfi_dispatched', true),
  ('t1000000-0000-0000-0000-000000000003', 'u1000000-0000-0000-0000-000000000003', 'Deployment Assigned',      'You have been assigned to Woodlands Factory Audit deployment.', 'deployment_assigned', false),
  ('t1000000-0000-0000-0000-000000000004', 'u1000000-0000-0000-0000-000000000001', 'Approval Needed',           'New contractor certificate CERT-VT-005 requires approval.', 'approval_needed', false);

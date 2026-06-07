UPDATE public.users SET role = 'admin', full_name = 'Raja', employee_id = '10001'
WHERE email = 'raja@ndt-app.com';

UPDATE auth.users SET
  raw_app_meta_data = raw_app_meta_data || '{"role":"admin"}'::jsonb,
  raw_user_meta_data = raw_user_meta_data || '{"role":"admin","full_name":"Raja","job_role":"QA","employee_id":"10001"}'::jsonb
WHERE email = 'raja@ndt-app.com';

SELECT '=== Raja FINAL ===' as info;
SELECT id, full_name, email, role, employee_id, active FROM public.users WHERE email = 'raja@ndt-app.com';
SELECT email, raw_app_meta_data->>'role' as jwt_role FROM auth.users WHERE email = 'raja@ndt-app.com';

-- Fix admin role
UPDATE public.users SET role = 'admin' WHERE email = 'admin@ndt-app.com';

-- Fix JWT claims so the role is in the token
UPDATE auth.users
SET raw_app_meta_data = raw_app_meta_data || '{"role":"admin"}'::jsonb,
    raw_user_meta_data = raw_user_meta_data || '{"role":"admin"}'::jsonb
WHERE email = 'admin@ndt-app.com';

-- Verify
SELECT 'User:' as check, id, full_name, email, role FROM public.users WHERE email = 'admin@ndt-app.com';
SELECT 'JWT claims:' as check, raw_app_meta_data->>'role' as role FROM auth.users WHERE email = 'admin@ndt-app.com';

-- Clean up broken Raja records
DELETE FROM auth.identities WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'raja@ndt-app.com');
DELETE FROM auth.sessions WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'raja@ndt-app.com');
DELETE FROM auth.refresh_tokens WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'raja@ndt-app.com');
DELETE FROM auth.mfa_factors WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'raja@ndt-app.com');
DELETE FROM public.users WHERE email = 'raja@ndt-app.com';
DELETE FROM auth.users WHERE email = 'raja@ndt-app.com';
SELECT 'Cleaned up. Now sign up Raja via the app or API.' as result;

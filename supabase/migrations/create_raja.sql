-- Create Raja by copying the working admin user structure
DO $$
DECLARE
    v_id UUID := gen_random_uuid();
BEGIN
    -- Insert into auth.users (match admin structure exactly)
    INSERT INTO auth.users (
        id, instance_id, email, encrypted_password, email_confirmed_at,
        raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at, aud, role,
        confirmation_token, recovery_token,
        email_change_token_new, email_change_token_current,
        is_sso_user, is_anonymous
    ) VALUES (
        v_id, '00000000-0000-0000-0000-000000000000',
        'raja@ndt-app.com',
        crypt('Admin123!', gen_salt('bf', 10)),
        now(),
        '{"provider":"email","providers":["email"],"role":"admin"}'::jsonb,
        '{"full_name":"Raja","role":"admin","job_role":"QA","employee_id":"10001"}'::jsonb,
        now(), now(), 'authenticated', 'authenticated',
        '', '', '', '',
        false, false
    );

    -- Insert identity
    INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    VALUES (gen_random_uuid(), v_id,
        jsonb_build_object('sub', v_id::text, 'email', 'raja@ndt-app.com', 'email_verified', true, 'phone_verified', false),
        'email', v_id::text, now(), now(), now());

    -- Insert profile (handle_new_user trigger will also fire, so ON CONFLICT)
    INSERT INTO public.users (id, full_name, email, role, employee_id, active)
    VALUES (v_id, 'Raja', 'raja@ndt-app.com', 'admin', '10001', true)
    ON CONFLICT (id) DO UPDATE
    SET role = 'admin', full_name = 'Raja', employee_id = '10001';

    RAISE NOTICE 'Raja created: %', v_id;
END $$;

-- Verify
SELECT 'Profile:' as x, id, full_name, email, role, employee_id FROM public.users WHERE email = 'raja@ndt-app.com';
SELECT 'Auth:' as x, id, email, email_confirmed_at IS NOT NULL as conf, raw_app_meta_data->>'role' as jwt_role FROM auth.users WHERE email = 'raja@ndt-app.com';
SELECT 'Identity:' as x, id, provider FROM auth.identities WHERE user_id = (SELECT id FROM auth.users WHERE email = 'raja@ndt-app.com');

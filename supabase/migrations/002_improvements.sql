-- =============================================================================
-- NDT Management App — Schema Improvements (Migration 002)
-- Based on production workflow requirements
-- =============================================================================

-- 1. RFI DISPATCH TRACKING
-- Add flag to track whether NDT RFI has been sent to the team
-- =============================================================================
ALTER TABLE project_ndt_planning
ADD COLUMN IF NOT EXISTS rfi_sent_to_team BOOLEAN DEFAULT false;

COMMENT ON COLUMN project_ndt_planning.rfi_sent_to_team IS
  'True when the NDT contractor has dispatched the RFI to their team';


-- 2. NOTIFICATIONS TABLE
-- In-app notification support for cert expiry, approvals, and assignments
-- =============================================================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT,
    type TEXT CHECK (type IN (
        'cert_expiry',
        'approval_needed',
        'rfi_dispatched',
        'deployment_assigned'
    )),
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user
    ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read
    ON notifications(user_id, read);


-- 3. AUTO-UPDATE VALIDATION STATUS TRIGGER
-- Automatically sets validation_status to 'expired' when expire_date passes
-- =============================================================================
CREATE OR REPLACE FUNCTION update_cert_validation_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.expire_date < CURRENT_DATE
       AND NEW.validation_status != 'expired'
       AND NEW.validation_status != 'revoked' THEN
        NEW.validation_status := 'expired';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_cert_expiry_on_update
    ON ndt_contractor_register;

CREATE TRIGGER check_cert_expiry_on_update
    BEFORE INSERT OR UPDATE ON ndt_contractor_register
    FOR EACH ROW EXECUTE FUNCTION update_cert_validation_status();


-- 4. RLS FOR NOTIFICATIONS
-- =============================================================================
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own_notifications"
ON notifications FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "admin_all_notifications"
ON notifications FOR ALL
USING (auth.jwt()->>'role' = 'admin')
WITH CHECK (auth.jwt()->>'role' = 'admin');

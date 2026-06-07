-- =============================================================================
-- 008_technician_name
-- Adds technician name field to contractor register.
-- =============================================================================

ALTER TABLE ndt_contractor_register
  ADD COLUMN IF NOT EXISTS technician_name TEXT;

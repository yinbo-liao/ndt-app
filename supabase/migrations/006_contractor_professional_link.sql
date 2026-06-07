-- =============================================================================
-- 006_contractor_professional_link
-- Adds professional reference and short technician ID to contractor register.
-- =============================================================================

-- 1. Add columns
ALTER TABLE ndt_contractor_register
  ADD COLUMN IF NOT EXISTS ndt_professional_id UUID
    REFERENCES ndt_professional_register(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS tech_id CHAR(4);

-- 2. Index for the new FK
CREATE INDEX IF NOT EXISTS idx_contractor_professional
  ON ndt_contractor_register(ndt_professional_id);

-- 3. Index for tech_id lookup
CREATE INDEX IF NOT EXISTS idx_contractor_tech_id
  ON ndt_contractor_register(tech_id);

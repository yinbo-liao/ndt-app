-- =============================================================================
-- 007_structural_rfi_fields
-- Adds standard structural NDT RFI fields to project_ndt_planning.
-- =============================================================================

ALTER TABLE project_ndt_planning
  ADD COLUMN IF NOT EXISTS drawing_ref TEXT,
  ADD COLUMN IF NOT EXISTS iso_line_no TEXT,
  ADD COLUMN IF NOT EXISTS system_name TEXT,
  ADD COLUMN IF NOT EXISTS material_grade TEXT,
  ADD COLUMN IF NOT EXISTS ndt_specification TEXT,
  ADD COLUMN IF NOT EXISTS acceptance_standard TEXT,
  ADD COLUMN IF NOT EXISTS ndt_coverage_pct NUMERIC(5,1),
  ADD COLUMN IF NOT EXISTS surface_condition TEXT,
  ADD COLUMN IF NOT EXISTS joint_details JSONB DEFAULT '[]'::jsonb;

-- joint_details stores an array of joint objects:
-- [{"joint_no":"J1","joint_type":"butt","size":"6\"","ndt_method":"UT","extent":"100%","remarks":"Line A"}]

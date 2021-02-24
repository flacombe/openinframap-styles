DROP VIEW IF EXISTS substation;
DROP MATERIALIZED VIEW IF EXISTS power_substation_relation;

DROP MATERIALIZED VIEW IF EXISTS power_line_warningareas;

DROP VIEW IF EXISTS power_plant;
DROP MATERIALIZED VIEW IF EXISTS power_plant_relation;

/* Projects enedis */
DROP VIEW pdm_boundary;
DROP VIEW pdm_boundary_subdivide;
DROP MATERIALIZED VIEW pdm_project_poteaux;
DROP MATERIALIZED VIEW pdm_project_substations;
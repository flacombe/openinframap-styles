/* OpenInfraMap */
REFRESH MATERIALIZED VIEW power_plant_relation;
REFRESH MATERIALIZED VIEW power_substation_relation;

/* gespot */
UPDATE osm_power_line SET voltage_max=convert_voltage(voltage), geometry_4326=ST_Transform(geometry, 4326);
UPDATE osm_power_line SET tags=(tags::hstore - 'circuits'::text) where tags->'circuits' !~ '^ *[-+]?[0-9]*([.][0-9]+)?[0-9]*(([eE][-+]?)[0-9]+)? *$';
REFRESH MATERIALIZED VIEW power_line_warningareas;

/* Projects enedis */
REFRESH MATERIALIZED VIEW pdm_project_poteaux;

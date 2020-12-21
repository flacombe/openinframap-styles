CREATE MATERIALIZED VIEW power_substation_relation AS
    SELECT rel.osm_id, ST_ConvexHull(ST_Union(mem.geometry)) AS geometry, rel.tags -> 'name' AS name,
        combine_voltage(rel.voltage, voltage_agg(mem.tags -> 'voltage')) AS voltage,
        rel.tags -> 'frequency' AS frequency,
        combine_field(rel.tags -> 'substation', field_agg(mem.tags -> 'substation')) AS substation,
        combine_field(rel.tags -> 'operator', field_agg(mem.tags -> 'operator')) AS operator,
	rel.tags, rel.construction
        FROM osm_power_substation_relation as rel, osm_power_substation_relation_member as mem
        WHERE mem.osm_id = rel.osm_id
        GROUP BY rel.osm_id, rel.tags -> 'name', rel.voltage, rel.tags -> 'frequency',
			rel.tags -> 'substation', rel.tags -> 'operator', rel.tags, rel.construction;

CREATE INDEX power_substation_relation_geom ON power_substation_relation USING GIST (geometry);

ANALYZE power_substation_relation;

CREATE OR REPLACE VIEW substation AS
    SELECT osm_id, geometry, tags -> 'name' AS name, voltage, substation, tags, construction
                  FROM osm_power_substation
    UNION
    SELECT osm_id, geometry, name, voltage, substation, tags, construction
                  FROM power_substation_relation;

CREATE MATERIALIZED VIEW power_plant_relation AS
    SELECT rel.osm_id, ST_ConvexHull(ST_Union(mem.geometry)) AS geometry, 
        (rel.tags -> 'name') AS name, rel.output, rel.source, rel.tags, rel.construction
        FROM osm_power_plant_relation as rel, osm_power_plant_relation_member as mem
        WHERE mem.osm_id = rel.osm_id
        GROUP BY rel.osm_id, rel.tags -> 'name', rel.output, rel.source, rel.tags, rel.construction;

CREATE INDEX power_plant_relation_geom ON power_plant_relation USING GIST (geometry);

ANALYZE power_plant_relation;

ALTER TABLE osm_power_line ADD COLUMN geometry_4326 geometry;
UPDATE osm_power_line SET voltage_max=convert_voltage(voltage), geometry_4326=ST_Transform(geometry, 4326);
CREATE INDEX ON osm_power_line USING gist(geometry_4326);

CREATE MATERIALIZED VIEW power_line_warningareas AS
  SELECT pl.osm_id, pl.voltage, pl.tags->'location' AS location, pl.tags->'tunnel' AS tunnel, pl.type AS type, 'BT' AS voltage_level,
    ST_Transform(ST_Buffer(geometry_4326::geography,0.3*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dma_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,0.3*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvr_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,3*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvs_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,50)::geometry,3857) AS dli_geometry
  FROM osm_power_line pl WHERE geometry_4326 IS NOT NULL AND pl.voltage_max BETWEEN 0 AND 1000
  UNION SELECT pl.osm_id, pl.voltage, pl.tags->'location' AS location, pl.tags->'tunnel' AS tunnel, pl.type AS type, 'HTA' AS voltage_level,
    ST_Transform(ST_Buffer(geometry_4326::geography,2*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dma_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,4*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvr_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,5*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvs_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,50)::geometry,3857) AS dli_geometry
  FROM osm_power_line pl WHERE geometry_4326 IS NOT NULL AND pl.voltage_max BETWEEN 1000 AND 50000
  UNION SELECT pl.osm_id, pl.voltage, pl.tags->'location' AS location, pl.tags->'tunnel' AS tunnel, pl.type AS type, 'HTB' AS voltage_level,
    ST_Transform(ST_Buffer(geometry_4326::geography,(3+floor(pl.voltage_max/100000))*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dma_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,(4+floor(pl.voltage_max/100000))*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvr_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,(6+floor(pl.voltage_max/100000))*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvs_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,50)::geometry,3857) AS dli_geometry
  FROM osm_power_line pl WHERE geometry_4326 IS NOT NULL AND pl.voltage_max BETWEEN 50000 AND 250000
  UNION SELECT pl.osm_id, pl.voltage, pl.tags->'location' AS location, pl.tags->'tunnel' AS tunnel, pl.type AS type, 'HTB' AS voltage_level,
    ST_Transform(ST_Buffer(geometry_4326::geography,(4+floor(pl.voltage_max/100000))*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dma_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,(5+floor(pl.voltage_max/100000))*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvr_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,(6+floor(pl.voltage_max/100000))*Coalesce((pl.tags->'circuits')::numeric,1))::geometry,3857) AS dlvs_geometry,
    ST_Transform(ST_Buffer(geometry_4326::geography,50)::geometry,3857) AS dli_geometry
  FROM osm_power_line pl WHERE geometry_4326 IS NOT NULL AND pl.voltage_max BETWEEN 250000 AND 500000;

CREATE INDEX ON power_line_warningareas USING GIST (dma_geometry);
CREATE INDEX ON power_line_warningareas USING GIST (dlvr_geometry);
CREATE INDEX ON power_line_warningareas USING GIST (dlvs_geometry);
CREATE INDEX ON power_line_warningareas USING GIST (dli_geometry);

ANALYZE power_line_warningareas;

CREATE OR REPLACE VIEW power_plant AS
    SELECT osm_id, geometry, tags -> 'name' AS name, output, source, tags, construction
              FROM osm_power_plant
    UNION
    SELECT osm_id, geometry, name, output, source, tags, construction
              FROM power_plant_relation;

/* Projets enedis */
CREATE MATERIALIZED VIEW pdm_project_poteaux AS SELECT osm_id::text, tags->'name' AS name, hstore_to_json(tags) AS tags, geometry FROM osm_power_tower where tags->'operator'='Enedis';

/* Dispatch power line query to the appropriate generalised table based on zoom. */
CREATE OR REPLACE FUNCTION power_lines(zoom INT, search_geom geometry) RETURNS
	TABLE (gid bigint,
		geometry geometry(LineString, 3857),
		type character varying,
		location character varying,
		line character varying,
		voltage character varying,
		circuits integer,
		frequency character varying,
		construction character varying,
		tunnel boolean,
		voltages INTEGER[],
		tags hstore)
	LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
	IF zoom < 5 THEN
		RETURN QUERY SELECT osm_id, osm_power_line_gen_500.geometry, 
			osm_power_line_gen_500.type, osm_power_line_gen_500.location,
			osm_power_line_gen_500.line, osm_power_line_gen_500.voltage,
			osm_power_line_gen_500.circuits, osm_power_line_gen_500.frequency,
			osm_power_line_gen_500.construction, osm_power_line_gen_500.tunnel,
			line_voltages(osm_power_line_gen_500.voltage, osm_power_line_gen_500.circuits) AS voltages,
			osm_power_line_gen_500.tags
			FROM osm_power_line_gen_500
			WHERE osm_power_line_gen_500.geometry && search_geom;
	ELSIF zoom < 8 THEN
		RETURN QUERY SELECT osm_id, osm_power_line_gen_100.geometry, 
			osm_power_line_gen_100.type, osm_power_line_gen_100.location,
			osm_power_line_gen_100.line, osm_power_line_gen_100.voltage,
			osm_power_line_gen_100.circuits, osm_power_line_gen_100.frequency,
			osm_power_line_gen_100.construction, osm_power_line_gen_100.tunnel,
			line_voltages(osm_power_line_gen_100.voltage, osm_power_line_gen_100.circuits) AS voltages,
			osm_power_line_gen_100.tags
			FROM osm_power_line_gen_100
			WHERE osm_power_line_gen_100.geometry && search_geom;
	ELSE
		RETURN QUERY SELECT osm_id, osm_power_line.geometry, 
			osm_power_line.type, osm_power_line.location, osm_power_line.line,
			osm_power_line.voltage, osm_power_line.circuits, osm_power_line.frequency,
			osm_power_line.construction, osm_power_line.tunnel,
			line_voltages(osm_power_line.voltage, osm_power_line.circuits) AS voltages,
			osm_power_line.tags
			FROM osm_power_line
			WHERE osm_power_line.geometry && search_geom;
	END IF;
END
$$;

# Open Infrastructure Map
This is the main repository for [OpenInfraMap](https://openinframap.org).

## Web frontend

The [web frontend](web) contains the web app, written in TypeScript using Maplibre GL JS, and served as static files.

## Web backend

The [web backend](web-backend) serves the [stats pages](https://openinframap.org/stats), as well as some additional non-JS web endpoints. It's an async python web app built using starlette.

## OSM Import & Mapping

The mapping file controls how the OSM subset is imported with
[imposm3](https://imposm.org/docs/imposm3/latest/). It's generated from the files in [mapping](mapping)
by calling `python3 ./mapping/main.py > ./mapping.json`.

Changes to the mapping require a re-import of the OpenStreetMap database, which takes
a while and is currently done very irregularly.

I will generally not make any changes to the mapping files unless I'm ready to run a re-import, so if you'd like some changes made to those, please raise an issue rather than a PR.

Consider install functions and views defined in [schema directory](schema).

## Tile Server

Map tiles are served with [Tegola](https://tegola.io/). There's a YAML-based language
which generates the Tegola config, from the `tegola.yml` and `layers.yml` files:

`python3 ./tegola/generate_tegola_config.py ./tegola/tegola.yml ./tegola/layers.yml > ./tegola/config.toml`

See more documentation in [tileserver directory](tegola).

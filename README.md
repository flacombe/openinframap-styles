# OIM Backend
Backend to produce tiles with Tegola help
Two docker imgages helps as well: imposm3 and tegola

## Docker

Imposm3 could run as docker container for both importing and updating.  
See dedicated Readme in imposm3 directory.

It expects an up & running postgresql server with a postgis enabled database

Docker images includes all it needs to run services described below.

Create a 10001 GID group that will own every directory mounted in docker for data persistance.
```
groupadd --gid 10001 -r osm_docker
```

## Local run

The mapping file controls how the OSM subset is imported with
[imposm3](https://imposm.org/docs/imposm3/latest/). It's generated from the files in [mapping](mapping)
by calling `python3 ./mapping/main.py > ./mapping.json`.

Imposm3 and Tegola could run as docker containers for importing, updating and rendering.  
See dedicated Readme in imposm3 and tegola directories.

### Services

Docker images includes all it needs to run services described below.

Create a 10001 GID group that will own every directory mounted in docker for data persistance.
```
groupadd --gid 10001 -r osm_docker
```

## Setup
Follow OSM guidelines at https://wiki.openstreetmap.org/wiki/Debian/Stretch/FR:Installation

### Filesystem

Create required directories:
```
mkdir -p /data/files/imposm3
```

### Create osm database

Postgresql can run from the camp2camp postgis image:
```
docker network create -d bridge oim-internal
docker run -d --rm --name pgsqldb --network=oim-internal -p 5432:5432 -e POSTGRES_PASSWORD=pgpassword -v /data/pgdocker:/var/lib/postgresql/data camptocamp/postgres:13-postgis-3
```

Connection with psql is done on host with:
```
docker exec -it 80ed0984a663 psql -d osm -U postgres
```
or
```
psql -h localhost -p 5432 -U postgres -d osm
```

Then, with postgres user:

```sh
createuser osm
psql -U postgres -c "ALTER USER osm WITH PASSWORD '#votremdp#';"

createdb -E UTF8 -O osm
psql -U postgres -c "CREATE EXTENSION postgis;" 
```

In case of heavy structure changes, it is preferable to destroy the existing database and recreate it as to avoid any issue during the importing process

#### SQL functions

As osm user:

```sh
psql -f schema/functions.sql -d osm
```

### Build

Imposm3 docker is built with simple:
```
docker build --build-arg IMPOSM3_VERSION=0.11.0 -f imposm3.Dockerfile -t oim/imposm:latest .
```

Several tegola servers can be built this way, adjust the TEGOLA_CONFIG directory path to change configuration:
```
docker build --build-arg TEGOLA_CONFIG=tegola -f tegola.Dockerfile -t oim/tegola:latest .
```

### Load OSM Data
First of all, choose the file corresponding to the area you want to load https://download.geofabrik.de/

Loading is done with `import` command of imposm3 docker image as follows:
```
docker run -it -v /data/files/imposm3:/data/files/imposm3 --network=oim-internal -e DB_URL=postgres://user:password@pgsqldb:5432/osm -e OSM_FILE=https://download.geofabrik.de/europe/france-latest.osm.pbf oim/imposm3:latest import
```

`import` command directly fallbacks to run state once completed, you won't have to wait to restart the docker.

## Running

Running includes a few tasks that are mostly included in docker images
* Keeping data and views up to date is done by imposm3 docker
* Producing and cleaning up expired tiles log is also done by imposm3 docker
* Consuming expired tiles log is done by tegola docker

### Docker

Tegola instance server could be started with following docker run:
```
docker run -d --rm -v /data/files/imposm3:/data/files/imposm3 --network=oim-internal -p 8083:8081 -e DB_HOST=pgsqldb -e DB_PORT=5432 -e DB_DATABASE=osm -e DB_USER=user -e DB_PWD=password oim/tegola:latest
```

### Continuous OSM data update

With Docker
```
docker run -d --rm -v /data/files/imposm3:/data/files/imposm3 --network=oim-internal -e DB_URL=postgres://user:password@pgsqldb:5432/osm oim/imposm3:latest run
```
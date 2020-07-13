# OIM Backend
Backend to produce tiles with Tegola help
Mapping.yml rules the layers produced in the MVT tiles
OSM data is update with imposm3

## Setup
Follow OSM guidelines at https://wiki.openstreetmap.org/wiki/Debian/Stretch/FR:Installation

### Install dependencies
#### DB

```sh
apt install postgresql postgis
```

#### Golang
Download binaries at https://golang.org/dl/

```sh
tar -C /opt/go -xvf go1.13.4.linux-amd64.tar.gz
export GOROOT=/opt/go
export GOPATH=/opt/imposm3
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
```

#### Imposm3
Download binaries at https://github.com/omniscale/imposm3/releases

```sh
tar -C /opt/imposm3 -xvf imposm-0.8.1-linux-x86-64.tar.gz
```

#### Tegola
```sh
wget https://github.com/go-spatial/tegola/releases/download/v0.10.2/tegola_linux_amd64.zip
unzip tegola_linux_amd64.zip
mkdir -p /home/osm/go/bin
cp tegola /home/osm/go/bin
```

### Setup pgsql: Move datadir to a dedicated volume
```sh
mkdir -p /data/pgsql/11/main
chown postgres:postgres -R /data/pgsql
```

Edit /etc/postgresql/11/main/postgresql.conf and change the data directory
Use initdb to build a proper data directory:

```sh
/usr/lib/postgresql/11/bin/initdb -D /data/pgsql/11/main
```

Rename or delete original datadir to avoid any error: 

```sh
mv /var/lib/postgresql/11/main /var/lib/postgresql/11/main.bak
systemctl restart postgresql
```

Then you should get a running status for postgresql service listening on port 5432

### Create osm database
With postgres user:

```sh
createuser osm
psql -c "ALTER USER osm WITH PASSWORD '#votremdp#';"

createdb -E UTF8 -O osm
psql -c "CREATE EXTENSION hstore;" -d osm
psql -c "CREATE EXTENSION postgis;" -d osm
```

#### Mapbox vt-utils

As osm user:

```sh
psql -f postgis-vt-util.sql -d osm
psql -f functions.sql -d osm
```

### Create services

Several services manage the running state of OIM backend.  
You need to run those commands to install them

```sh
sudo ln -s /opt/oim-styles/imposm3/osm-update.service /etc/systemd/system/osm-update.service
sudo systemctl daemon-reload
sudo systemctl enable osm-update
sudo systemctl start osm-update

sudo ./tegola/install_tegola_service.sh
```

### Import OSM data
Download pbf of your choice at https://download.geofabrik.de/

```sh
sudo mkdir /data/files
sudo chmod osm:osm /data/files
```

And then do the initial import with Imposm3
```
sudo mkdir /data/updates
sudo chown osm:osm /data/updates
sudo chmod 2774 /data/updates
cd /data/updates
/opt/imposm3/imposm3 import -cachedir . -config /opt/oim-styles/imposm3/imposm3.conf -mapping /opt/oim-styles/mapping.yml -deployproduction -read /data/files/france-latest.osm.pbf -write -optimize -overwritecache -diff
cp /data/updates/last.state.txt /data/updates/state.txt
```

Finally populate views of PgSQL database

```sh
psql -d osm -f views.sql
```

A script is here to help :
```sh
./imposm3/reload_db.sh [--load-osm]
```

### Reload database
Basically, database reload consists in :

* Eventually dowload up to date OSM extract from Geofabrik
* Use imposm3 to process OSM extract

A script is here to help :

```sh
./imposm3/reload_db.sh [--load-osm]
```

## Running

### Manage tile server

Tegola could be manually started with following

```sh
/home/osm/go/bin/tegola serve --config /opt/oim-styles/config.toml
```

A service is here to help

```sh
sudo systemctl status tegola
sudo systemctl start tegola
sudo systemctl stop tegola
```

### Continuous OSM data update
Imposm3 is processing minute diffs from main OSM database.  
Continuous updates are managed as a SystemD service : osm-update

```sh
sudo systemctl start osm-update
sudo systemctl status osm-update
sudo systemctl stop osm-update
```
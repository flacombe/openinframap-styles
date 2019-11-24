#!/bin/bash

# Reload database contents according to mapping.yml
# 2019 - Francois Lacombe
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
loadOsm=0;

while [ ! $# -eq 0 ]
do
  	case "$1" in
                --help | -h)
                        echo "Use this syntax: reload_db.sh [--load-osm]"
                        echo "    --load-osm: Enable osm data download from geofabrik"
                        exit
                        ;;
                --load-osm)
                        loadOsm=1
                        ;;
        esac
	shift
done

# Stop continuous import
sudo systemctl stop osm-update.timer

# Mise a jour france-latest
if [ "${loadOsm}" -eq "1" ]; then
  rm -f /data/files/france-latest.osm.pbf
  curl -o /data/files/france-latest.osm.pbf https://download.geofabrik.de/europe/france-latest.osm.pbf
fi

# Nettoyage views
(cd $scriptDir/.. && psql -d osm -f views_clean.sql)

# Import initial
(cd /data/updates && /opt/imposm3/imposm3 import -cachedir . -config /opt/oim-styles/osmosis/imposm3.conf -mapping /opt/oim-styles/mapping.yml -deployproduction -read /data/files/france-latest.osm.pbf -write -optimize -overwritecache -diff)
cp /data/updates/last.state.txt /data/updates/state.txt

# Views
(cd $scriptDir/.. && psql -d osm -f views.sql)

# Relance continuous imports
sudo systemctl start osm-update.timer

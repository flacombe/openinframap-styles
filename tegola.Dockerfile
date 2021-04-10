FROM python:3.6-slim AS builder
ARG TEGOLA_CONFIG=tegola

COPY ./tegola/requirements.txt ./tegola/generate_tegola_config.py ./${TEGOLA_CONFIG}/tegola.yml ./${TEGOLA_CONFIG}/layers.yml ./

RUN apt-get update \
    && apt-get -y --no-install-recommends install ca-certificates gnupg \
    && update-ca-certificates

RUN pip3 install -r requirements.txt \
    && python3 ./generate_tegola_config.py tegola.yml layers.yml > /opt/config.toml

FROM gospatial/tegola:v0.13.0

ENV BOUNDS="-180,-85.0511,180,85.0511" \
    DB_HOST=10.43.18.68 \
    DB_PORT=5432 \
    DB_DATABASE=osm \
    DB_USER=osm \
    DB_PWD=osm

RUN addgroup --gid 10001 osm \
    && adduser --uid 10001 --home /home/osm --disabled-password --ingroup osm osm \
    && mkdir -p /opt/tegola_config \
    && chown -R osm:osm /opt/tegola_config \
    && apk update \
    && apk add bash python3 dcron libcap \
    && chown osm:osm /usr/sbin/crond \
    && setcap cap_setgid=ep /usr/sbin/crond

WORKDIR /opt/tegola_config

COPY ./tegola/docker-entrypoint.sh ./tegola/seed.sh ./tegola/expire.py ./tegola/crontab ./
COPY --from=builder /opt/config.toml ./config.toml

RUN chown -R osm:osm . \
    && chmod 775 -R . \
    && crontab -u osm /opt/tegola_config/crontab \
    && chown osm:osm /etc/crontabs/osm

USER osm

ENTRYPOINT ["./docker-entrypoint.sh"]

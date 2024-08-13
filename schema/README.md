Files in this directory define some utilities around OpenInfraMap DB schema.

The schema is directly created by imposm3 when importing.

## Install

Functions need to be installed prior importing with Imposm3, with the following:

```sh
psql -d postgres://user:password@host:port/database -f ./functions.sql
```

Then run the import

## Create materialised views

Following the import, some views need to be created, based upon the tables created by the imposm3 import.

Use the following:

```sh
psql -d postgres://user:password@host:port/database -f ./views.sql
```

## Refresh materialised views

Materialised views should be periodically refreshed with the help of:

```sh
psql -d postgres://user:password@host:port/database -f refresh_matviews.sql
```

It could be used in a crontab.
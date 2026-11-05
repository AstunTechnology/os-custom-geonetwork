# Docker Geonetwork

Instructions for deploying a customised GeoNetwork install (from a web archive file) including the following supporting software and services:

* ElasticSearch
* Kibana
* Nginx
* PostgreSQL/PostGIS (mandatory but can be RDS)
* OGC-API records service
* Zeppelin (optional)
* Datahub (optional)
* Keycloak (optional)
* Geoserver (optional)

It includes files for building and testing GeoNetwork locally, and also on Docker.

More detailed documentation on the various components can be found in [Confluence](https://astuntech.atlassian.net/wiki/spaces/MET/pages/2831286291/Other+components-+setup+and+usage).

## QUICK START

Install (please don't use the snap version for installing):

* docker
* docker-compose
* ssmtp (only needed on server- for running clamav)

### Prep

* Clone this repository locally and check out the correct branch for the client you are working for.
* Look at the `services\geonetwork\volumes` section of `docker-compose.yml` and ensure that you match the file structure for any volumes that are not inside this repository, e.g. those where the local path starts with `../`. These are generally schema plugins and can be found on [Github](https://github.com/astuntechnology).
* Clone the required repositories to the same level in your file system as `docker-geonetwork` and match the folder names so that you can refer to the mounted files using the location e.g. `../iso19139.gemini23/...`.

Copy `.env.sample` to `.env` and edit the credentials for any services that you are using. For the optional services, ensure that their `docker-compose-XXX.yml` file is included in the colon-delimited `COMPOSE_FILE` variable at the top of the file. 

### Database Prep- Existing PostgreSQL server (i.e. RDS)

* Create an appropriate database on your server and note the credentials. 
* For good measure enable the postgis and hstore extensions.
* Ensure that the followin credentials are correct in `.env`:

```
POSTGRES_DB_NAME=
POSTGRES_DB_HOST=
POSTGRES_DB_PASSWORD=
POSTGRES_DB_USERNAME=
POSTGRES_DB_PORT=
```

### Database Prep- using included Postgres container

* If you are using the included Postgres container set `POSTGRES_DB_HOST` to match the container name `postgres`.

```
POSTGRES_DB_NAME=
POSTGRES_DB_HOST=postgres
POSTGRES_DB_PASSWORD=
POSTGRES_DB_USERNAME=
POSTGRES_DB_PORT=5432
```
* Start just the postgres container so that you can create the database:

```
docker-compose --env-file .env -f docker-compose-postgres.yml up -d
```

* Then edit `.env` to reference the correct `POSTGRES_DB_NAME` and start up all of the containers:

```
docker-compose --env-file .env up -d
```

### Optional services

* Ensure that their section in `.env` is filled in, that their `docker-compose-XXX.yml` file is included in the `COMPOSE_FILE` variable in `.env` and that any mapped volume overrides are correct on the local side.


## Antivirus

SSH onto the server running the containers. Ensure the correct credentials are completed in the SMTP section of `docker-geonetwork/.env`. Note that the email address will be used as both the `FROM` address and the `TO` address, and if you are using Amazon SES then it needs to be a verified email.

Edit `docker-geonetwork/clamav/run-clamav.sh` to scan the correct volume (the default is `/var/lib/docker/volumes`). If your login user is not `astun` then do a find and replace with the correct username to set the folder paths.

**Switch to the root user.**

Ensure the script is executable (`chmod a+x docker-geonetwork/clamav/run-clamav.sh`) and then run it. Test it manually first to pick up issues with things like email credentials and directory access permissions.

The shell-script can be set to run as a scheduled task. There's an example crontab file in the `clamav` folder. The folder path might need editing if the standard user is not `astun`. You can load it using the following syntax (as root):

 crontab clamav.crontab

* For a tame virus file for testing purposes go to <https://www.eicar.org/?page_id=3950>.

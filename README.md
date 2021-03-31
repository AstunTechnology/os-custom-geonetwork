# Docker Geonetwork MASTER TESTING BRANCH

**Use only for testing a locally downloaded war file based on the Geonetwork 4.0.x or master branches**

**This is probably not the branch you want!**

Instructions for deploying a customised GeoNetwork install (from a web archive file) including the following supporting software:

 * ElasticSearch
 * Kibana
 * Zeppelin (optional)
 * Nginx
 * PostgreSQL/PostGIS (mandatory but can be RDS)

It includes files for building and testing GeoNetwork locally, and also files specific to deploying using AWS ECS.

Note: local containers can use `containername` to communicate with each other. ECS containers use `localhost`. ECS also needs/supports different config. That's why we need different versions of everything.


## Installation

### Requirements

* Docker
* Docker-Compose

How to install docker etc on an ubuntu box:

	sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
	wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
	sudo apt update
	sudo apt -y install docker-ce

	sudo systemctl start docker # start docker
	sudo systemctl enable docker # enable it as a service
	sudo usermod -aG docker $(whoami) # add your user to the docker group so commands don't have to be prefixed with sudo

	sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	docker-compose --version # check it's working


### Set Up

Clone https://bitbucket.org/astuntech/docker-geonetwork locally:

	git clone git@bitbucket.org:astuntech/docker-geonetwork.git
	cd docker-geonetwork

Get an app password from bitbucket with **read** access to **repositories** and save it somewhere useful. Copy `bitbucket.sh.sample` to `bitbucket.sh` and fill in your usename and app password. You'll also need this information in a second place if you're going to try to use a custom war file downloaded from bitbucket later.


#### Optional Zeppelin

If you wish to deploy zeppelin (commented out by default) then un-comment the `services\zeppelin` section in your `docker-compose` file and additionally:
	
	cd docker-geonetwork
	git submodule update --init

Modify `./shiro-geonetwork/conf/shiro.ini.geonetworkexample` to match your GeoNetwork postgresql read-only credentials and save it as `./shiro-geonetwork/conf/shiro.ini`


### Building and running GeoNetwork using a locally downloaded war file

Ensure your war file is locally tested, then copy it into docker-geonetwork/geonetwork.

Ensure you have the schema plugins https://github.com/AstunTechnology/iso19139.gemini23 and https://github.com/AstunTechnology/iso19139.gemini22_GN3 cloned and available at the same relative location in your filesystem as `docker-geonetwork`.

Copy `.env-local.sample` to `.env-local` and fill in the credentials- note it's the same value in each case.

Build from the root `docker-geonetwork` folder using:

	docker build -f Dockerfile.local .

Once the image is built, ensure you're using `build` and `context` rather than `image` in your `docker-compose.yml` then:

	docker-compose -f docker-compose.yml --env-file .env-local up

Add the `-d` parameter if you want it to run quietly.


## Testing locally

There is an additional `docker-compose-dev.yml` file to build a separate set of ephemeral containers to run the built-in GeoNetwork integration tests. To run the tests. See the instructions at the top of `docker-compose-dev.yml` for information on how to run.

## Docker Security Tests

See https://astuntech.atlassian.net/wiki/spaces/ITA/pages/1992097906/Docker+security+testing
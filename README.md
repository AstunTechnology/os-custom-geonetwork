# Docker Geonetwork

Instructions for deploying a customised GeoNetwork install (from a web archive file) including the following supporting software:

 * ElasticSearch
 * Kibana
 * Zeppelin (optional)
 * Nginx
 * PostgreSQL/PostGIS (mandatory but can be RDS)

It includes files for building and testing GeoNetwork locally, and also files specific to deploying using AWS ECS.

Note: local containers can use `containername` to communicate with each other. ECS containers use `localhost`. ECS also needs/supports different config. That's why we need different versions of everything.


## Questions before you start

**Is the client likely to want to access to core geonetwork code and/or the docker customisations and config?**

If the answer to the above is NO (default):

* Create a new branch of https://bitbucket.org/astuntech/core-geonetwork/src/3.10.x/ with the format `custom/clientshortname`
* Create a branch of this repository with the form `clientshortname`

*Note that the 3.10.x branch is rectified with https://github.com/geonetwork/core-geonetwork 3.10.x about once a month- by pulling changes from core into a local copy, pushing them to this repository and doing a pull request per custom branch to get the custom branches up to date. Generally this works just fine but occasionally there's a conflict- in which case bitbucket provides instructions on how to resolve locally.*

If the answer is YES:

* Create a new branch of https://github.com/AstunTechnology/custom-geonetwork with the format `clientshortname-version`
* Create new custom repository on GitHub for the docker code, looking like, and named like https://github.com/AstunTechnology/os-custom-geonetwork and leave, your work is done here

*Our custom-geonetwork repository on GitHub is a straight fork of the main core geonetwork one so can be brought up to date using a pull request in the normal way*

**Are you going to use an RDS for the databse when deploying in ECS?**

If NO (default):

* Use the `docker-compose-postgres-ecs.yml` file, which will create a local postgresql database on the server alongside the other components

If YES:

* Create a `.env` file from `.env.sample` with your credentials in it. 
* Use `docker-compose-rds-ecs.yml` which will use an RDS for the database

**Are you going to need to make any changes to GeoNetwork that require building from source?**

If NO (default):

* Choose the correct GeoNetwork image in the `services\geonetwork` section of the correct docker-compose file for you (see above)
* Keep any `build` or `context` lines commented out

If YES: 

* You'll be working locally so use `docker-compose.yml` and comment out the `services\geonetwork\images` lines. Un-comment the `build` and `context` lines.
* **RECOMMENDED** build and test GeoNetwork locally so that you have a working geonetwork.war file, and copy it into the `docker-geonetwork/geonetwork` folder. Then use `Dockerfile.local` to build your image.
* If you absolutely must try to build from a war file on bitbucket then think again, but if you really must then use Dockerfile.bitbucket for the build and follow the additional instructions below
* Note that a local build of GeoNetwork can't be deployed to ECS, you'll need to publish it to the AWS Public ECR container registry first. 


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

### Running GeoNetwork locally using a standard image

Ensure you have the schema plugins https://github.com/AstunTechnology/iso19139.gemini23 and https://github.com/AstunTechnology/iso19139.gemini22_GN3 cloned and available at the same relative location in your filesystem as `docker-geonetwork`.

In `docker-compose.yml` modify `services\geonetwork\images` to match the image you wish to download. Keep `build` and `context` commented out then run:

	docker-compose -f docker-compose.yml up

Add the `-d` parameter if you want it to run quietly.

### Deploying GeoNetwork to ECS

You'll be using either `docker-compose-postgres-ecs.yml` with `ecs-params.yml` or `docker-compose-rds-ecs.yml` with `ecs-params-rds.yml`.

Ensure you have an AWS and ECS profile properly configured and set up. Modify your `docker-compose` and `ecs-params` files with the correct values for subnets and security groups as provided.


In your `docker-compose` modify `services\geonetwork\images` to match the image you wish to download. Keep `build` and `context` commented out then see https://astuntech.atlassian.net/wiki/spaces/ITA/pages/966852646/Docker#GeoNetwork for the generalised commands to deploy, substiting your ECS and AWS profile, and subnets/security groups as needed.


### Building and running GeoNetwork using a locally downloaded war file

Ensure your war file is locally tested, then copy it into docker-geonetwork/geonetwork.

Ensure you have the schema plugins https://github.com/AstunTechnology/iso19139.gemini23 and https://github.com/AstunTechnology/iso19139.gemini22_GN3 cloned and available at the same relative location in your filesystem as `docker-geonetwork`.

Build from the root `docker-geonetwork` folder using:

	docker build -f Dockerfile.local .

Once the image is built, ensure you're using `build` and `context` rather than `image` in your `docker-compose.yml` then:

	docker-compose -f docker-compose.yml up

Add the `-d` parameter if you want it to run quietly.

### Building and running GeoNetwork locally using a war file from bitbucket

Ensure that the war file you wish to deploy is available as part of the downloads in https://bitbucket.org/astuntech/docker-geonetwork/downloads/. This may mean creating one with a different name. If your file is big enough it may trip the BitBucket upload size limit, in which case it will provide instructions on how to use the API to upload the file with cURL.

Grab your app password that you created what seems like years ago and create a file `creds.txt` in the root `docker-geonetwork` folder with the following format:

	--user yourbitbucketusername:yourapppassword

Take a copy of `env.test`,  save it as `.env`, and edit it to match your postgresql super user credentials. 

**Ensure you don't inadvertently overwrite or edit `env.test` as that is needed!**


Build the docker image for geonetwork from the `docker-geonetwork` root folder with the following command:

	DOCKER_BUILDKIT=1 docker build -t customgeonetwork -f Dockerfile.bitbucket--no-cache --secret id=creds,src=creds.txt --progress=plain .

Then run docker-compose from the same root folder as follows:

	docker-compose -f docker-compose.yml up -d


## Testing locally

There is an additional `docker-compose-dev.yml` file to build a separate set of ephemeral containers to run the built-in GeoNetwork integration tests. To run the tests. See the instructions at the top of `docker-compose-dev.yml` for information on how to run.

## Docker Security Tests

See https://astuntech.atlassian.net/wiki/spaces/ITA/pages/1992097906/Docker+security+testing
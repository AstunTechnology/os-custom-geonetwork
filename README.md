# Docker Geonetwork

Instructions for deploying a customised GeoNetwork install (from a web archive file) including the following supporting software:

 * ElasticSearch
 * Kibana
 * Zeppelin
 * Nginx

## Installation

### Requirements

* Docker
* Docker-Compose
* A postgresql database for which you have credentials for both a super-user and a read-only user

How to install on an ubuntu server:

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


### Prep

This assumes you have a war file for the GeoNetwork project you wish to deploy. For instructions on how to build that, see https://geonetwork-opensource.org/manuals/trunk/en/install-guide/installing-from-source-code.html

Ensure that the war file you wish to deploy is available as part of the downloads in https://bitbucket.org/astuntech/geonetwork-build/downloads/. This may mean creating one with a different name. If your file is big enough it may trip the BitBucket upload size limit, in which case it will provide instructions on how to use the API to upload the file with cURL.

### Set Up

Clone https://bitbucket.org/astuntech/docker-geonetwork onto the server you wish to deploy on and initialise the submodule for shiro-geonetwork:

	git clone git@bitbucket.org:astuntech/docker-geonetwork.git
	cd docker-geonetwork
	git submodule update --init

Modify `./shiro-geonetwork/conf/shiro.ini.geonetworkexample` to match your GeoNetwork postgresql read-only credentials and save it as `./shiro-geonetwork/conf/shiro.ini`

Get an app password from bitbucket with **read** access to **repositories** and create a file `creds.txt` in the root `docker-geonetwork` folder with the following format:

	--user yourbitbucketusername:yourapppassword

Take a copy of `env.test`,  save it as `.env`, and edit it to match your postgresql super user credentials. 

**Ensure you don't inadvertently overwrite or edit `env.test` as that is needed!**


### Building and Running

Build the docker image for geonetwork from the `docker-geonetwork` root folder with the following command:

	DOCKER_BUILDKIT=1 docker build -t customgeonetwork --no-cache --secret id=creds,src=creds.txt --progress=plain .

Then run docker-compose from the same root folder as follows:

	docker-compose -f docker-compose.yml up -d


Once the installation is up and running, navigate to the Kibana Dashboard at `https:\\[yourgeonetworkURL]\geonetwork\dashboards\app\kibana` and load the saved objects settings file `kibana/export.ndjson`


## Testing

There is an additional docker-compose file to build a separate set of ephemeral containers to run the built-in GeoNetwork integration tests. To run the tests:

Build a new GeoNetwork image:

	DOCKER_BUILDKIT=1 docker build -t docker-geonetwork_geonetwork --no-cache --secret id=creds,src=creds.txt --progress=plain .

Then run the tests:

	docker-compose -f docker-compose-dev.yml run --rm  integration mvn clean test -Dbrowser=firefox -DendPointToTest=http://geonetwork:8080/geonetwork -Dcucumber.options="--plugin pretty" && docker-compose down

### Testing work to do

 * Report back test failures via email
 * Additional robot framework tests customised for each GeoNetwork installation (eg SSDI, EA, Astun)	






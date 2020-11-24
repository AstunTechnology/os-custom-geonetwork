#!/bin/sh

echo Initiating Elasticsearch Custom Index
# move to the directory of this setup script
cd "$(dirname "$0")"

# should wrap this in some logic to check if the indices already exist or not
# this isn't working yet!

#if ! http://elasticsearch:9200/gn-records ; then
	echo "Loading Indices into ElasticSearch"
	curl -s -XPUT -H 'Content-Type: application/json' http://elasticsearch:9200/gn-records -d @/records.json
	curl -s -XPUT -H 'Content-Type: application/json' http://elasticsearch:9200/gn-features -d @/features.json
	curl -s -XPUT -H 'Content-Type: application/json' http://elasticsearch:9200/gn-searchlogs -d @/searchlogs.json

#else
#	echo "Indices already exist"
#fi
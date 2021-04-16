#!/bin/sh

echo Initiating Elasticsearch Custom Index
# move to the directory of this setup script
cd "$(dirname "$0")"

until $(curl -sSf -XGET  'http://localhost:9200/_cluster/health?wait_for_status=yellow' -u elastic:elastic > /dev/null); do
    printf 'not ready, trying again in 5 seconds \n'
    sleep 5
done

echo "Loading Indices into ElasticSearch"
curl -s -XPUT -H 'Content-Type: application/json' http://0.0.0.0:9200/gn-records -u elastic:elastic -d @/records.json
curl -s -XPUT -H 'Content-Type: application/json' http://0.0.0.0:9200/gn-records-public -u elastic:elastic -d @/records.json
curl -s -XPUT -H 'Content-Type: application/json' http://0.0.0.0:9200/gn-features -u elastic:elastic -d @/features.json
curl -s -XPUT -H 'Content-Type: application/json' http://0.0.0.0:9200/gn-searchlogs -u elastic:elastic -d @/searchlogs.json

# else
# 	echo "Indices already exist"
# fi
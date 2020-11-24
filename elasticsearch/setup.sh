#!/bin/sh

echo Initiating Elasticsearch Custom Index
# move to the directory of this setup script
cd "$(dirname "$0")"

until $(curl -sSf -XGET  'http://localhost:9200/_cluster/health?wait_for_status=yellow' > /dev/null); do
    printf 'not ready, trying again in 5 seconds \n'
    sleep 5
done

echo "Loading Indices into ElasticSearch"
curl -s -XPUT -H 'Content-Type: application/json' http://0.0.0.0:9200/gn-records -d @/records.json
curl -s -XPUT -H 'Content-Type: application/json' http://0.0.0.0:9200/gn-features -d @/features.json
curl -s -XPUT -H 'Content-Type: application/json' http://0.0.0.0:9200/gn-searchlogs -d @/searchlogs.json

# else
# 	echo "Indices already exist"
#fi
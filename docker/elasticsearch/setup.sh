#!/bin/sh

echo Initiating Elasticsearch Custom Index
# move to the directory of this setup script
cd "$(dirname "$0")"

until $(curl -sSf -XGET  'http://localhost:9200/_cluster/health?wait_for_status=yellow' > /dev/null); do
    printf 'not ready, trying again in 5 seconds \n'
    sleep 5
done

echo "Loading Indices into ElasticSearch"
for f in *.json ; do 
	if [ $(curl -LI "http://localhost:9200/gn-${f%.*}" -o /dev/null -w '%{http_code}\n' -s) == "200" ] ; 
		then echo "gn-${f##*/} exists" ; 
	else echo "gn-${f%.*} missing" && curl -X PUT "http://localhost:9200/gn-${f%.*}" -H "Content-Type:application/json"  -d @$f ; 
	fi ; 
done
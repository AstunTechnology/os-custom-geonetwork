#!/bin/bash
# Get cluster health status (yellow/green are OK)
curl -X GET 'http://localhost:9200/_cat/health?h=st'

# check if the indices are present, if they are not then load them
for f in *.json ; do if [ $(curl -LI "http://localhost:9200/gn-${f%.*}" -o /dev/null -w '%{http_code}\n' -s) == "200" ] ; then echo "gn-${f##*/} exists" ; else echo "gn-${f%.*} missing" && curl -X PUT "http://localhost:9200/gn-${f%.*}" -H "Content-Type:application/json"  -d @$f ; fi ; done

# load kibana saved objects
curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf:true" --form file=@export.ndjson




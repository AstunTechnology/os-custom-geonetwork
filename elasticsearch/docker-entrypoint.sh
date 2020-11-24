#!/bin/sh

# wait for Elasticsearch to start, then run the setup script to
# create and configure the index.
exec /wait-for-it.sh elasticsearch:9200 -- /setup.sh &
exec $@ 
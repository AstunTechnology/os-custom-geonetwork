#!/bin/bash
curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf:true" --form file=@export.ndjson




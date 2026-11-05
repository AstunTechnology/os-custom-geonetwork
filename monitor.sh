#!/bin/bash

# generate a session token lasting six hours (21,600 seconds)
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2> /dev/null`

# get the region from the metadata service
REGION=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/region 2> /dev/null`

# get the EC2 instance ID from the metadata service
INSTANCE_ID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id 2> /dev/null`

# obtain docker stats and format them into JSON
STATS=$(docker stats --no-stream --format "{\"container\": \"{{ .Container }}\",\"name\": \"{{ .Name }}\", \"memory\": { \"raw\": \"{{ .MemUsage }}\", \"percent\": \"{{ .MemPerc }}\"}, \"cpu\": \"{{ .CPUPerc }}\"}" | jq '.' -s -c )

# get total number of containers
NUM_CONTAINERS=$(echo "$STATS" | jq '. | length')

# iterate through JSON to obtain required values for each container
for (( i=0; i<$NUM_CONTAINERS; i++ )) 
    do CPU=$(echo "$STATS" | jq -r .[$i].cpu | sed 's/%//')
    MEMORY=$(echo "$STATS" | jq -r .[$i].memory.percent | sed 's/%//')
    CONTAINER=$(echo $STATS | jq -r .[$i].container)
    CONTAINER_NAME=$(echo $STATS | jq -r .[$i].name)

# upload values to CloudWatch using AWS CLI
aws cloudwatch put-metric-data --metric-name CPU --namespace DockerStats --unit Percent --value $CPU --dimensions InstanceId=$INSTANCE_ID,ContainerId=$CONTAINER,ContainerName=$CONTAINER_NAME --region $REGION

aws cloudwatch put-metric-data --metric-name Memory --namespace DockerStats --unit Percent --value $MEMORY --dimensions InstanceId=$INSTANCE_ID,ContainerId=$CONTAINER,ContainerName=$CONTAINER_NAME --region $REGION

done

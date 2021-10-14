#/bin/bash

REGION=eu-west-1
SECGRP=sg-0192b068e0185d319
VPC=vpc-01f55c9340e0bee27
PROFILE=ea-docker
SUBNET_EXT1=subnet-0a94c6fea5f8157b4 #1_ext az2
SUBNET_EXT2=subnet-09db39011f1d586aa #2_ext az3
CLUSTER_CONFIG=ea-docker
CLUSTER=docker-geonetwork-ec2
FILE=docker-compose-rds-ecs.yml
   
Help()
{
	echo "Helper functions for launching docker-geonetwork using ECS."
	echo "Make sure you complete the variables at the top of the script."
	echo
	echo "Syntax: launch.sh [option]"
	echo
	echo "Options:"
	echo "-c|--configure configure cluster"
	echo "-i|--instanceup bring up EC2 instance"
	echo "-d|--deploycontainers deploy containers in EC2 instance"
	echo "-u|--undeploycontainers undeploy containers"
	echo "-k|--killinstance kill EC2 instance"
	echo "-f|--followlogs follow task logs"
	echo
}



for arg in "$@"
do
	case $arg in

		-h|--help)

		Help
		;;
		
		-c|--configure)

		ecs-cli configure --cluster $CLUSTER \
		--default-launch-type EC2 --config-name $CLUSTER_CONFIG --region $REGION
		;;

		-i|--instanceup)

		ecs-cli up \
		--capability-iam \
		--instance-type t3a.large \
		--keypair ea \
		--size 1 \
		--security-group $SECGRP \
		--subnets $SUBNET_EXT1,$SUBNET_EXT2 \
		--vpc $VPC \
		--extra-user-data bitbucket.sh \
		--extra-user-data server_prep.sh  \
		--cluster $CLUSTER \
		--force \
		--ecs-profile $PROFILE \
		--region $REGION
		;;

		-d|--deploycontainers)

		ecs-cli compose \
		--file $FILE \
		service up \
		--force-deployment \
		--cluster $CLUSTER \
		--launch-type EC2 \
		--target-group-arn arn:aws:elasticloadbalancing:eu-west-1:139926528184:targetgroup/docker-geonetwork-new/fbd6df82a319acb2 \
		--container-name nginx \
		--container-port 80 \
		--health-check-grace-period 1800 \
		--ecs-profile $PROFILE
		;;

		-u|--undeploycontainers)

		ecs-cli compose \
		--file $FILE \
		service rm \
		--cluster $CLUSTER \
		--ecs-profile $PROFILE
		;;

		-k|--killinstance)

		ecs-cli down \
		--cluster $CLUSTER \
		--ecs-profile $PROFILE
		;;

		-f|--followlogs)
		taskid=$( aws ecs list-tasks --cluster $CLUSTER --profile $PROFILE | jq '.[]' | jq -j .[] | cut -d/ -f3) && \
		ecs-cli logs --follow --task-id $taskid --ecs-profile $PROFILE --cluster $CLUSTER
		;;

		*)

		Help
		;;

	esac

done

if [ -z "$*" ]; then Help; fi

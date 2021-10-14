#/bin/bash

VPC=vpc-01f55c9340e0bee27
PROFILE=ea-docker
KEYPAIR=ea.pem
#RDS=geonet.cd9fhl2gkjny.eu-west-1.rds.amazonaws.com
ROOT=l33t

instanceIP=$( aws ec2 describe-instances --filters "Name=vpc-id, Values=$VPC" --query 'Reservations[*].Instances[*].PublicIpAddress' --output json --profile $PROFILE | jq .[]| jq -r .[] )

su - $ROOT sh -c "sudo -S route del -net $instanceIP netmask 255.255.255.255 dev tun0"
su - $ROOT sh -c "sudo -S route add -net $instanceIP netmask 255.255.255.255 dev tun0"

ssh ec2-user@$instanceIP -i ~/.ssh/$KEYPAIR
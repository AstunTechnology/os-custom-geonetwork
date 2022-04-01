#!/bin/bash

# pull and run clamav image, scanning docker volumes
# send output to clamav-logs/output.txt
# move infected files to clamav-quarantine

#unset $DOCKER_CONTENT_TRUST because the av container is not signed
unset DOCKER_CONTENT_TRUST

docker run --rm -it -v /var/lib/docker/volumes:/scan -v /home/ec2-user/clamav-logs:/logs -v /home/ec2-user/clamav-quarantine:/quarantine tquinnelly/clamav-alpine  --log=logs/output.txt --move=quarantine

#  read the SMTP environment variables from the .env file
set -a; source /home/ec2-user/.env; set +a

# add a line to output.txt so we know the cron job has run even if
# clamav doesn't, because of network error or whatever

if [ ! -f /home/ec2-user/clamav-logs/output.txt ]; then
        sudo echo -e "Antivirus job ran, but no output was generated\n" >> /home/ec2-user/clamav-logs/output.txt
fi

# send output file as email using curl
sudo curl -v --url smtps://$SMTP --ssl-reqd  --mail-from $EMAILADDR --mail-rcpt $EMAILADDR  --user $SMTPUSER:$SMTPPWD -F '=</home/ec2-user/clamav-logs/output.txt;encoder=quoted-printable' -H "Subject: $ES_PREFIX  antivirus output $(date +%Y-%m-%d)" -H "From: $EMAILADDR <$EMAILADDR>" -H "To: $EMAILADDR <$EMAILADDR>"


# remove the log file
sudo rm /home/ec2-user/clamav-logs/output.txt

# reset $DOCKER_CONTENT_TRUST
export DOCKER_CONTENT_TRUST=1

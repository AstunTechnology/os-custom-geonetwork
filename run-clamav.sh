#!/bin/bash

# pull and run clamav image, scanning docker volumes
# send output to clamav-logs/output.txt
# move infected files to clamav-quarantine
docker run --rm -it -v /var/lib/docker/volumes:/scan -v /home/ec2-user/clamav-logs:/logs -v /home/ec2-user/clamav-quarantine:/quarantine tquinnelly/clamav-alpine -i --log=logs/output.txt --move=quarantine

#  read the SMTP environment variables from the .env file
set -a; source .env; set +a

# send output file as email using curl
sudo curl --ssl-reqd   --url smtps://$SMTP   --user $SMTPUSER:$SMTPPWD   --mail-from $EMAILADDR   --mail-rcpt $EMAILADDR   --upload-file clamav-logs/output.txt

# remove the log file
sudo rm clamav-logs/output.txt
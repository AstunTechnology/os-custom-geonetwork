#!/bin/bash

# pull and run clamav image, scanning docker volumes
# send output to clamav-logs/output.txt
# move infected files to clamav-quarantine
docker run --rm -it -v /var/lib/docker/volumes:/scan -v /home/ec2-user/clamav-logs:/logs -v /home/ec2-user/clamav-quarantine:/quarantine tquinnelly/clamav-alpine  --log=logs/output.txt --move=quarantine

#  read the SMTP environment variables from the .env file
set -a; source /home/ec2-user/.env; set +a

# add a line to output.txt so we know the cron job has run even if
# clamav doesn't, because of network error or whatever

sudo echo "Antivirus job ran, but if this is the only line then no output was generated\n"  | tee -a /home/ec2-user/clamav-logs/output.txt

# send output file as email using curl
sudo curl --ssl-reqd   --url smtps://$SMTP   --user $SMTPUSER:$SMTPPWD   --mail-from $EMAILADDR   --mail-rcpt $EMAILADDR   --upload-file /home/ec2-user/clamav-logs/output.txt

# remove the log file
sudo rm /home/ec2-user/clamav-logs/output.txt


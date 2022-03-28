#!/usr/bin/bash

# pull and run clamav container; non-interactive for cron
# send logs to clamav-logs
# move infected files to clamav-quarantine

# make sure we have the environment variables available
set -a; source /home/astun/docker-geonetwork/.env; set +a
# make directories for quarantine and logs if they don't exist

mkdir -p /home/astun/clamav-logs /home/astun/clamav-quarantine

# unset $DOCKER_CONTENT_TRUST because the av container is not signed
unset DOCKER_CONTENT_TRUST

# change the first mounted volume to match the correct directory to scan
docker run --rm -v /var/lib/docker/volumes:/scan:ro -v /home/astun/clamav-logs:/logs:rw -v /home/astun/clamav-quarantine:/quarantine:rw tquinnelly/clamav-alpine --log=logs/output.txt --move=quarantine

# ensure the log file is created even if the container doesn't run for some reason
if [ ! -f /home/astun/clamav-logs/output.txt ]; then
        echo -e "Antivirus job ran, but no output was generated\n" >> /home/astun/clamav-logs/output.txt
fi

# send email with output.txt as body
curl -v --url smtps://$SMTP --ssl-reqd  --mail-from $EMAILADDR --mail-rcpt $EMAILADDR  --user $SMTPUSER:$SMTPPWD -F '=</home/astun/clamav-logs/output.txt;encoder=quoted-printable' -H "Subject: $ES_PREFIX  antivirus output $(date +%Y-%m-%d)" -H "From: $EMAILADDR <$EMAILADDR>" -H "To: $EMAILADDR <$EMAILADDR>"

# remove the old log file
rm /home/astun/clamav-logs/output.txt

# reset $DOCKER_CONTENT_TRUST
export DOCKER_CONTENT_TRUST=1




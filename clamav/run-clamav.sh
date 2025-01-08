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

# change to correct directory
cd /home/astun/docker-geonetwork/clamav

# set custom ssmtp.conf

# root=$SSMTP_TO
cat << EOF > ssmtp.conf
mailhub=$SMTP:$SMTP_PORT
AuthUser=$SMTP_USERNAME
AuthPass=$SMTP_PASSWORD
AuthMethod=LOGIN
UseSTARTTLS=YES
useTLS=YES
Hostname=uat.astuntechnology.com
FromLineOverride=YES
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
EOF

# set up output file from sample with environment variables and such like
cp output.txt.sample output.txt
sed -i -e "s|TOADDRESS|$EMAIL_ADDR|g" output.txt
sed -i -e "s|FROMADDRESS|$EMAIL_ADDR|g" output.txt
sed -i -e "s|SUBJECT|$GN_SITE_NAME antivirus output $(date +%Y-%m-%d)|g" output.txt

# change the first mounted volume to match the correct directory to scan
docker run --rm -v /var/lib/docker/volumes:/scan:ro -v /home/astun/clamav-logs:/logs:rw -v /home/astun/clamav-quarantine:/quarantine:rw tquinnelly/clamav-alpine --log=logs/output.txt --move=quarantine

# ensure the log file is created even if the container doesn't run for some reason
if [ ! -f /home/astun/clamav-logs/output.txt ]; then
        echo -e "Antivirus job ran, but no output was generated\n" >> /home/astun/clamav-logs/output.txt
fi

# append logs to output email file
cat /home/astun/clamav-logs/output.txt >> output.txt

# send email with output.txt as body
#curl -v --url smtps://$SMTP_URL_CLAMAV --ssl-reqd  --mail-from $EMAIL_ADDR --mail-rcpt $EMAIL_ADDR  --user $SMTP_USERNAME:$SMTP_PASSWORD -F '=</home/astun/clamav-logs/output.txt;encoder=quoted-printable' -H "Subject: $GN_SITE_NAME  antivirus output $(date +%Y-%m-%d)" -H "From: $EMAIL_ADDR <$EMAIL_ADDR>" -H "To: $EMAIL_ADDR <$EMAIL_ADDR>"

/usr/sbin/ssmtp -v -C ssmtp.conf  metadata@astuntechnology.com < output.txt


# remove log file, output email and generated ssmtp.conf
rm /home/astun/clamav-logs/output.txt output.txt ssmtp.conf

# reset $DOCKER_CONTENT_TRUST
export DOCKER_CONTENT_TRUST=1


#!/usr/bin/bash

# pull and run clamav container; non-interactive for cron
# send logs to clamav-logs
# move infected files to clamav-quarantine

# make directories for quarantine and logs if they don't exist

sudo mkdir -p /home/ec2-user/clamav-logs /home/ec2-user/clamav-quarantine

# unset $DOCKER_CONTENT_TRUST because the av container is not signed
unset DOCKER_CONTENT_TRUST

# change the first mounted volume to match the correct directory to scan
docker run --rm -v /var/lib/docker/volumes:/scan -v /home/ec2-user/clamav-logs:/logs -v /home/ec2-user/clamav-quarantine:/quarantine tquinnelly/clamav-alpine --log=logs/output.txt --move=quarantine

# make sure we have the environment variables available
source /home/ec2-user/clamav/.clamavenv

# ensure the log file is created even if the container doesn't run for some reason
if [ ! -f /home/ec2-user/clamav-logs/output.txt ]; then
        echo -e "Antivirus job ran, but no output was generated\n" >> /home/ec2-user/clamav-logs/output.txt
fi

# change permission on output.txt so we can send email
sudo chown ec2-user:ec2-user /home/ec2-user/clamav-logs/output.txt

# send an email with the log file as body
openssl s_client -crlf -quiet -connect $SMTP  << EOF
helo
auth login
$(echo $SMTPUSER | base64)
$(echo $SMTPPWD | base64)
mail from:$EMAILADDR
rcpt to:$EMAILADDR
Data
From: $EMAILADDR
To: $EMAILADDR
Subject: $HOSTNAME Clamav Log $(date +%Y-%m-%d)

$(< /home/ec2-user/clamav-logs/output.txt)
.
EOF

# remove the old log file
sudo rm /home/ec2-user/clamav-logs/output.txt

# reset $DOCKER_CONTENT_TRUST
export DOCKER_CONTENT_TRUST=1



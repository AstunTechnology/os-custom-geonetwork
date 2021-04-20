#!/usr/bin/bash

# pull and run clamav container; non-interactive for cron
# send logs to clamav-logs
# move infected files to clamav-quarantine

docker run --rm -v /var/lib/docker/volumes:/scan -v /home/ec2-user/clamav-logs:/logs -v /home/ec2-user/clamav-quarantine:/quarantine tquinnelly/clamav-alpine -i --log=logs/output.txt --move=quarantine

# make sure we have the environment variables available
source /home/ec2-user/.env

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

$(< ./clamav-logs/output.txt)
.
EOF

# remove the old log file
sudo rm /home/ec2-user/clamav-logs/output.txt


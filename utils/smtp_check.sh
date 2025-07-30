#!/bin/bash

# make sure we have the environment variables available
set -a; source $HOME/docker-geonetwork/.env; set +a

# set the value of variables
logfile="smtp_check_log.txt"
host=$POSTGRES_DB_HOST
port=$POSTGRES_DB_PORT
database=$POSTGRES_DB_NAME
user=$POSTGRES_DB_USERNAME
password=$POSTGRES_DB_PASSWORD
geonetworkSmtpPassword=$SMTP_PASSWORD
currentDateTime=`date +"%Y-%m-%d %T"`

# set Postgres env variable to avoid the need
# to authenticate when running psql commands
export PGPASSWORD=$password

# set custom ssmtp.conf
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

# execute psql command to retrieve the current password from GeoNetwork
currentPassword=$(psql -t -h $host -p $port -U $user -d $database -c "select value from settings where name = 'system/feedback/mailServer/password';" 2>&1 | awk '{$1=$1};1')

# check for errors from psql
if [[ "$currentPassword" == *"ERROR:"* || "$currentPassword" == *"error:"* ]]; then
    echo -e "Error retrieving password:\n$currentPassword" > $logfile

else
    if [ "$currentPassword" = "$geonetworkSmtpPassword" ]; then
        echo "$currentDateTime INFO: Passwords are the same" > $logfile

    # logic for correcting the password:
    elif [ "$currentPassword" = "" ]; then
        psql -h $host -p $port -U $user -d $database -c "update settings set value = '$geonetworkSmtpPassword', encrypted = 'n' where name = 'system/feedback/mailServer/password' and value = '';" > $logfile
        echo "$currentDateTime ERROR: Password is missing - reseting it" >> $logfile

    elif [ "$currentPassword" != "$geonetworkSmtpPassword" ]; then
        psql -h $host -p $port -U $user -d $database -c "update settings set value = '$geonetworkSmtpPassword', encrypted = 'n' where name = 'system/feedback/mailServer/password' and value = '$currentPassword';" > $logfile
        echo "$currentDateTime ERROR: Password is incorrect - reseting it" >> $logfile
    fi
fi

# read the content of the logfile
log_content=$(cat "$logfile")

# check if the content contains the specified string
if [[ "$log_content" == *"INFO: Passwords are the same"* ]]; then
    # don't send an email if there was no issue
    echo "No problem with the password."	

else
    # set up output file from sample with environment variables and such like
    cp output.txt.sample output.txt
    sed -i -e "s|TOADDRESS|$EMAIL_ADDR|g" output.txt
    sed -i -e "s|FROMADDRESS|$EMAIL_ADDR|g" output.txt
    sed -i -e "s|SUBJECT|$GN_SITE_NAME SMTP password check output $(date +%Y-%m-%d)|g" output.txt
    sed -i -e "s|SITE|$GN_PROTOCOL://$GN_URL/geonetwork|g" output.txt

    # append logs to output email file
    cat $logfile >> output.txt

    # send email with output.txt as body
    /usr/sbin/ssmtp -v -C ssmtp.conf metadata@astuntechnology.com < output.txt

    # remove the output email
    rm output.txt

fi

# unset the postgres password variable
unset PGPASSWORD

# remove the log file and generated ssmtp.conf
rm ssmtp.conf $logfile

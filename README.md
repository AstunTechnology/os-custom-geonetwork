# Docker Geonetwork CLAMAV BRANCH

**For testing an ephemeral docker container running clamav on the server, which sends the clamav log file to a named user**

**This is probably not the branch you want!**

Requires SMTP credentials to be filled in in `.env` and then once you have running containers on the server, ssh onto it and run the following command:

`
docker run --rm -it \
-v /var/lib/docker/volumes:/scan \
-v /home/ec2-user/clamav-logs:/logs \
-v /home/ec2-user/clamav-quarantine:/quarantine \
tquinnelly/clamav-alpine -i \
--log=logs/output.txt \
--move=quarantine && \ 
sudo curl --ssl-reqd   --url "smtps://$SMTP"   --user "$SMTPUSER:$SMTPPWD"   --mail-from "$EMAILADDR"   --mail-rcpt "$EMAILADDR"   --upload-file clamav-logs/output.txt && \
sudo rm clamav-logs/output.txt
`

* If running it on your local machine you will need to adjust the volume locations in the above commands to match.

* You shouldn't need to create the log and quarantine directories but if it doesn't work, try doing exactly that.

* For a tame virus file for testing purposes go to https://www.eicar.org/?page_id=3950.
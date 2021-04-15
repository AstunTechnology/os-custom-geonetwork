# Docker Geonetwork CLAMAV BRANCH

**For testing an ephemeral docker container running clamav on the server, which sends the clamav log file to a named user**

**This is probably not the branch you want!**

Requires SMTP credentials to be filled in in `.env` and then once you have running containers on the server, ssh onto it and run the shell-script `clamav/run-clamav.sh`.

The shell-script is set to run as a scheduled task for the `ec2-user` (see `clamav/clamav.crontab`). The crontab is loaded as part of `bitbucket.sh` when the server is provisioned.


* If running it on your local machine you will need to adjust the volume locations in the above commands to match.

* You shouldn't need to create the log and quarantine directories but if it doesn't work, try doing exactly that.

* For a tame virus file for testing purposes go to https://www.eicar.org/?page_id=3950.
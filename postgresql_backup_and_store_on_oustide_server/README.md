The script does the following actions: 
1. Create a postgresql DB backup file
2. Check if the created DB backup is different from the last stored. If it's the same - deletes the new one.
3. If the new DB backup is different - sent it to remote storage server via scp (using ssh key-based authentication)
4. Add info into log file (/var/log/dbbackuplog.log)

Run the scipt manualy for DB user postgres:

sudo -u postgres /opt/dbbackup.sh 2>>/var/log/dbbackuplog.log 

The script could be run daily by using crontab:

Run crontab as a user:

sudo -u postgres crontab -e   

Add a task:

SHELL=/bin/bash
0 0 * * * sudo -u postgres /opt/dbbackup.sh 2>>/var/log/dbbackuplog.log     ---> run script daily as 0:00

Verify existing tasks for all users: 

for user in $(cut -f1 -d: /etc/passwd); do echo $user; sudo crontab -u $user -l; done

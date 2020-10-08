The script does the following actions: 
1. Create a Postgresql DB backup file (/var/backups/dbbackup/)
2. Check if the created DB backup is different from the last stored. If it's the same - delete the new one.
3. If the new DB backup is different - left it and copy to remote storage server via scp (using ssh key-based authentication)
4. Delete the oldest backup, so the only 14 last backups left on disk
5. Add info into a log file (/var/log/dbbackuplog.log)

######

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

######

SSH key-based authentication 

1. create ssh keys:
 ssh-keygen

it will create private key called id_rsa and public key kalled ip_rsa.pub

2. copy the public key to the server:
ssh-copy-id username@server_ip

OR

cat ~/.ssh/id_rsa.pub | ssh username@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

OR copy it manualy to ~/.ssh/authorized_keys

now you can connect using "ssh username@server_ip" command without using password  

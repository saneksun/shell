#!/bin/bash
filepath="/var/backups/dbbackup/"
bkname="dbbackup_$(date +%Y%m%d_%H%M%S).gz"
filename="$filepath$bkname"
logfile="/var/log/dbbackuplog.log"
timestamp=$(date +%Y-%m-%d_%H:%M:%S)
zerofile="$(find $filepath -empty -type f -delete -print)"
lastfile="$(ls $filepath -t1 | grep '.gz' | head -n 1)"
lastsize="$(stat -c %s $filepath$lastfile)"
remote_path=/home/postgres/

if  [[ -n $(pg_dump netbox |  gzip > "$filename") ]]; then
        echo "$(date +%Y-%m-%d_%H:%M:%S) Backup failure." >> $logfile;
        exit 1
else
        if [[ -s $filename ]]; then
                #check if new backup is differ from the previous one:
                if [[ "$lastsize" != "$(stat -c %s $filename)" ]]; then
                        echo "$(date +%Y-%m-%d_%H:%M:%S) Backup done. Backup filename is "$filename"" >> $logfile
                        scp -i /var/lib/postgresql/.ssh/id_rsa $filename postgres@<REMOTE SERVER NAME/IP>:$remote_path$bkname
                        if [[ $? -eq 0 ]]; then echo "$(date +%Y-%m-%d_%H:%M:%S) Backup file "$bkname" was uploaded sucessfully" >> $logfile
                        else echo "$(date +%Y-%m-%d_%H:%M:%S) Backup upload error" >> $logfile
                        fi
                else
                        rm $filename
                        echo "$(date +%Y-%m-%d_%H:%M:%S) No changes, backup skipped" >> $logfile
                fi
        else
            echo "$(date +%Y-%m-%d_%H:%M:%S) Error writing DB backup file." >> $logfile
            exit 1
    fi
fi

if [[ -n "$zerofile" ]]; then
    echo "$(date +%Y-%m-%d_%H:%M:%S) Empty file(s) "$zerofile" deleted." >> $logfile
# Left last 14 backups
elif [[ -n $(find /var/backups/dbbackup/ -maxdepth 1 -name "*.gz" -type f -print | sort -n | head -n -14 | xargs rm -rf) ]]; then
    echo "$(date +%Y-%m-%d_%H:%M:%S) Old files deleted." >> $logfile
else
    echo "$(date +%Y-%m-%d_%H:%M:%S) No old or empty files found." >> $logfile
fi
exit 0

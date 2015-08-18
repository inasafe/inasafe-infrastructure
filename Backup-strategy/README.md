
We'll be using duplicity http://duplicity.nongnu.org/ for backups

The setup will be that we'll do backups of /data/backup /data/dbbackup to Hetzner.de backup server's ```~/${HostName}/{db}backup```

Setup
=====

1) http://wiki.hetzner.de/index.php/Backup_Space_SSH_Keys/en describes a method to copy ssh keys to the Hetzner backup server.


_*Do not copy paste all of them together these, as they need user intervention with passwords*_ (line by line is okay :) )

Initial step only needed once from any server to seed the backup space for the ssh public key authentication:
```
echo "mkdir .ssh" | sftp u109852@u109852.your-backup.de:.ssh
```

These needs to be repeated on all the servers backing up:
```
mkdir auth-setup-dir
cd auth-setup-dir
scp u109852@u109852.your-backup.de:.ssh/authorized_keys .
ssh-keygen -e -f .ssh/id_rsa.pub | grep -v "Comment:"  >> authorized_keys
scp authorized_keys u109852@u109852.your-backup.de:.ssh/authorized_keys
```

Because you need to enter the password given from the http://robot.your-server.de/ to login, this is not feasible to enter/save it in ansible especially as this is a once of procedure.

2) 

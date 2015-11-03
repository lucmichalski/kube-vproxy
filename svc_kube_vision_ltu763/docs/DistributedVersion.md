Distributed installation of LTU engine

1 - On all hosts
Install unzip command.
Edit /etc/hosts in order to add all IP and hostnames of the hosts that will be used for the installation:
Make sure machine hostname do not refer to the loopback address (127.0.0.1) for license subsystem to work correctly.
Unzip ltu-engine archive
Copy the spec and the license files provided by LTU in the extracted folder

2 - On kima hosts
Install rsync server
Configure rsync by editing /etc/rsyncd.conf:
 uid = ltu gid = ltu  list = yes [saas] path = <install_dir>/data/ltu comment = sql lite folder for kima read only = false hosts allow = <database host> ( support mask 10.1.0.0/16 )
Edit /etc/default/rsync.conf and set RSYNC_ENABLE to true
Run ”/etc/init.d/rsync start”

3 - On database host
Go to the ltu-engine extracted folder
Run ./install.sh -i <path_to_spec>
Run /etc/init.d/ltud stop all
Configure NFS to share <install_directory>/data among all cluster hosts:
Make sure NFS server is started at system start and words correctly
Edit /etc/exports:
<install_directory>/data/ 10.1.0.0/255.255.0.0(rw,sync,no_subtree_check,insecure)
restart nfs

4 - On non-database hosts
Go to the ltu-engine extracted folder
Run ./install.sh -i <path_to_spec> -n
Run ”/etc/init.d/ltud stop all”
Configure you system to mount shared folder at the right place in /etc/fstab:
<database_host>:<install_dir>/data/ltu/storage <install_dir>/data/ltu/storage nfs rw,noatime,sync 0 0 <database_host>:<install_dir>/data/ltu/queue <install_dir>/data/ltu/queue nfs 
rw,noatime,sync 0 0 <database_host>:<install_dir>/data/ltu/query <install_dir>/data/ltu/query nfs rw,noatime,sync 0 0 <database_host>:<install_dir>/data/ltu/reports 
<install_dir>/data/ltu/reports nfs rw,noatime,sync 0 0 <database_host>:<install_dir>/data/ltu/ftp <install_dir>/data/ltu/ftp nfs rw,noatime,sync 0 0
Create folders:
mkdir -p <install_dir>/data/ltu/{storage,queue,query,reports,ftp}
Mount all folders:
mount -a

5 - On database host
Generate and distribute a suitable ssh configuration for ltu user:
ssh-keygen -t rsa -P”” # will generate ssh key
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys # will add this key to the authorized keys
Run the following command will add all cluster hosts to the known_hosts file:
for host in [<list_of_hosts>]; do ssh-keyscan -t rsa $host » ~/.ssh/known_hosts; done
Copy the .ssh folder located in the ltu home directory on every hosts
/etc/init.d/ltud start all

6 - On all other hosts
/etc/init.d/ltud start all

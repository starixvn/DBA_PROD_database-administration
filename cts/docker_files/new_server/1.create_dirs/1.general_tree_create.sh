#!/bin/bash

<<'general_folders'
comment go here
general_folders

echo "---> Start create general folders <---"

#root dir
mkdir -p -m 777 /mount/
mkdir -p -m 777 /mount/cts

#sub dir 1
mkdir -p -m 777 /mount/cts/backup

mkdir -p -m 777 /mount/cts/cts_master_mysql80
mkdir -p -m 777 /mount/cts/cts_master_mysql80/data
mkdir -p -m 777 /mount/cts/cts_master_mysql80/config
mkdir -p -m 777 /mount/cts/cts_master_mysql80/config/conf.d
mkdir -p -m 777 /mount/cts/cts_master_mysql80/log
mkdir -p -m 777 /mount/cts/cts_master_mysql80/tmp
mkdir -p -m 777 /mount/cts/cts_master_mysql80/binlog
mkdir -p -m 777 /mount/cts/cts_master_mysql80/vol_data

#copy config file - change if need
cp /mount/cts/new_server/1.create_dirs/cts_master.cnf /mount/cts/53_local_01/cts_master_mysql80/config/conf.d/
cp /mount/cts/new_server/1.create_dirs/my.cnf /mount/cts/53_local_01/cts_master_mysql80/config/

#copy script file
cp /mount/cts/new_server/1.create_dirs/initial.sql /mount/cts/53_local_02/cts_master_mysql80/config/conf.d/

#change the path of root folder (777) if need
echo "---> Set permissions <---" 
chmod -R 777 /mount/cts/
chmod 644 /mount/cts/cts_master_mysql80/config/my.cnf #limit access to fix => mysqld: [Warning] World-writable config file '/etc/mysql/my.cnf' is ignored.
chmod 644 /mount/cts/cts_master_mysql80/config/conf.d/cts_master.cnf #limit access to fix => mysqld: [Warning] World-writable config file '/etc/mysql/my.cnf' is ignored.
chmod 644 /mount/cts/cts_master_mysql80/config/conf.d/initial.sql #create new admin account

echo "---> DONE <---"
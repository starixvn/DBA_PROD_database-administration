#!/bin/bash

<<'general_folders'
comment go here
general_folders

echo "---> Start create general folders <---"

#root dir
mkdir -p -m 777 /mount/
mkdir -p -m 777 /mount/fps

#sub dir 1
mkdir -p -m 777 /mount/fps/backup
mkdir -p -m 777 /mount/fps/backup/fps_db02
mkdir -p -m 777 /mount/fps/backup/fps_db02-fps_01

mkdir -p -m 777 /mount/fps/cronfiles

mkdir -p -m 777 /mount/fps/logshipping
mkdir -p -m 777 /mount/fps/logshipping/ls_backuplog_mapping
mkdir -p -m 777 /mount/fps/logshipping/ls_backuplog_mapping/fps_db02
mkdir -p -m 777 /mount/fps/logshipping/ls_backuplog_mapping/fps_db02-fps_01

mkdir -p -m 777 /mount/fps/logshipping/ls_copylog_mapping
mkdir -p -m 777 /mount/fps/logshipping/ls_copylog_mapping/fps_db02
mkdir -p -m 777 /mount/fps/logshipping/ls_copylog_mapping/fps_db02-fps_01

mkdir -p -m 777 /mount/fps/tls_config
mkdir -p -m 777 /mount/fps/tls_config/fps_db02
mkdir -p -m 777 /mount/fps/tls_config/fps_db02-fps_01

mkdir -p -m 777 /mount/fps/user_data
mkdir -p -m 777 /mount/fps/user_data/fps_db02
mkdir -p -m 777 /mount/fps/user_data/fps_db02-fps_01

mkdir -p -m 777 /mount/fps/yaml_config_files
mkdir -p -m 777 /mount/fps/yaml_config_files/fps_db02
mkdir -p -m 777 /mount/fps/yaml_config_files/fps_db02-fps_01

echo "---> Set permissions <---"
chmod -R 777 /mount/fps/

echo "---> DONE <---"
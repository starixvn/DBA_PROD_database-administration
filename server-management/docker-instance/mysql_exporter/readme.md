mysql exporter
===============

Purpose: deploy mysql exporter docker on PRO
Version: latest
Tools: Docker

Steps to install mysql exporter Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - mysql_exporter (1 - 1 vs mysql containers on host, so it should be named follow mysql container like exporter_chatbot_master)
    - /var/docker/mysql_exporter
        + .env
        + docker-compose.yml
        + makefile

  * Prepare Configuration
	- /var/docker/mysql_exporter/.env -- container definition

  * Check configuration
    - make config

  * Start container
    - make start

  * Stop container
    - make stop

  * Restart container
    - make restart

  * Check status
    - make status

  * For more options
    - make help
	
NOTE:
  * no need to create volume because no need to save data here (data will be store at prometheus container)
  * should config list exporters needing to get (to save CPU, mem, network)
  * create user on mysql server needed to monitor:
    - create user 'vngrafana'@'%' identified by '' WITH MAX_USER_CONNECTIONS 3;
    - GRANT PROCESS, REPLICATION CLIENT, SELECT ON . TO 'vngrafana'@'%';
  * use 2 networks in this container (1 is the network of mysql - needed to monitor, 1 is network monitoring - same as network of prometheus)
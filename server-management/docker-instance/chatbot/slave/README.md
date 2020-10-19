Chatbot - MySQL Server
===============

Purpose: to perform chatbox-master MySQL databases
Role: Master
Version: 8.0.20
Tools: Docker
Server: 10.40.40.185

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - chatbox_master
    - mysql-container map to /var/docker/chatbot_slave
        + .env
        + mysql.env
        + docker-compose.yml
        + makefile
        + log/
        + conf.d/

    - volume map to /volumes/chatbot_slave
        + data

  * Prepare Configuration
    - mysql-container/.env -- container definition
    - mysql-container/mysql.env -- mysql environments at starting up
    - mysql-container/conf.d/custom-mysql.cnf -- mysqld configuration

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
	
  * Steps
    - check config files /etc/mysql/mysql.conf.d/mysqld.cnf /var/docker/chatbot_slave/conf.d/custom-mysql.cnf
	- mkdir /var/docker/chatbot_slave/log/
	- chmod 777 -R /var/docker/chatbot_slave/log/
	- docker network create -d bridge chatbot_network
	- docker volume create --driver local --opt type=none --opt device=/volumes/chatbot_slave/data --opt o=bind chatbot_data
	- use a snapshot of slave to build new slave:
		connect to current chatbot_slave:
			stop slave;
			show slave status \G; #store master_log_file and master_log_pos for replication
		systemctl stop mysql.service
		cp -r /var/lib/mysql/* /volumes/chatbot_slave/data
		mv /volumes/chatbot_slave/data/auto.cnf /volumes/chatbot_slave/data/auto.cnf.bk
	- cd /var/docker/chatbot_slave
	- make start
	- config replication
		connect to chatbot_slave in docker
		reset slave
		CHANGE MASTER TO MASTER_HOST='10.40.40.184',  MASTER_PORT=3306, MASTER_USER='rpl_user', MASTER_PASSWORD='', MASTER_LOG_FILE='<master_log_file>', MASTER_LOG_POS=<master_log_pos> FOR CHANNEL 'pro_chatbot';
		start slave for channel 'pro_chatbot';
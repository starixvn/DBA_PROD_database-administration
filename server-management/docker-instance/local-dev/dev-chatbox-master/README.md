DEV-Chatbot - MySQL Server
===============

Purpose: to perform chatbox-master MySQL databases
Role: Master
Version: 8.0.20
Tools: Docker
Server: 10.18.200.228

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - chatbox-master-dev
    - mysql-container map to /var/docker/chatbox-master-dev
        + .env
        + mysql.env
        + docker-compose.yml
        + makefile
        + logs/
        + conf.d/

    - volume map to /volumes/chatbox-master-dev
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
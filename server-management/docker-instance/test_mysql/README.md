Pontus - MySQL Server
===============

Purpose: to perform admin's tasks for MySQL databases
Role: Standalone
Version: 8.0.20
Tools: Docker
Server: 10.40.40.185

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - test_mysql
    - mysql-container map to /var/docker/test_mysql
        + .env
        + mysql.env
        + docker-compose.yml
        + makefile

    - volume map to /volumes/novacash
        + data
        + logs
        + conf.d

  * Prepare Configuration
    - mysql-container/.env -- container definition
    - mysql-container/mysql.env -- mysql environments at starting up
    - volume/conf.d/custom-mysql.cnf -- mysqld configuration

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
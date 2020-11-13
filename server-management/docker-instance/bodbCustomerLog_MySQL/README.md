customerloguat - MySQL Server
===============

Purpose: to perform customerLog on MySQL databases
Role: UAT
Version: 8.0.20
Tools: Docker

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - customerloguat
    - mysql-container map to /var/docker/customerloguat
        + .env
        + mysql.env
        + docker-compose.yml
        + makefile

    - volume map to /volumes/customerloguat
        + data
        + logs
        + conf.d

  * Prepare Configuration
    - docker volume create --driver local --opt type=none --opt device=/volumes/customerloguat/data --opt o=bind customerloguat_data
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

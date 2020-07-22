NovaCash - MySQL Server
===============

Purpose: to pull data from Licensee MySQL databases to KBT
Role: Slave - Replicated Server
Version: 8.0.20
Tools: Docker

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - novacash
    - mysql-container map to /var/docker/novacash
        + .env
        + mysql.env
        + docker-compose.yml
        + makefile
        + init.d (folder if any)

    - volume map to /volumes/novacash
        + data
        + logs
        + conf.d

  * Prepare Configuration
    - docker volume create --driver local --opt type=none --opt device=/volumes/novacash/data --opt o=bind novacash_data
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
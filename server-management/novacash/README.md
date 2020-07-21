NovaCash - MySQL Server
=======================

Purpose: to pull data from Licensee MySQL databases to KBT
Role: Slave - Replicated Server
Version: 8.0.20
Tools: Docker

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder <novacash>
    - container
        + .env
        + mysql.env
        + docker-compose.yml
        + makefile
        + init.d (folder if any)

    - volume - <path_to_store?>
        + data
        + logs
        + conf.d

  * Prepare Configuration
    - ./container/.env -- container definition
    - ./container/mysql.env -- mysql environments at starting up
    - ./volume/conf.d/custom-mysql.cnf -- mysqld configuration

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
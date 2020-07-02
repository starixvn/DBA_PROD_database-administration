NovaCash - MySQL Server
========================

    - Purpose: to pull data from Licensee MySQL databases to KBT.
    - Role: Slave - Replicated Server
    - Version: 8.0.20
    - Tools: Docker

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component;

  * Prepare Configuration
    - ./.env -- container definition
    - ./mysql.env -- mysql environments with docker start up
    - ./conf.d/mysql.cnf -- mysqld configuration
  * Check container configuration

    - docker-compose config

  * Build mysql image;
    - docker-compose build --no-cache

  * Run mysql container;
    - docker-compose up -d

  * Check status
    - docker-compose logs
    - docker-compose ps
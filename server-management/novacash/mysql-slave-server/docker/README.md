NovaCash - MySQL Server
========================

    - Purpose: To pull data from Licensee MySQL databases to KBT
    - Role: Slave - Replicated Server
    - Version: 8.0.20
    - Tools: Docker

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component

  * Prepare Configuration
    - .env -- container definition
    - mysql.env -- mysql environments with container start up
    - conf.d/mysql.cnf -- mysqld setting values    

  * Create data volume to store NovaCash databases
    - docker volume create --driver local --opt type=none --opt device=/path/to/store --opt o=bind mysql-novacash-data

  * Check container configuration

    - docker-compose config

  * Build mysql image
    - docker-compose build

  * Run mysql container
    - docker-compose up -d

  * Check status
    - docker-compose logs
    - docker-compose ps
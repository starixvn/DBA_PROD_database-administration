LOCAL-Chatbot - MySQL Server
===============

Purpose: to perform chatbox-master MySQL databases
Role: Master/Slave
Version: 8.0.20
Tools: Docker with Swarm mode
Servers: 
    - Manager   : 10.18.200.228 - master role
    - Worker    : 10.18.200.229 - slave role

Steps to install MySQL with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Install Overlay network
  * Initialize Swarm mode between manager vs worker servers
  * Structure folder - chatbox-swarm on manager server
    - Swarm-folder map to /var/docker/chatbox-swarm
        + docker-compose-master.yml
        + docker-compose-slave.yml

  * Structure folder - chatbox-matser-local on manager server
    - mysql-container map to /var/docker/chatbox-master-local
        + logs/
        + conf.d/

    - volume map to /volumes/chatbox-master-local
        + data

  * Structure folder - chatbox-slave-local on worker server
    - mysql-container map to /var/docker/chatbox-slave-local
        + logs/
        + conf.d/

    - volume map to /volumes/chatbox-slave-local
        + data

  * Prepare Configuration on master server
    - mysql-container/conf.d/mysql.cnf -- mysqld configuration

  * Prepare Configuration on slave server
    - mysql-container/conf.d/mysql.cnf -- mysqld configuration

  * On Manager server - chatbox-swarm folder
  * Start service master
    - docker deploy --compose-file docker-compose-master.yml local
  
  * Start service slave
    - docker deploy --compose-file docker-compose-slave.yml local

  * Check status master/slave containers
    - docker service ls

  * Stop servive containers
    - docker service rm chatbox_master
    - docker service rm chatbox_slave

  * Restart servive containers
    - docker service update chatbox_master
    - docker service update chatbox_slave
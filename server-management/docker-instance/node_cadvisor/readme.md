node exporter and cadvisor
===============

Purpose: deploy mysql exporter docker on PRO
Version: latest
Tools: Docker

Steps to install node exporter and cadvisor Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - node_cadvisor 
    - /var/docker/node_cadvisor
        + .env
        + docker-compose.yml
        + makefile

  * Prepare Configuration
	- /var/docker/node_cadvisor/.env -- container definition

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
  * should config list exporters needing to get (to save CPU, mem, network)
  * redis is requested by cadvisor
  * could build image for 3 of these containers (cadvisor, redis, node exporter)
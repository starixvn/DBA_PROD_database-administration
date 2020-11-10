prometheus
===============

Purpose: deploy prometheus docker on PRO
Version: v2.21.0
Tools: Docker

Steps to install prometheus Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - prometheus
    - /var/docker/prometheus
        + .env
        + docker-compose.yml
		+ prometheus.yml
        + makefile

  * Prepare Configuration
	- /var/docker/prometheus/.env -- container definition

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
  * scrape_interval:     5s # Set the scrape interval to every 5 seconds. Default is every 1 minute.
  * prometheus.yml is file to config and define job, instance... to monitor
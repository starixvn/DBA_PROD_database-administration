grafana
===============

Purpose: deploy grafana docker on PRO
Version: 7.0.6
Tools: Docker

Steps to install grafana Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - grafana
    - /var/docker/grafana
        + .env
        + docker-compose.yml
        + makefile
		+ grafana.ini

    - volume map to /volumes/grafana
        + data:/var/lib/grafana
		+ grafana.ini:/etc/grafana/grafana.ini

  * Prepare Configuration
    - docker volume create --driver local --opt type=none --opt device=/volumes/grafana/data --opt o=bind grafana_data
    - cp /var/docker/grafana/grafana.ini /volumes/grafana/
	- /var/docker/grafana/.env -- container definition

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
	

Steps to move grafana Docker to another ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - grafana
    - /var/docker/grafana
        + .env
        + docker-compose.yml
        + makefile
		+ grafana.ini
		
    - volume map to /volumes/grafana
        + data:/var/lib/grafana
		+ grafana.ini:/etc/grafana/grafana.ini
		
  * Prepare Configuration
    - docker volume create --driver local --opt type=none --opt device=/volumes/grafana/data --opt o=bind grafana_data
	- scp [user]@[oldserver]:/volumes/grafana/data /volumes/grafana/data/
    - scp [user]@[oldserver]:/volumes/grafana/grafana.ini /volumes/grafana/
	- /var/docker/grafana/.env -- container definition

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
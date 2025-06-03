Rocketchat - Mongo DB
===============

Purpose: deploy Mongo DB docker for rocketchat on PRO
Version: 7.0.18
Tools: Docker

Steps to install Mongo DB with Docker on ubuntu server
---------------------------------------------------

  * Install [Docker Engine] vs [docker-compose] component
  * Structure folder - rocketchat
    - MongoDB-container map to /var/docker/rocketchat
        rocketchat/
        ├── config/
        │   ├── mongod.conf
        │   └── replica.key
        ├── log/
        │   ├── owp_rocketchat2/
        │   └── owp_rocketchat_primary/
        ├── yaml_config_files/
        │   └── mongo-scripts/
        │       └── mongodb_rs_init.sh
        ├── .env
        └── docker-compose.yml

    - volume map to /volumes/rocketchat
        rocketchat/
        ├── data/
        │   ├── backup/
        │   ├── owp_rocketchat2/
        │   └── owp_rocketchat_primary/

  * Prepare Configuration 
      - mongodb-container/yaml_config_files/ -- container definition 
      - mongodb-container/config/mongod.conf -- mongo configuration
      - mongodb-container/config/replica.key -- mongo replicate setting

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
    

    ** Steps run deploy
    
    - Prepare/ create folder,file
      + cd /var/docker
      + mkdir rocketchat
      + chmod 777 rocketchat/
      + mkdir -p {config,log,yaml_config_files}
      + cd /volumes
      + mkdir rocketchat
      + chmod -R 777 rocketchat/
      + cd /rocketchat
      + mkdir data
      + cd data
      + mkdir  -p {config,owp_rocketchat_primary,owp_rocketchat2}
      + nano mongodb_rs_init.sh
      + chmod +x mongodb_rs_init.sh
      + mkdir -p /var/docker/rocketchat/log/{owp_rocketchat_primary,owp_rocketchat2}
      + nano /var/docker/rocketchat/config/mongod.conf
      + openssl rand -base64 756 > /var/docker/config/replica.key
      + chmod 400 /var/docker/config/replica.key
      + chown 999:999 /var/docker/config/replica.key

    - Run starts the container
      + docker network create owp-rocketchat-network
      + docker pull mongo:7.0.18
      + docker-compose up -d

    - Create a user in MongoDB
      + connect to owp_rocketchat:  docker exec -it owp_rocketchat bash
      + connection string to db: mongosh "mongodb://admin:xxxxxx@10.40.40.33:16601/rocketchat?replicaSet=dbrs&directConnection=true&readPreference=primaryPreferred&authSource=admin"
      + run create user:

          use admin

          db.createUser({
            user: 'rkc_owp',
            pwd: 'xxxxxx',
            roles: [
              { role: 'readWrite', db: 'rocketchat' },
              { role: 'clusterMonitor', db: 'admin' }
            ]
          })

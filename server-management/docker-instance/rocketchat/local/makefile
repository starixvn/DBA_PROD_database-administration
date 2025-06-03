help:
	echo "make [config | status | start | restart | stop | runit | logs] options."

config:
	docker-compose config

status:
	docker-compose ps --all

start:
	docker-compose up -d

restart:
	docker-compose down
	docker-compose up -d

runit:
	docker-compose up

stop:
	docker-compose down

logs:
	docker-compose logs


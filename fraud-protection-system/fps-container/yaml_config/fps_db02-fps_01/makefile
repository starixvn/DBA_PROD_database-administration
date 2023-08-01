help:
	echo "make [config | status | start | restart | stop | logs] options."

config:
	docker-compose config

status:
	docker-compose ps --all

start:
	docker-compose run --rm createdir
	docker-compose --compatibility up -d mssql_fps_db02-fps_01

restart:
	docker-compose --compatibility down
	docker-compose --compatibility up -d mssql_fps_db02-fps_01

stop:
	docker-compose --compatibility down

logs:
	docker-compose logs

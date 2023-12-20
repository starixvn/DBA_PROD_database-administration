help:
	echo "make [config | status | start | restart | stop | logs] options."

config:
	docker-compose config

status:
	docker-compose ps --all

start:
	docker-compose run --rm createdir
	docker-compose --compatibility up -d mssql_fps_db02
	chown -R 10001:0 /mount/fps/user_data/fps_db02/

restart:
	docker-compose --compatibility down
	docker-compose --compatibility up -d mssql_fps_db02
	chown -R 10001:0 /mount/fps/user_data/fps_db02/

stop:
	docker-compose --compatibility down

logs:
	docker-compose logs

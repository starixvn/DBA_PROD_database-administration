sqlcmd -U vnJoe -P r4g95x -S DBTrans  -d IPDB   -i DB_IPDB_After.sql
sqlcmd -U vnJoe -P r4g95x -S DB05     -d IPDB   -i DB_IPDB_After.sql
sqlcmd -U vnJoe -P r4g95x -S DB05BK1  -d IPDB   -i DB_IPDB_After.sql
sqlcmd -U vnJoe -P r4g95x -S DBCust   -d IPDB   -i DB_IPDB_After.sql 
sqlcmd -U vnJoe -P r4g95x -S DBSITEC1 -d IPDB   -i DB_IPDB_After.sql 
sqlcmd -U vnJoe -P r4g95x -S DBSITEC2 -d IPDB   -i DB_IPDB_After.sql 
sqlcmd -U vnJoe -P r4g95x -S DBSITEC3 -d IPDB   -i DB_IPDB_After.sql 

sqlcmd -U vnJoe -P r4g95x -S DB062    -d bodb02 -i DB_bodb02_After.sql
sqlcmd -U vnJoe -P r4g95x -S DB061    -d bodb02 -i DB_bodb02_After.sql
sqlcmd -U vnJoe -P r4g95x -S DBKULC1  -d bodb02 -i DB_bodb02_After.sql
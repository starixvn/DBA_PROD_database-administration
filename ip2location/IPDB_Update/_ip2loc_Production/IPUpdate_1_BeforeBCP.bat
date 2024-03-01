sqlcmd -U vnJoe -P r4g95x -S DBTrans  -d IPDB   -i DB_IPDB_Before.sql
sqlcmd -U vnJoe -P r4g95x -S DB05     -d IPDB   -i DB_IPDB_Before.sql
sqlcmd -U vnJoe -P r4g95x -S DB05BK1  -d IPDB   -i DB_IPDB_Before.sql
sqlcmd -U vnJoe -P r4g95x -S DBCust   -d IPDB   -i DB_IPDB_Before.sql 
sqlcmd -U vnJoe -P r4g95x -S DBGRP01L -d IPDB   -i DB_IPDB_Before.sql 
sqlcmd -U vnJoe -P r4g95x -S DBGRP02L -d IPDB   -i DB_IPDB_Before.sql 
sqlcmd -U vnJoe -P r4g95x -S DBGRP03L -d IPDB   -i DB_IPDB_Before.sql 

sqlcmd -U vnJoe -P r4g95x -S DB062    -d bodb02 -i DB_bodb02_Before.sql
sqlcmd -U vnJoe -P r4g95x -S DB061    -d bodb02 -i DB_bodb02_Before.sql
sqlcmd -U vnJoe -P r4g95x -S DBTP10C  -d bodb02 -i DB_bodb02_Before.sql

sqlcmd -U vnJoe -P r4g95x -S DBOddsN2 -d DBIP   -i DBOdds_Before.sql

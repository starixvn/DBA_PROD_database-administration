bcp TEMP_IP             IN bcp_IPTable.csv        -S DB062   -U vnJoe -P r4g95x -d bodb02 -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DB061   -U vnJoe -P r4g95x -d bodb02 -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DBTP10C -U vnJoe -P r4g95x -d bodb02 -c -tv!x -b 100000

bcp TEMP_IPTable_Mini   IN bcp_IPTable_Mini.csv   -S DBTrans -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DBTrans -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IPTable_Mini   IN bcp_IPTable_Mini.csv   -S DB05    -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DB05    -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IPTable_Mini   IN bcp_IPTable_Mini.csv   -S DB05BK1 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DB05BK1 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IPTable_Mini   IN bcp_IPTable_Mini.csv   -S DBCust  -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DBCust  -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IPTable_Denied IN bcp_IPTable_Denied.csv -S DBCust   -U vnJoe -P r4g95x -d IPDB  -c -tv!x -b 100000

bcp TEMP_IPTable_Mini   IN bcp_IPTable_Mini.csv   -S DBSITEC1 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DBSITEC1 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IPTable_Mini   IN bcp_IPTable_Mini.csv   -S DBSITEC2 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DBSITEC2 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IPTable_Mini   IN bcp_IPTable_Mini.csv   -S DBSITEC3 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000
bcp TEMP_IP             IN bcp_IPTable.csv        -S DBSITEC3 -U vnJoe -P r4g95x -d IPDB   -c -tv!x -b 100000

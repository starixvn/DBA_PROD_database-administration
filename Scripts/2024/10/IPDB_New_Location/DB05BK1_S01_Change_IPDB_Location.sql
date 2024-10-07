/*<info serverAlias="DB05BK1-master></info>*/
/*  
	Created by: 20241007@Sol
	Task: change IPDB location
	DB: DB05BK1-master
*/

USE master;

GO

ALTER DATABASE IPDB MODIFY FILE ( NAME = ipdb_Data, FILENAME = 'H:\USER_DB\IPDB\IPDB.MDF')
ALTER DATABASE IPDB MODIFY FILE ( NAME = ipdb_Log, FILENAME = 'H:\USER_DB\IPDB\IPDB_1.LDF')

GO
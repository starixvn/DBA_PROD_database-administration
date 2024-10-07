/*<info serverAlias="DB05-master></info>*/
/*  
	Created by: 20241007@Sol
	Task: change IPDB location
	DB: DB05-master
*/

---### Take db OFFLINE to prepare moving physical files
USE master;

GO

ALTER DATABASE IPDB SET OFFLINE WITH ROLLBACK IMMEDIATE;

GO

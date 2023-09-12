/*
	Created: 20230801@Sol
	Task: change owner, mapping user
	DB: 10.40.40.33,16401-master
*/

USE FPS_LOG;

GO

select 'EXEC sp_change_users_login ''update_one'',' + name + ',' + name
from sys.sysusers 
where issqlrole = 0 
 and hasdbaccess = 1
 and uid > 1 -- exclude dbo

go

EXEC FPS_LOG.dbo.sp_changedbowner 'sa';
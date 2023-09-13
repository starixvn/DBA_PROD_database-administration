/*
	Created: 20230912@Sol
	Task: change owner, mapping user
	DB: 10.40.40.33,16401-master
*/

/*

FPS_ADMIN
FPS_BODB_TRANS
FPS_DEV
FPS_EVI
FPS_MiddleService
FPS_RPT

*/

USE xxxx;

GO

select 'EXEC sp_change_users_login ''update_one'',' + name + ',' + name
from sys.sysusers 
where issqlrole = 0 
 and hasdbaccess = 1
 and uid > 1 -- exclude dbo

GO

--######################
EXEC sp_change_users_login xxxx

--######################

go

EXEC xxxx.dbo.sp_changedbowner 'sa';
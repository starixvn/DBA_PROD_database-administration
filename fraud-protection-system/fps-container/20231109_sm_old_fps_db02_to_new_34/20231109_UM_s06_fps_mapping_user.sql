/*
	Created: 20231026@Sol
	Task: change owner, mapping user
	DB: 10.40.40.34,16402-master
*/

USE FPS_DeviceFingerprint;

GO

select 'EXEC sp_change_users_login ''update_one'',' + name + ',' + name
from sys.sysusers 
where issqlrole = 0 
 and hasdbaccess = 1
 and uid > 1 -- exclude dbo

go

EXEC FPS_DeviceFingerprint.dbo.sp_changedbowner 'sa';

GO
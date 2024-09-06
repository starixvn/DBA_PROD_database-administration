/*<info serverAlias="DBGRP01N1-master></info>*/
/*  
	Created by: 20240829@Sol
	Task: add vnteam to linked server
	DB: DBGRP01N1-master
*/

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam', @useself = N'True'

GO

--- REVERT ---
/*

EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam'

*/
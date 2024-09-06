/*<info serverAlias="DB062-master></info>*/
/*  
	Created by: 20240829@Sol
	Task: add vnteam to linked server
	DB: DB062-master
*/

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DB03', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DB05BK1', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBCASINOADMINCS\ADMIN', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBCTG', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBDISTRM', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBDW2', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBSPARE', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS02', @locallogin = N'vnteam', @useself = N'True'

GO

--- REVERT ---
/*

EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DB03', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DB05BK1', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBCASINOADMINCS\ADMIN', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBCTG', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBDISTRM', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBDW2', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBSPARE', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS02', @locallogin = N'vnteam'


*/
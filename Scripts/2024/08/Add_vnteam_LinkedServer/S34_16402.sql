/*<info serverAlias="10.40.40.34,16402-master></info>*/
/*  
	Created by: 20240829@Sol
	Task: add vnteam to linked server
	DB: 10.40.40.34,16402-master
*/

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'_DBFRAUD_', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'_FPS_DB02_FPS_01_', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'FPS_LINUX33', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'FPSADMIN', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'FPSARC', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'FPSCR', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'FPSDEV', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'FPSRPT', @locallogin = N'vnteam', @useself = N'True'

GO

--- REVERT ---
/*

EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'_DBFRAUD_', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'_FPS_DB02_FPS_01_', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'FPS_LINUX33', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'FPSADMIN', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'FPSARC', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'FPSCR', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'FPSDEV', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'FPSRPT', @locallogin = N'vnteam'

*/
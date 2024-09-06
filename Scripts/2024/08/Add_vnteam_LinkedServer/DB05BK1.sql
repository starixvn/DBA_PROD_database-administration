/*<info serverAlias="DB05BK1-master></info>*/
/*  
	Created by: 20240829@Sol
	Task: add vnteam to linked server
	DB: DB05BK1-master
*/

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam', @useself = N'True'

GO

--- REVERT ---
/*

EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam'

*/
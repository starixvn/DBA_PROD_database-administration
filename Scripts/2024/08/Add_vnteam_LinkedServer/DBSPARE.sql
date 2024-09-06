/*<info serverAlias="DBSPARE-master></info>*/
/*  
	Created by: 20240829@Sol
	Task: add vnteam to linked server
	DB: DBSPARE-master
*/

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSABAPLAYARC', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSABAPLAYARC', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC1', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC1', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC2', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC2', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC3', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC3', @locallogin = N'vnteam', @useself = N'True'

GO

--- REVERT ---
/*

EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSABAPLAYARC', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSABAPLAYARC', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC1', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC1', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC2', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC2', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC3', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'MONDB_DBSITEC3', @locallogin = N'vnteam'

*/
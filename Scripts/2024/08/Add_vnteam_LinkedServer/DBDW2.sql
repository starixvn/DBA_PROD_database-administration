/*<info serverAlias="DBDW2-master></info>*/
/*  
	Created by: 20240829@Sol
	Task: add vnteam to linked server
	DB: DBDW2-master
*/

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBCASINO', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBCUST', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBDW_AWS', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBDW_KBT', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBDW_KL', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBFRAUD', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBPRO', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBSTAGING', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBSTAGINGKBT', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBUSERLOG', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'INFOSITE03', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'INFOSITE07', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'LICBOT', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_ALLPRODUCT', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_ALLPRODUCTUSD', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_LAPPERF', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_LAPSBPERF', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_MDXReport', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_MEMBER', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_ParlayRejectRate', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_TEAM', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS_VOIDSTAT', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SSAS03', @locallogin = N'vnteam', @useself = N'True'

GO

--- REVERT ---
/*

EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBCASINO', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBCUST', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBDW_AWS', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBDW_KBT', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBDW_KL', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBFRAUD', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBPRO', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBSTAGING', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBSTAGINGKBT', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBUSERLOG', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'INFOSITE03', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'INFOSITE07', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'LICBOT', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_ALLPRODUCT', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_ALLPRODUCTUSD', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_LAPPERF', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_LAPSBPERF', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_MDXReport', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_MEMBER', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_ParlayRejectRate', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_TEAM', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS_VOIDSTAT', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'SSAS03', @locallogin = N'vnteam'

*/
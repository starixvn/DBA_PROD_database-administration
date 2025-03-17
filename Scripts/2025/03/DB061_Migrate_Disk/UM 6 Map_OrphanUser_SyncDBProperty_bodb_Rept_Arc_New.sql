/*
	Task: Map orphan users in DB <> Login and update DB Property
		bodb_Report
		bodb_Archive
		
	Created on 20250317 by Daniel
	Run on DB061
*/

--1 Sync orphan users in DB
exec monDB.dbo.DBA_Sync_Orphan_User;
GO

--2- Sync DB Property:
/*
 --1- Check DB Property
 --2- Change Full Recovery MODE (0)
 --3- Change is_auto_update_stats_async_on (4)
 --4- Change is_trustworthy_on (0)
 --5- Change is_parameterization_forced (1)
 --6- Change is_broker_enabled (1)
 --7- Set COMPATIBILITY_LEVEL=150 (8)
 --8- Set owner db to 'sa'
USE [master]
GO
SELECT name,compatibility_level,recovery_model_desc,page_verify_option_desc
,is_auto_update_stats_async_on,is_trustworthy_on,is_parameterization_forced
,is_broker_enabled
FROM sys.databases
WHERE DB_NAME(database_id) IN('bodb_Report', 'bodb_Archive','bodb_Report_New', 'bodb_Archive_New')
ORDER BY 1
GO
*/
--> Change owner to sa
USE [master];
GO
EXEC [bodb_Report].dbo.sp_changedbowner @loginame = N'sa';
GO
EXEC [bodb_Archive].dbo.sp_changedbowner @loginame = N'sa';
GO


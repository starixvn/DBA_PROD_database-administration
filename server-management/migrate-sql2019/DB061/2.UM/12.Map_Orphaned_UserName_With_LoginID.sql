--SITDB05
-- 1.Sync Orphan USER
EXEC [MONDB].[dbo].[DBA_Sync_Orphan_USER]

-- 2.Check Orphaned USER
EXEC sp_MSForeachDB @commAND1='
 USE [?];
SELECT DB_NAME() [DBName],dp.name [USER_name]
    ,dp.type_desc [USER_type]
    ,isnull(sp.name,''Orhphaned!'') [login_name]
    ,sp.type_desc [login_type]
FROM sys.database_principals dp LEFT JOIN sys.server_principals sp
 ON (dp.sid = sp.sid)
WHERE dp.type in (''S'',''U'',''G'')
  AND dp.principal_id > 4
  AND dp.name not like ''##%''
ORDER BY sp.name;'
GO

-- 3.Gen Sync Script for Orphaned USER
USE tempdb;
CREATE TABLE #tmp_sync_cmd ([cmd] nvarchar(4000))
INSERT INTO #tmp_sync_cmd  
 EXEC sp_MSForeachDB @commAND1='
 USE [?];
 --IF DB_ID() > 4
 SELECT CMD = N'' USE [?];ALTER USER ['' + dp.name + N''] WITH LOGIN = ['' + dp.name + N''];''
 FROM sys.database_principals dp LEFT JOIN sys.server_principals sp
  ON (dp.sid = sp.sid)
 WHERE dp.type in (''S'',''U'',''G'')
   AND dp.principal_id > 4
   AND dp.name not like ''##%''
   AND dp.name not like ''MS_DataCollector%'' 
 ORDER BY sp.name;'
SELECT * FROM #tmp_sync_cmd;
DROP TABLE #tmp_sync_cmd;
GO

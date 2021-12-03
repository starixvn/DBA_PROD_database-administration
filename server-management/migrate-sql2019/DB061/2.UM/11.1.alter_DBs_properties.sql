/*
	Task - Upgrade SQL Server DB055 to 2019
		1- Check DB Property
		2- Change Full Recovery MODE (0)
		3- Change is_auto_update_stats_async_on (4)
		4- Change is_trustworthy_on (0)
		5- Change is_parameterization_forced (1)
		6- Change is_broker_enabled (1)
		7- Set COMPATIBILITY_LEVEL=150 (8)
		8- Set owner db to 'sa'
	Run on db055
*/

USE [master]
GO
-- 1- Check DB Property
SELECT name,compatibility_level,recovery_model_desc,page_verify_option_desc
,is_auto_update_stats_async_on,is_trustworthy_on,is_parameterization_forced
,is_broker_enabled
FROM sys.databases
WHERE database_id > 4
ORDER BY 1
GO

--ALTER DATABASE SCOPED CONFIGURATION

/*
  a.FULL Recovery Mode = 0
  b.is_auto_update_stats_async_on = 4
  c.is_trustworthy_on = 0
  d.is_parameterization_forced = 1
  e.is_broker_enabled = 1
  f.compatibility_level(100->150) = 8
*/

--2- Change Full Recovery MODE (0)
SELECT 'ALTER DATABASE [' + name +'] SET RECOVERY FULL WITH NO_WAIT;'
FROM sys.databases
WHERE database_id > 4 AND recovery_model=1
ORDER BY 1
GO

ALTER DATABASE [bodb_ACC] SET RECOVERY FULL WITH NO_WAIT;
ALTER DATABASE [bodb_OWP] SET RECOVERY FULL WITH NO_WAIT;
ALTER DATABASE [bodb_TGRS] SET RECOVERY FULL WITH NO_WAIT;

--3- Change is_auto_update_stats_async_on (4)
SELECT 'ALTER DATABASE [' + name +'] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;'
FROM sys.databases
WHERE database_id > 4 AND is_auto_update_stats_async_on=1
ORDER BY 1
GO

ALTER DATABASE [bodb_archive] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;
ALTER DATABASE [bodb_Licensee] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;
ALTER DATABASE [bodb_Report] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;
ALTER DATABASE [bodb02] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;

-- 4- Change is_trustworthy_on (0)
SELECT 'ALTER DATABASE [' + name +'] SET TRUSTWORTHY ON;'
FROM sys.databases
WHERE database_id > 4 AND is_trustworthy_on=1
ORDER BY 1
GO

-- 5- Change is_parameterization_forced (1)
SELECT 'ALTER DATABASE [' + name +'] SET PARAMETERIZATION FORCED;'
FROM sys.databases
WHERE database_id > 4 AND is_parameterization_forced=1
ORDER BY 1
GO

ALTER DATABASE [bodb02] SET PARAMETERIZATION FORCED;

-- 6- Change is_broker_enabled (1)
SELECT 'ALTER DATABASE [' + name + '] SET ENABLE_BROKER WITH NO_WAIT;'
FROM sys.databases
WHERE database_id > 4 AND is_broker_enabled=1
ORDER BY 1
GO

ALTER DATABASE [bodb02] SET ENABLE_BROKER WITH NO_WAIT;

-- 7- Set COMPATIBILITY_LEVEL=150 (8)
SELECT 'ALTER DATABASE [' + name +'] SET COMPATIBILITY_LEVEL = 150;'
FROM sys.databases
WHERE database_id > 4 AND compatibility_level < 150
ORDER BY 1
GO

ALTER DATABASE [bodb_ACC] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_archive] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_Licensee] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_OWP] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_Report] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_TGRS] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb02] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [LasDB_Archive] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [LogDB] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [LogPDB] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [MonDB] SET COMPATIBILITY_LEVEL = 150;

-- 8- Set owner db to 'sa'
select db.name as [Database Name], sp.name [SQL Login Name]
	, 'EXEC ['+db.name+'].dbo.sp_changedbowner @loginame = N''sa''' cmd
from sys.databases db 
	left join sys.server_principals sp on db.owner_sid = sp.sid
where sp.name <> 'sa'
GO

EXEC [bodb_archive].dbo.sp_changedbowner @loginame = N'sa'
EXEC [bodb02].dbo.sp_changedbowner @loginame = N'sa'
EXEC [bodb_Report].dbo.sp_changedbowner @loginame = N'sa'
EXEC [LasDB_Archive].dbo.sp_changedbowner @loginame = N'sa'
EXEC [bodb_ACC].dbo.sp_changedbowner @loginame = N'sa'
EXEC [bodb_Licensee].dbo.sp_changedbowner @loginame = N'sa'
EXEC [bodb_OWP].dbo.sp_changedbowner @loginame = N'sa'
EXEC [bodb_TGRS].dbo.sp_changedbowner @loginame = N'sa'
EXEC [MonDB].dbo.sp_changedbowner @loginame = N'sa'
EXEC [LogDB].dbo.sp_changedbowner @loginame = N'sa'
EXEC [LogPDB].dbo.sp_changedbowner @loginame = N'sa'

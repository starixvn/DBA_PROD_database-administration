/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: GET db properties
***/
USE [master]
GO
-- 1.Check DB Property
SELECT name,compatibility_level,recovery_model_desc,page_verify_option_desc
,is_auto_update_stats_async_on,is_trustworthy_on,is_parameterization_forced
,is_broker_enabled, state_desc
FROM sys.databases
WHERE database_id > 4 and state_desc=N'ONLINE'
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
select *
from (
	-- 1.a.Change Full Recovery MODE (0)
	SELECT 'ALTER DATABASE [' + name +'] SET RECOVERY FULL WITH NO_WAIT;' as cmd, 1 as Idx
	FROM sys.databases
	WHERE database_id > 4 AND recovery_model=1 and state_desc=N'ONLINE'
	union all

	-- 2.b.Change is_auto_update_stats_async_on (4)
	SELECT 'ALTER DATABASE [' + name +'] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;',2
	FROM sys.databases
	WHERE database_id > 4 AND is_auto_update_stats_async_on=1 and state_desc=N'ONLINE'
	union all

	-- 3.c.Change is_trustworthy_on (0)
	SELECT 'ALTER DATABASE [' + name +'] SET TRUSTWORTHY ON;',3
	FROM sys.databases
	WHERE database_id > 4 AND is_trustworthy_on=1 and state_desc=N'ONLINE'
	union all

	-- 4.d.Change is_parameterization_forced (1)
	SELECT 'ALTER DATABASE [' + name +'] SET PARAMETERIZATION FORCED;',4
	FROM sys.databases
	WHERE database_id > 4 AND is_parameterization_forced=1 and state_desc=N'ONLINE'
	union all

	-- 5.e.Change is_broker_enabled (1)
	SELECT 'ALTER DATABASE [' + name + '] SET ENABLE_BROKER WITH NO_WAIT;',5
	FROM sys.databases
	WHERE database_id > 4 AND is_broker_enabled=1 and state_desc=N'ONLINE'
	union all

	/** Compare first before Set Compatibility Level **/
	-- 6.f.Set COMPATIBILITY_LEVEL=150 (8)
	SELECT 'ALTER DATABASE [' + name +'] SET COMPATIBILITY_LEVEL = 150;',6
	FROM sys.databases
	WHERE database_id > 4 AND compatibility_level < 150 and state_desc=N'ONLINE'
) as t (cmd, idx)
order by idx

--TODO:
/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: SET db properties
***/
use master;
GO
ALTER DATABASE [bodb_ChatBot] SET RECOVERY FULL WITH NO_WAIT;
ALTER DATABASE [bodb_FraudSensor] SET RECOVERY FULL WITH NO_WAIT;
ALTER DATABASE [bodb_Ploutos] SET RECOVERY FULL WITH NO_WAIT;
ALTER DATABASE [bodb_LicenseeReport] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;
ALTER DATABASE [bodb02] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;
ALTER DATABASE [bodb_Licensee] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;
ALTER DATABASE [bodb_AGE] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;
ALTER DATABASE [bodb02] SET ENABLE_BROKER WITH NO_WAIT;
ALTER DATABASE [bodb_N88] SET ENABLE_BROKER WITH NO_WAIT;
ALTER DATABASE [MonDB] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_LicenseeReport] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_LicenseeReportArchive] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_PlaytechCS] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb02] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bk] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_3rdProduct] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_ChatBot] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_FraudSensor] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_Licensee] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_Ploutos] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_Summary] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_AGE] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [bodb_N88] SET COMPATIBILITY_LEVEL = 150;
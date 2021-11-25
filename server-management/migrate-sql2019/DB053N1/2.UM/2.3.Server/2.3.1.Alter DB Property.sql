USE [master]
GO
-- 1.Check DB Property
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

-- 2.a.Change Full Recovery MODE (0)
SELECT 'ALTER DATABASE [' + name +'] SET RECOVERY FULL WITH NO_WAIT;'
FROM sys.databases
WHERE database_id > 4 AND recovery_model=1
ORDER BY 1
GO

--TODO:
GO


-- 2.b.Change is_auto_update_stats_async_on (4)
SELECT 'ALTER DATABASE [' + name +'] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT;'
FROM sys.databases
WHERE database_id > 4 AND is_auto_update_stats_async_on=1
ORDER BY 1
GO

--TODO:
GO


-- 2.c.Change is_trustworthy_on (0)
SELECT 'ALTER DATABASE [' + name +'] SET TRUSTWORTHY ON;'
FROM sys.databases
WHERE database_id > 4 AND is_trustworthy_on=1
ORDER BY 1
GO

--TODO:
GO


-- 2.d.Change is_parameterization_forced (1)
SELECT 'ALTER DATABASE [' + name +'] SET PARAMETERIZATION FORCED;'
FROM sys.databases
WHERE database_id > 4 AND is_parameterization_forced=1
ORDER BY 1
GO

--TODO
GO

-- 2.e.Change is_broker_enabled (1)
SELECT 'ALTER DATABASE [' + name + '] SET ENABLE_BROKER WITH NO_WAIT;'
FROM sys.databases
WHERE database_id > 4 AND is_broker_enabled=1
ORDER BY 1
GO

--TODO:

GO

/** Compare first before Set Compatibility Level **/
-- 2.f.Set COMPATIBILITY_LEVEL=150 (8)
SELECT 'ALTER DATABASE [' + name +'] SET COMPATIBILITY_LEVEL = 150;'
FROM sys.databases
WHERE database_id > 4 AND compatibility_level < 150
ORDER BY 1
GO

--TODO:
GO


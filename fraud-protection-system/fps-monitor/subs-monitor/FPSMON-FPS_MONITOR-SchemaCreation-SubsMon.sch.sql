/*
	Creator:	20200310@Billy
	Task:		Schema for FPS subscribers monitoring - [Redmine: #112758]
	Server:		FPSMON.FPS_MONITOR
*/


SET NOCOUNT ON;
GO

--	BEGIN STEP 1:
--		Create schema
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	SCHEMA_ID('subs') IS NULL
BEGIN;
	EXECUTE	sys.sp_executesql N'\
CREATE SCHEMA subs AUTHORIZATION dbo;
';
	RAISERROR(N'Schema %s created', 0, 0, N'subs') WITH NOWAIT;
END;
GO

--	BEGIN STEP 2:
--		Create storage
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	FILEGROUP_ID('SUBS') IS NULL
BEGIN;
	ALTER DATABASE FPS_MONITOR ADD FILEGROUP SUBS;
	RAISERROR(N'Filegroup %s created', 0, 0, N'SUBS') WITH NOWAIT;
END;

IF	FILE_IDEX('FPS_MONITOR_SUBS') IS NULL
BEGIN;
	ALTER DATABASE FPS_MONITOR ADD FILE (
		NAME		= N'FPS_MONITOR_SUBS'
	,	FILENAME	= N'D:\FPS02\FPS_MONITOR\FPS_MONITOR_SUBS.ndf'
	,	SIZE		= 4MB
	,	FILEGROWTH	= 4MB
	,	MAXSIZE		= UNLIMITED
	) TO FILEGROUP SUBS;
	RAISERROR(N'File %s added to filegroup %s', 0, 0, N'FPS_MONITOR_SUBS', N'SUBS') WITH NOWAIT;
END;
GO


/*
	Creator:	20200310@Billy
	Task:		Schema for FPS file monitoring - [Redmine: #112758]
	Server:		FPSMON-FPS_MONITOR
*/


SET NOCOUNT ON;
GO

--	BEGIN STEP 1:
--		Create schema
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	SCHEMA_ID('_file') IS NULL
BEGIN;
	EXECUTE	sys.sp_executesql N'\
CREATE SCHEMA _file AUTHORIZATION dbo;
';
	RAISERROR(N'Schema %s created', 0, 0, N'_file') WITH NOWAIT;
END;
GO

--	BEGIN STEP 2:
--		Create storage
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	FILEGROUP_ID('_FILE') IS NULL
BEGIN;
	ALTER DATABASE FPS_MONITOR ADD FILEGROUP _FILE;
	RAISERROR(N'Filegroup %s created', 0, 0, N'_FILE') WITH NOWAIT;
END;

IF	FILE_IDEX('FPS_MONITOR_FILE') IS NULL
BEGIN;
	ALTER DATABASE FPS_MONITOR ADD FILE (
		NAME		= N'FPS_MONITOR_FILE'
	,	FILENAME	= N'D:\FPS02\FPS_MONITOR\FPS_MONITOR_FILE.ndf'
	,	SIZE		= 4MB
	,	FILEGROWTH	= 4MB
	,	MAXSIZE		= UNLIMITED
	) TO FILEGROUP _FILE;
	RAISERROR(N'File %s added to filegroup %s', 0, 0, N'FPS_MONITOR_FILE', N'_FILE') WITH NOWAIT;
END;
GO


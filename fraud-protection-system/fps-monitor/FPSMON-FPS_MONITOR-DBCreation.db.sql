/*
	Creator:	20200309@Billy
	Task:		FPS_MONITOR database creation script - [Redmine: #112758]
	Server:		FPSMON
*/

SET NOCOUNT ON;
GO

--	BEGIN STEP :
--		Create database
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	master;

EXECUTE	sys.xp_create_subdir N'D:\FPS02\FPS_MONITOR';

CREATE DATABASE	FPS_MONITOR
ON	PRIMARY (
		NAME		= N'FPS_MONITOR'
	,	FILENAME	= N'D:\FPS02\FPS_MONITOR\FPS_MONITOR.mdf'
	,	SIZE		= 4MB
	,	FILEGROWTH	= 4MB
	,	MAXSIZE		= UNLIMITED
	)
,	FILEGROUP DATA DEFAULT (
		NAME		= N'DATA'
	,	FILENAME	= N'D:\FPS02\FPS_MONITOR\FPS_MONITOR_Data.ndf'
	,	SIZE		= 4MB
	,	FILEGROWTH	= 4MB
	,	MAXSIZE		= UNLIMITED
	)
,	FILEGROUP IDX (
		NAME		= N'IDX'
	,	FILENAME	= N'D:\FPS02\FPS_MONITOR\FPS_MONITOR_Idx.ndf'
	,	SIZE		= 4MB
	,	FILEGROWTH	= 4MB
	,	MAXSIZE		= UNLIMITED
	)
	LOG ON (
		NAME		= N'FPS_MONITOR_Log'
	,	FILENAME	= N'D:\FPS02\FPS_MONITOR\FPS_MONITOR_Log.ldf'
	,	SIZE		= 128MB
	,	FILEGROWTH	= 128MB
	,	MAXSIZE		= UNLIMITED
	);

ALTER AUTHORIZATION ON DATABASE::FPS_MONITOR TO sa;
GO


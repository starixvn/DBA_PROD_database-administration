/*
	Creator:	20200310@Billy
	Task:		Create metadata tables - [Redmine: #112758]
	Server:		FPSMON.FPS_MONITOR
*/


SET NOCOUNT ON;
GO


--	BEGIN STEP :
--		Servers table
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	OBJECT_ID('dbo.Servers') IS NULL
BEGIN;
	CREATE TABLE	dbo.Servers (
						ServerName		NVARCHAR(128)
					,	isActive		BIT
					,	CONSTRAINT	PK_Servers PRIMARY KEY CLUSTERED (
										ServerName
									) ON IDX
					) ON DATA;

	RAISERROR(N'Table %s created', 0, 0, N'dbo.Servers') WITH NOWAIT;
END;
GO


--	BEGIN STEP :
--		Databases table
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	OBJECT_ID('dbo.Databases') IS NULL
BEGIN;
	CREATE TABLE	dbo.Databases (
						DatabaseId		INT					IDENTITY(1, 1)
					,	ServerName		NVARCHAR(128)
					,	DatabaseName	NVARCHAR(128)
					,	isActive		BIT
							CONSTRAINT	DF_Databases_isActive DEFAULT (0)
					,	CONSTRAINT	PK_Databases PRIMARY KEY NONCLUSTERED (
										DatabaseId
									) ON IDX
					) ON DATA;

	CREATE CLUSTERED INDEX	CIX_Databases ON dbo.Databases (
								DatabaseName
							,	ServerName
							) ON DATA;

	RAISERROR(N'Table %s created', 0, 0, N'dbo.Databases') WITH NOWAIT;
END;
GO
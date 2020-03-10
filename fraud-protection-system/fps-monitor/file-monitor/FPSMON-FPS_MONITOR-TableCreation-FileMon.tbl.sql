/*
	Creator:	20200310@Billy
	Task:		Create table for file monitoring - [Redmine: #112758]
	Server:		FPSMON.FPS_MONITOR
*/


SET NOCOUNT ON;
GO

--	BEGIN STEP 1:
--		Filegroups table
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	OBJECT_ID('_file.Filegroups') IS NULL
BEGIN;
	CREATE TABLE	_file.Filegroups (
						FilegroupId		INT					IDENTITY(1, 1)
					,	DatabaseId		INT
					,	FilegroupName	NVARCHAR(128)
					,	CONSTRAINT	PK_Filegroups PRIMARY KEY NONCLUSTERED (
										FilegroupId
									) ON _FILE
					) ON _FILE;

	CREATE UNIQUE CLUSTERED INDEX	CIX_Filegroups ON _file.Filegroups (
								DatabaseId
							,	FilegroupName
							) ON _FILE;

	RAISERROR(N'Table %s created', 0, 0, N'_file.Filegroups') WITH NOWAIT;
END;
GO


--	BEGIN STEP 2:
--		FileSizeCaptured table
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	OBJECT_ID('_file.FileSizeCaptured') IS NULL
BEGIN;
	CREATE TABLE	_file.FileSizeCaptured (
						CapturedTime	DATETIME
					,	FilegroupId		INT
					,	SizeKB			BIGINT
					,	CONSTRAINT	PK_FileSizeCaptured PRIMARY KEY CLUSTERED (
										CapturedTime
									,	FilegroupId
									) WITH (DATA_COMPRESSION = PAGE) ON _FILE
					) ON _FILE;

	CREATE NONCLUSTERED INDEX	IX_FileSizeCaptured ON _file.FileSizeCaptured (
								FilegroupId
							,	CapturedTime
							) INCLUDE (SizeKB) WITH (DATA_COMPRESSION = PAGE) ON _FILE;

	RAISERROR(N'Table %s created', 0, 0, N'_file.FileSizeCaptured') WITH NOWAIT;
END;
GO
/*
	Creator:	20200310@Billy
	Task:		Create table for subscribers monitoring - [Redmine: #112758]
	Server:		FPSMON.FPS_MONITOR
*/


SET NOCOUNT ON;
GO

--	BEGIN STEP 1:
--		Tables table
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	OBJECT_ID('subs.Tables') IS NULL
BEGIN;
	CREATE TABLE	subs.Tables (
						TableId			INT					IDENTITY(1, 1)
					,	TableName		NVARCHAR(128)
					,	CONSTRAINT	PK_Tables PRIMARY KEY NONCLUSTERED (
										TableId
									) ON SUBS
					) ON SUBS;

	CREATE UNIQUE CLUSTERED INDEX	CIX_Tables ON subs.Tables (
								TableName
							) ON SUBS;

	RAISERROR(N'Table %s created', 0, 0, N'subs.Tables') WITH NOWAIT;
END;
GO


--	BEGIN STEP 2:
--		Subscribers table
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	OBJECT_ID('subs.Subscribers') IS NULL
BEGIN;
	CREATE TABLE	subs.Subscribers (
						SubscriberId	INT
					,	SubscriberName	NVARCHAR(128)
					,	ServerName		NVARCHAR(128)
					,	DatabaseName	NVARCHAR(128)
					,	isActive		BIT
					,	CONSTRAINT	PK_Subscribers PRIMARY KEY NONCLUSTERED (
										SubscriberId
									) ON SUBS
					) ON SUBS;

	CREATE UNIQUE CLUSTERED INDEX	CIX_Subscribers ON subs.Subscribers (
								SubscriberName
							) ON SUBS;

	RAISERROR(N'Table %s created', 0, 0, N'subs.Subscribers') WITH NOWAIT;
END;
GO

--	BEGIN STEP 3:
--		SubscribersRowcount table
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	FPS_MONITOR;

IF	OBJECT_ID('subs.SubscribersRowcount') IS NULL
BEGIN;
	CREATE TABLE	subs.SubscribersRowcount (
						CapturedTime	DATETIME
					,	SubscriberId	INT
					,	TableId			INT
					,	Rows			BIGINT
					,	CONSTRAINT	PK_SubscribersRowcount PRIMARY KEY CLUSTERED (
										CapturedTime
									,	SubscriberId
									,	TableId
									) WITH (DATA_COMPRESSION = PAGE) ON SUBS
					) ON SUBS;

	CREATE NONCLUSTERED INDEX	IX_SubscribersRowcount ON subs.SubscribersRowcount (
								SubscriberId
							,	TableId
							,	CapturedTime
							) INCLUDE (Rows) WITH (DATA_COMPRESSION = PAGE) ON SUBS;

	RAISERROR(N'Table %s created', 0, 0, N'subs.SubscribersRowcount') WITH NOWAIT;
END;
GO
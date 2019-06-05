SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ArchiveDR_CheckRowcount
AS
/*
	Creator:	20190605@Billy
	Task:		Check bodb_Archive tables' rowcount - [Redmine: #00000]
	Database:	DBARC.bodb_Archive
		
	Revisions:
		- 20190605@Billy:	DB061 Migration - [Redmine: #111418]
*/
BEGIN;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF	DB_ID('_This_MNL_DR_site') IS NULL
	BEGIN;
		RAISERROR('This SP can only be run on MNL environment.', 16, 1) WITH NOWAIT;
		RETURN -1;
	END;

	DECLARE	@Server			NVARCHAR(128)
		,	@Database		NVARCHAR(128)
		,	@Table			NVARCHAR(128)
		,	@WinLostDate	DATETIME
		;

	CREATE TABLE	#StandbyRowcount (
						DatabaseName	NVARCHAR(128)
					,	TableName		NVARCHAR(128)
					,	WinLostDate		DATETIME
					,	RowCnt			BIGINT
					,	TimeType		VARCHAR(10)
					);

	CREATE TABLE	#ActiveRowcount (
						DatabaseName	NVARCHAR(128)
					,	TableName		NVARCHAR(128)
					,	WinLostDate		DATETIME
					,	RowCnt			BIGINT
					,	TimeType		VARCHAR(10)
					);

	-- Truncate rowcount table --
	TRUNCATE TABLE	dbo.Task_ArchiveHA_RowcountResult;


	SELECT	@Server = N'MNL' + @@SERVERNAME;

	--	BEGIN STEP 1:
	--	Compare rowcount based on system dynamic views
	----------------------------------------------------------------------------------------------------

	-- Import data from source --
	INSERT INTO	#ActiveRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
	EXECUTE	DB061.bodb_Archive.dbo.Task_ArchiveHA_CheckRowcount_Child @Step = 1;

	-- Import data from local --
	INSERT INTO	#StandbyRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
	EXECUTE	dbo.Task_ArchiveHA_CheckRowcount_Child @step = 1;

	-- Insert month level rowcounts --
	INSERT INTO	dbo.Task_ArchiveHA_RowcountResult (StandbyServer, DatabaseName, TableName, WinLostDate, ActiveRowcount, StandbyRowcount, TimeType)
	SELECT	[StandbyServer]		= @Server
		,	[DatabaseName]		= ISNULL(act.DatabaseName, stb.DatabaseName)
		,	[TableName]			= ISNULL(act.TableName, stb.TableName)
		,	[WinLostDate]		= ISNULL(act.WinLostDate, stb.WinLostDate)
		,	[ActiveRowcount]	= ISNULL(act.RowCnt, 0)
		,	[StandbyRowcount]	= ISNULL(stb.RowCnt, 0)
		,	[TimeType]			= ISNULL(act.TimeType, stb.TimeType)
	FROM			#ActiveRowcount AS act
	FULL OUTER JOIN	#StandbyRowcount AS stb
				ON	act.DatabaseName = stb.DatabaseName
				AND	act.TableName = stb.TableName
				AND	ISNULL(act.WinLostDate, 0) = ISNULL(stb.WinLostDate, 0)
				AND	act.TimeType = stb.TimeType;

	-- Keep only mismatch result --
	DELETE	tbl WITH (TABLOCK)
	FROM	dbo.Task_ArchiveHA_RowcountResult AS tbl
	WHERE	tbl.ActiveRowcount = tbl.StandbyRowcount;


	--	BEGIN STEP 2:
	--		Compare rowcount based on actual rows count
	----------------------------------------------------------------------------------------------------

	-- Clear temp table --
	TRUNCATE TABLE	#ActiveRowcount;
	TRUNCATE TABLE	#StandbyRowcount;

	WHILE	0 = 0
	BEGIN;
		SELECT	TOP(1)
				@Database		= DatabaseName
			,	@Table			= TableName
			,	@WinLostDate	= WinLostDate
		FROM	dbo.Task_ArchiveHA_RowcountResult WITH (NOLOCK)
		WHERE	TimeType		= 'MONTH';

		IF	@@ROWCOUNT = 0
			BREAK;

		-- Mark current table as PROCESSING --
		UPDATE	tbl WITH (TABLOCK)
		SET		TimeType = 'PROCESSING'
		FROM	dbo.Task_ArchiveHA_RowcountResult AS tbl
		WHERE	tbl.DatabaseName = @Database
			AND	tbl.TableName = @Table
			AND	ISNULL(tbl.WinLostDate, 0) = ISNULL(@WinLostDate, 0);

		-- Import data from source --
		INSERT INTO	#ActiveRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
		EXECUTE	DB061.bodb_Archive.dbo.Task_ArchiveHA_CheckRowcount_Child @step = 2, @Database = @Database, @Table = @Table, @WinLostDate = @WinLostDate, @MonthLimit = NULL;

		-- Import data from local --
		INSERT INTO	#StandbyRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
		EXECUTE	dbo.Task_ArchiveHA_CheckRowcount_Child @Step = 2, @Database = @Database, @Table = @Table, @WinLostDate = @WinLostDate, @MonthLimit = NULL;

		-- Insert day level rowcounts --
		INSERT INTO	dbo.Task_ArchiveHA_RowcountResult (StandbyServer, DatabaseName, TableName, WinLostDate, ActiveRowcount, StandbyRowcount, TimeType)
		SELECT	[StandbyServer]		= @Server
			,	[DatabaseName]		= ISNULL(act.DatabaseName, stb.DatabaseName)
			,	[TableName]			= ISNULL(act.TableName, stb.TableName)
			,	[WinLostDate]		= ISNULL(act.WinLostDate, stb.WinLostDate)
			,	[ActiveRowcount]	= ISNULL(act.RowCnt, 0)
			,	[StandbyRowcount]	= ISNULL(stb.RowCnt, 0)
			,	[TimeType]			= ISNULL(act.TimeType, stb.TimeType)
		FROM			#ActiveRowcount AS act
		FULL OUTER JOIN	#StandbyRowcount AS stb
					ON	act.DatabaseName = stb.DatabaseName
					AND	act.TableName = stb.TableName
					AND	ISNULL(act.WinLostDate, 0) = ISNULL(stb.WinLostDate, 0)
					AND	act.TimeType = stb.TimeType;

		UPDATE	tbl WITH (ROWLOCK)
		SET		TimeType = NULL
		FROM	dbo.Task_ArchiveHA_RowcountResult AS tbl
		WHERE	tbl.StandbyServer = @Server
			AND	tbl.TimeType = 'PROCESSING';

		-- Keep only mismatch result and in month limitation --
		DELETE	tbl WITH (TABLOCK)
		FROM		dbo.Task_ArchiveHA_RowcountResult AS tbl
		WHERE	tbl.DatabaseName = @Database
			AND	tbl.TableName = @Table
			AND	tbl.ActiveRowcount = tbl.StandbyRowcount;

		TRUNCATE TABLE #ActiveRowcount;
		TRUNCATE TABLE #StandbyRowcount;
	END;

	-- Delete processed data --
	DELETE	tbl WITH (TABLOCK)
	FROM	dbo.Task_ArchiveHA_RowcountResult AS tbl
	WHERE	tbl.TimeType IS NULL;
END;
GO
/*<info serverAlias="DBARc-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/
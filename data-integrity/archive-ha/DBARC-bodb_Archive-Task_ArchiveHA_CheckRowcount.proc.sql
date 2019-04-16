SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ArchiveHA_CheckRowcount
AS
/*
	Creator:	20170427@Billy
	Task:		Check bodb_Archive tables' rowcount - [Redmine: #00000]
	Database:	DBARC.bodb_Archive
		
	Revisions:
		- 20170627@Billy:	Add table type 5: MatchEventDate - [Redmine: #79047]
		- 20171222@Billy:	Add dynamic database support & Bring DB06 rowcount check to Child SP
							Add table type 6: accdate
							Add table type 7: ArchiveDate
							[Redmine: #88591]
		- 20190416@Billy:	DB061 Migration - [Redmine: #111418]
*/
BEGIN;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE	@Server			NVARCHAR(128)
		,	@LinkedServer	NVARCHAR(128)
		,	@MonthLimit		SMALLINT
		,	@Database		NVARCHAR(128)
		,	@Table			NVARCHAR(128)
		,	@WinLostDate	DATETIME
		,	@Query			NVARCHAR(MAX)
		,	@Params			NVARCHAR(MAX)
		,	@Execute		NVARCHAR(MAX)
		;

	CREATE TABLE	#StandbyServers (
						ServerName		NVARCHAR(128)	NOT NULL
					,	LinkedServer	NVARCHAR(128)	NOT NULL
					,	DataMonthLimit	SMALLINT
					,	isDone			BIT				NOT NULL
					,	PRIMARY KEY CLUSTERED (isDone, ServerName)
					);

	CREATE TABLE	#StandbyRowcount (
						DatabaseName	NVARCHAR(128)
					,	TableName		NVARCHAR(128)
					,	WinLostDate		DATETIME
					,	RowCnt			BIGINT
					,	TimeType		VARCHAR(10)
					,	PRIMARY KEY CLUSTERED (DatabaseName, TableName, WinLostDate)
					);

	CREATE TABLE	#ActiveRowcount (
						DatabaseName	NVARCHAR(128)
					,	TableName		NVARCHAR(128)
					,	WinLostDate		DATETIME
					,	RowCnt			BIGINT
					,	TimeType		VARCHAR(10)
					,	PRIMARY KEY CLUSTERED (DatabaseName, TableName, WinLostDate)
					);

	-- Truncate rowcount table --
	TRUNCATE TABLE	dbo.Task_ArchiveHA_RowcountResult;

	-- Get metadata --
	INSERT INTO	#StandbyServers
		(	ServerName, LinkedServer, DataMonthLimit, isDone)
	SELECT	ServerName, LinkedServer, DataMonthLimit, 0
	FROM	dbo.Task_ArchiveHA_StandbyServers
	WHERE	isActive = 1;

	--	BEGIN STEP 1:
	--	Compare rowcount based on system dynamic views
	----------------------------------------------------------------------------------------------------

	-- Dynamic query for standby querying --
	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	#StandbyRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
EXECUTE	[~~Server~~].bodb_Archive.dbo.Task_ArchiveHA_CheckRowcount_Child @Step = 1;
';

	-- Import data from local --
	INSERT INTO	#ActiveRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
	EXECUTE	dbo.Task_ArchiveHA_CheckRowcount_Child @step = 1;

	WHILE	0 = 0
	BEGIN;
		UPDATE	TOP(1)
				tbl WITH (ROWLOCK)
		SET		@Server			= tbl.ServerName
			,	@LinkedServer	= tbl.LinkedServer
			,	@MonthLimit		= tbl.DataMonthLimit
			,	isDone = 1
		FROM	#StandbyServers AS tbl
		WHERE	isDone = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		-- Import data from standby --
		SELECT	@Execute = REPLACE(@Query, N'~~Server~~', @LinkedServer);
		EXECUTE	sys.sp_executesql @Execute;

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

		-- Clear temp table data --
		TRUNCATE TABLE	#StandbyRowcount;
	END;

	-- Keep only mismatch result and in month limitation --
	DELETE	tbl WITH (TABLOCK)
	FROM		dbo.Task_ArchiveHA_RowcountResult AS tbl
	INNER JOIN	#StandbyServers AS ss
			ON	tbl.StandbyServer = ss.ServerName
	WHERE	tbl.ActiveRowcount = tbl.StandbyRowcount
		OR	tbl.WinLostDate < DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - ss.DataMonthLimit, 0);


	--	BEGIN STEP 2:
	--		Compare rowcount based on actual rows count
	----------------------------------------------------------------------------------------------------

	-- Dynamic query for standby querying --
	SELECT	@Query = N''
		,	@Params = N''
		;
	SELECT	@Query = @Query + N'
INSERT INTO	#StandbyRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
EXECUTE	[~~Server~~].bodb_Archive.dbo.Task_ArchiveHA_CheckRowcount_Child @Step = 2, @Database = @Database, @Table = @Table, @WinLostDate = @WinLostDate, @MonthLimit = @MonthLimit;
'
		,	@Params = @Params + N'@Database NVARCHAR(128), @Table NVARCHAR(128), @WinLostDate DATETIME, @MonthLimit SMALLINT'
		;

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

		-- Get list of servers that need to be run --
		UPDATE	tmp WITH (TABLOCK)
		SET		isDone = CASE WHEN tbl.StandbyServer IS NULL THEN 1 ELSE 0 END
		FROM		#StandbyServers AS tmp
		LEFT JOIN	dbo.Task_ArchiveHA_RowcountResult AS tbl
				ON	tbl.StandbyServer = tmp.ServerName
				AND	tbl.TimeType = 'PROCESSING';

		-- Import data from local --
		INSERT INTO	#ActiveRowcount (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
		EXECUTE	dbo.Task_ArchiveHA_CheckRowcount_Child @step = 2, @Database = @Database, @Table = @Table, @WinLostDate = @WinLostDate, @MonthLimit = NULL;

		WHILE	0 = 0
		BEGIN;
			UPDATE	TOP(1)
					tbl WITH (ROWLOCK)
			SET		@Server			= tbl.ServerName
				,	@LinkedServer	= tbl.LinkedServer
				,	@MonthLimit		= tbl.DataMonthLimit
				,	isDone = 1
			FROM	#StandbyServers AS tbl
			WHERE	isDone = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			-- Import data from standby --
			SELECT	@Execute = REPLACE(@Query, N'~~Server~~', @LinkedServer);
			EXECUTE	sys.sp_executesql @Execute, @Params, @Database, @Table, @WinLostDate, @MonthLimit;

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

			-- Clear temp table data --
			TRUNCATE TABLE	#StandbyRowcount;
		END;
	END;

	-- Delete processed data --
	DELETE	tbl WITH (TABLOCK)
	FROM	dbo.Task_ArchiveHA_RowcountResult AS tbl
	WHERE	tbl.TimeType IS NULL;

	-- Keep only mismatch result and in month limitation --
	DELETE	tbl WITH (TABLOCK)
	FROM		dbo.Task_ArchiveHA_RowcountResult AS tbl
	INNER JOIN	#StandbyServers AS ss
			ON	tbl.StandbyServer = ss.ServerName
	WHERE	tbl.ActiveRowcount = tbl.StandbyRowcount
		OR	tbl.WinLostDate < DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - ss.DataMonthLimit, 0);
END;
GO
/*<info serverAlias="DBARc-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/
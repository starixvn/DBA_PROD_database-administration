SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ArchiveHA_CheckRowcount_Child
						@Step			INT
					,	@Database		NVARCHAR(128)	= NULL
					,	@Table			NVARCHAR(128)	= NULL
					,	@WinLostDate	DATETIME		= NULL
					,	@MonthLimit		SMALLINT		= NULL
AS
/*
	Creator:	20170427@Billy
	Task:		Check bodb_Archive tables' rowcount - [Redmine: #00000]
	Database:	DBARC.bodb_Archive

	Revisions:
		- 20170627@Billy:	Add table type 5: MatchEventDate - [Redmine: #79047]
		- 20171222@Billy:	Add dynamic database support
							Add table type 6: accdate
							Add table type 7: ArchiveDate
							[Redmine: #88591]
		- 20190416@Billy:	DB061 Migration - [Redmine: #111418]
*/
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE	@Databases AS TABLE (
				DatabaseName	NVARCHAR(128)	NOT NULL
			,	isDone			BIT				NOT NULL
			);

	CREATE TABLE	#Result (
						DatabaseName	NVARCHAR(128)
					,	TableName		NVARCHAR(128)
					,	WinLostDate		DATETIME
					,	RowCnt			BIGINT
					,	TimeType		VARCHAR(10)
					);

	DECLARE	@TableType		INT
		,	@FromDate		DATETIME
		,	@ToDate			DATETIME

		,	@DataQuery		NVARCHAR(MAX)
		,	@DataParams		NVARCHAR(MAX)
		,	@DataExecute	NVARCHAR(MAX)
		,	@Query			NVARCHAR(MAX)
		,	@Params			NVARCHAR(MAX)
		,	@Execute		NVARCHAR(MAX)
		;


	--	BEGIN STEP 1:
	--		Select rowcount from system dynamic view
	----------------------------------------------------------------------------------------------------

	IF	@Step = 1
	BEGIN;
		-- Query for select data --
		SELECT	@DataQuery = N'';
		SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= DB_NAME()
	,	[TableName]		= tbl.name
	,	[WinLostDate]	= pt.right_value
	,	[RowCount]		= prt.rows
	,	[TimeType]		= CAST(''MONTH'' AS VARCHAR(10))
FROM		bodb_Archive.dbo.Task_ArchiveHA_ArchiveTables AS at
INNER JOIN	sys.tables AS tbl
		ON	at.TableName = tbl.name
INNER JOIN	sys.indexes AS idx
		ON	tbl.object_id = idx.object_id
		AND	idx.type IN (0, 1)
INNER JOIN	sys.partitions AS prt
		ON	idx.object_id = prt.object_id
		AND	idx.index_id = prt.index_id
LEFT JOIN	sys.partition_schemes AS ps
		ON	idx.data_space_id = ps.data_space_id
LEFT JOIN	sys.partition_range_values AS rvr
		ON	ps.function_id = rvr.function_id
		AND	prt.partition_number = rvr.boundary_id
OUTER APPLY	(
	SELECT	[right_value]	= DATEADD(MONTH, DATEDIFF(MONTH, 0, CAST(rvr.value AS DATETIME)), 0)
) AS pt
WHERE	at.DatabaseName = DB_NAME()
ORDER BY tbl.name, prt.partition_number;
';

		SELECT	@Query = N''
			,	@Params = N''
			;
		SELECT	@Query = @Query + N'
EXECUTE	[~~Database~~].sys.sp_executesql @Query;
'
			,	@Params = @Params + N'@Query NVARCHAR(MAX)'
			;

		INSERT INTO	@Databases
			(	DatabaseName, isDone)
		SELECT	DISTINCT
				DatabaseName, 0
		FROM	dbo.Task_ArchiveHA_ArchiveTables
		WHERE	TableType IS NOT NULL;

		WHILE	0 = 0
		BEGIN
			UPDATE	TOP(1)
					@Databases
			SET		@Database = DatabaseName
				,	isDone = 1
			WHERE	isDone = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			SELECT	@Execute = REPLACE(@Query, N'~~Database~~', @Database);

			EXECUTE	sys.sp_executesql @Execute, @Params, @DataQuery;
		END;

		DELETE	tbl
		FROM	#Result AS tbl
		WHERE	tbl.WinLostDate IS NULL
			AND	EXISTS (SELECT 1 FROM #Result AS r WHERE r.TableName = tbl.TableName AND r.WinLostDate IS NOT NULL);
	END;

	IF	@Step = 2 AND @Database IS NOT NULL AND @Table IS NOT NULL
	BEGIN;
		SELECT	@TableType = TableType
		FROM	dbo.Task_ArchiveHA_ArchiveTables
		WHERE	DatabaseName = @Database
			AND	TableName = @Table;

		IF	@TableType IS NOT NULL
		BEGIN;
			IF	@WinLostDate IS NULL
			BEGIN;
				SELECT	@FromDate	= ISNULL(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - @MonthLimit, 0), 0)
					,	@ToDate		= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 12, 0)
					;
			END;
			ELSE IF	@Table = N'Dot_Admin_LiveLog'
			BEGIN;
				SELECT	@FromDate	= DATEADD(MONTH, -2, @WinLostDate)
					,	@ToDate		= DATEADD(MILLISECOND, -3, DATEADD(MONTH, 1, @WinLostDate))
					;
			END;
			ELSE
			BEGIN;
				SELECT	@FromDate	= @WinLostDate
					,	@ToDate		= DATEADD(MILLISECOND, -3, DATEADD(MONTH, 1, @WinLostDate))
					;
			END;

			-- Table with winlostdate column --
			IF	@TableType = 1
			BEGIN;
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(tbl.winlostdate AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM	dbo.[~~Table~~] AS tbl WITH (NOLOCK)
WHERE	tbl.winlostdate >= @FromDate
	AND	tbl.winlostdate <= @ToDate
GROUP BY CAST(tbl.winlostdate AS DATE);
';
			END;

			-- Table with eventdate column --
			IF	@TableType = 2
			BEGIN;
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(tbl.eventdate AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM	dbo.[~~Table~~] AS tbl WITH (NOLOCK)
WHERE	tbl.eventdate >= @FromDate
	AND	tbl.eventdate <= @ToDate
GROUP BY CAST(tbl.eventdate AS DATE);
';
			END;

			-- Table with matchid column --
			IF	@TableType = 3
			BEGIN;
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(m.eventdate AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM		dbo.[~~Table~~] AS tbl WITH (NOLOCK)
INNER JOIN	bodb_Archive.dbo.match_bk AS m WITH (NOLOCK)
		ON	tbl.matchid = m.matchid
WHERE	m.eventdate >= @FromDate
	AND	m.eventdate <= @ToDate
GROUP BY CAST(m.eventdate AS DATE);
';
			END;

			-- Table with transtime column --
			IF	@TableType = 4
			BEGIN;
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(tbl.transtime AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM	dbo.[~~Table~~] AS tbl WITH (NOLOCK)
WHERE	tbl.transtime >= @FromDate
	AND	tbl.transtime <= @ToDate
GROUP BY CAST(tbl.transtime AS DATE);
';
			END;

			-- Table with MatchEventDate column --
			IF	@TableType = 5
			BEGIN;
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(tbl.MatchEventDate AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM	dbo.[~~Table~~] AS tbl WITH (NOLOCK)
WHERE	tbl.MatchEventDate >= @FromDate
	AND	tbl.MatchEventDate <= @ToDate
GROUP BY CAST(tbl.MatchEventDate AS DATE);
';
			END;

			-- Table with accdate column -- Statement --
			IF	@TableType = 6
			BEGIN;
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(tbl.accdate AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM	dbo.[~~Table~~] AS tbl WITH (NOLOCK)
WHERE	tbl.accdate >= @FromDate
	AND	tbl.accdate <= @ToDate
GROUP BY CAST(tbl.accdate AS DATE);
';
			END;

			-- Table with ArchiveDate column --
			IF	@TableType = 7
			BEGIN;
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(tbl.ArchiveDate AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM	dbo.[~~Table~~] AS tbl WITH (NOLOCK)
WHERE	tbl.ArchiveDate >= @FromDate
	AND	tbl.ArchiveDate <= @ToDate
GROUP BY CAST(tbl.ArchiveDate AS DATE);
';
			END;

			SELECT	@DataParams = N'';
			SELECT	@DataParams = @DataParams + N'@Database NVARCHAR(128), @Table NVARCHAR(128), @FromDate DATETIME, @ToDate DATETIME';

			SELECT	@DataExecute = REPLACE(@DataQuery, N'~~Table~~', @Table);

			SELECT	@Query = N'';
			SELECT	@Query = N'
EXECUTE	[~~Database~~].sys.sp_executesql @Query, @Params, @Database, @Table, @FromDate, @ToDate;
';

			SELECT	@Params = N'';
			SELECT	@Params = @Params + N'@Query NVARCHAR(MAX), @Params NVARCHAR(MAX), ' + @DataParams;

			SELECT	@Execute = REPLACE(@Query, N'~~Database~~', @Database);

			EXECUTE	sys.sp_executesql @Execute, @Params, @DataExecute, @DataParams, @Database, @Table, @FromDate, @ToDate;

			IF	@Table = N'Dot_Admin_Assignment_Operator_bk'
			BEGIN
				SELECT	@DataQuery = N'';
				SELECT	@DataQuery = @DataQuery + N'
INSERT INTO	#Result (DatabaseName, TableName, WinLostDate, RowCnt, TimeType)
SELECT	[DatabaseName]	= @Database
	,	[TableName]		= @Table
	,	[WinLostDate]	= CAST(m.eventdate AS DATE)
	,	[RowCount]		= COUNT(1)
	,	[TimeType]		= CAST(''DAY'' AS VARCHAR(10))
FROM		dbo.[~~Table~~] AS tbl WITH (NOLOCK)
INNER JOIN	bodb02.dbo.match14 AS m WITH (NOLOCK)
		ON	tbl.matchid = m.matchid
WHERE	m.eventdate >= @FromDate
	AND	m.eventdate <= @ToDate
GROUP BY CAST(m.eventdate AS DATE);
';

				SELECT	@DataParams = N'';
				SELECT	@DataParams = @DataParams + N'@Database NVARCHAR(128), @Table NVARCHAR(128), @FromDate DATETIME, @ToDate DATETIME';

				SELECT	@DataExecute = REPLACE(@DataQuery, N'~~Table~~', @Table);

				SELECT	@Query = N'';
				SELECT	@Query = N'
EXECUTE	[~~Database~~].sys.sp_executesql @Query, @Params, @Database, @Table, @FromDate, @ToDate;
';

				SELECT	@Params = N'';
				SELECT	@Params = @Params + N'@Query NVARCHAR(MAX), @Params NVARCHAR(MAX), ' + @DataParams;

				SELECT	@Execute = REPLACE(@Query, N'~~Database~~', @Database);

				EXECUTE	sys.sp_executesql @Execute, @Params, @DataExecute, @DataParams, @Database, @Table, @FromDate, @ToDate;
			END;
		END;
	END;


	--	BEGIN STEP n:
	--		Select result data
	----------------------------------------------------------------------------------------------------

	SELECT	DatabaseName, TableName, WinLostDate, RowCnt, TimeType
	FROM	#Result
	ORDER BY WinLostDate;
END;
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="0" isNested="1"></info>*/
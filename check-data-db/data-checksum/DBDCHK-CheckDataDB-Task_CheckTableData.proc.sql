SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	chksum.Task_CheckTableData
						@Schema				NVARCHAR(128)
					,	@Table				NVARCHAR(128)
					,	@CheckTime			DATETIME		= NULL
					,	@MaxPartitionValue	BIGINT			= NULL
					,	@Debug				BIT				= 0
AS
/*
	Creator:	20200123@Billy
	Task:		Perform checking data of a table - [Redmine: #127620]
	Database:	DBDCHK.CheckDataDB

	Revisions:
		- 20200123@Billy:	Initial - [Redmine: #127620]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Dynamic query --
	DECLARE	@Query				NVARCHAR(MAX)
		,	@Param				NVARCHAR(MAX)
		,	@ExecuteSP			NVARCHAR(MAX)
		;

	-- Target Variables --
	DECLARE	@TargetId			INT
		,	@Server				NVARCHAR(128)
		,	@Database			NVARCHAR(128)
		;

	-- Debug Variables --
	DECLARE	@Msg				NVARCHAR(MAX)
		;

	-- Variables --
	DECLARE	@TableId			INT
		,	@PartitionCol		NVARCHAR(128)
		,	@PartitionInterval	BIGINT
		,	@IntervalFrom		BIGINT
		,	@IntervalTo			BIGINT
		;

	-- Table Variables --
	DECLARE	@Targets AS TABLE (
				TargetId		INT
			,	TargetServer	NVARCHAR(128)
			,	TargetDatabase	NVARCHAR(128)
			,	isSource		BIT
			,	TargetStatus	TINYINT
					DEFAULT (0)
			,	PRIMARY KEY CLUSTERED (TargetServer, TargetDatabase)
			);

	DECLARE	@Intervals AS TABLE (
				IntervalFrom	BIGINT
			,	IntervalTo		BIGINT
			,	PRIMARY KEY CLUSTERED (IntervalFrom)
			);

	DECLARE	@TargetSchemas AS TABLE (
				TargetId		INT
			,	RowNum			INT
			,	ColName			NVARCHAR(128)
			,	ColType			NVARCHAR(256)
			,	PK				INT
			,	ID				BIT
			,	PRIMARY KEY CLUSTERED (TargetId, RowNum)
			);


	-- Get variables --
	SELECT	@TableId			= tbl.TableId
		,	@PartitionCol		= tbl.PartitionCol
		,	@PartitionInterval	= tbl.PartitionInterval
	FROM	chksum.TableConfigs AS tbl WITH (NOLOCK)
	WHERE	tbl.SchName = @Schema
		AND	tbl.TblName = @Table;

	-- Correct parameters --
	BEGIN;
		SELECT	@CheckTime		= ISNULL(@CheckTime, GETDATE())
			;

		IF	@TableId IS NULL
		OR	@PartitionCol IS NULL
		OR	@PartitionInterval IS NULL
		BEGIN;
			SELECT	@Msg = N'';
			SELECT	@Msg += N'\
[Check Table Data] - ' + @Schema + N'.' + @Table + N'
This table is not configured correctly. Exiting...';

			EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage 'BILLY', @Msg;
			RAISERROR(@Msg, 16, 1) WITH NOWAIT;

			RETURN 16;
		END;

		IF	@MaxPartitionValue IS NULL
		BEGIN;
			SELECT	TOP(1)
					@Server			= src.TargetServer
				,	@Database		= src.TargetDatabase
			FROM		chksum.TableConfigs AS tbl WITH (NOLOCK)
			INNER JOIN	chksum.Checklist AS l WITH (NOLOCK)
					ON	tbl.TableId = l.TableId
			INNER JOIN	chksum.Targets AS t WITH (NOLOCK)
					ON	l.TargetId = t.TargetId
			INNER JOIN	chksum.Targets AS src WITH (NOLOCK)
					ON	t.SrcTarget = src.TargetId
			WHERE	tbl.SchName = @Schema
				AND	tbl.TblName = @Table
				AND	l.isActive = 1;

			SELECT	@Query = N'';
			SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	@MaxPartitionValue = MAX(~~PartitionCol~~)
FROM	~~Schema~~.~~Table~~ WITH (NOLOCK);';
			SELECT	@Query = REPLACE(REPLACE(REPLACE(
								@Query
							,	N'~~PartitionCol~~'	, QUOTENAME(@PartitionCol))
							,	N'~~Schema~~'		, QUOTENAME(@Schema))
							,	N'~~Table~~'		, QUOTENAME(@Table))
							;

			SELECT	@Param = N'';
			SELECT	@Param += N'@MaxPartitionValue BIGINT OUTPUT';

			SELECT	@ExecuteSP = QUOTENAME(@Server) + N'.' + QUOTENAME(@Database) + N'.sys.sp_executesql';
			EXECUTE	@ExecuteSP @Query, @Param, @MaxPartitionValue OUTPUT;
			
			-- Abort if cannot obtain the value --
			IF	@@ERROR <> 0 OR @MaxPartitionValue IS NULL
			BEGIN;
				SELECT	@Msg = N'';
				SELECT	@Msg += N'\
[Check Table Data] - ' + @Schema + N'.' + @Table + N'
Cannot determine @MaxPartitionValue to continue checking data. Exiting...';

				EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage 'BILLY', @Msg;
				RAISERROR(@Msg, 16, 1) WITH NOWAIT;

				RETURN 16;
			END;
		END;
	END;

	-- Get targets --
	INSERT INTO	@Targets (TargetId, TargetServer, TargetDatabase, isSource)
	SELECT	t.TargetId, t.TargetServer, t.TargetDatabase, 0
	FROM		chksum.Checklist AS l WITH (NOLOCK)
	INNER JOIN	chksum.Targets AS t WITH (NOLOCK)
			ON	l.TargetId = t.TargetId
	WHERE	l.TableId = @TableId
		AND	l.isActive = 1
	UNION
	SELECT	src.TargetId, src.TargetServer, src.TargetDatabase, 1
	FROM		chksum.Checklist AS l WITH (NOLOCK)
	INNER JOIN	chksum.Targets AS t WITH (NOLOCK)
			ON	l.TargetId = t.TargetId
	INNER JOIN	chksum.Targets AS src WITH (NOLOCK)
			ON	t.SrcTarget = src.TargetId
	WHERE	l.TableId = @TableId
		AND	l.isActive = 1;

	-- Get intervals --
	INSERT INTO	@Intervals (IntervalFrom, IntervalTo)
	SELECT	[IntervalFrom]	= (t.id - 1) * @PartitionInterval
		,	[IntervalTo]	= CASE WHEN t.id * @PartitionInterval - 1 < @MaxPartitionValue THEN t.id * @PartitionInterval - 1 ELSE @MaxPartitionValue END
	FROM	(
		SELECT	TOP(@MaxPartitionValue / @PartitionInterval + 1)
				[id] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
		FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS _x10(n)
		CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS _x100(n)
		CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS _x1000(n)
		CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS _x10000(n)
		CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS _x100000(n)
		CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) AS _x1000000(n)
	) AS t
	WHERE	t.id < @MaxPartitionValue / @PartitionInterval + 1;


	-- Check schema --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[TargetId]		= @TargetId
	,	[RowNum]		= ROW_NUMBER() OVER(ORDER BY c.column_id)
	,	[ColName]		= c.name
	,	[ColType]		= ft.name
	,	[PK]			= ISNULL(idx.pk, 0)
	,	[ID]			= c.is_identity
FROM		sys.schemas AS s WITH (NOLOCK)
INNER JOIN	sys.tables AS t WITH (NOLOCK)
		ON	s.schema_id = t.schema_id
INNER JOIN	sys.columns AS c WITH (NOLOCK)
		ON	t.object_id = c.object_id
INNER JOIN	sys.types AS tp WITH (NOLOCK)
		ON	c.user_type_id = tp.user_type_id
CROSS APPLY	(
	SELECT	[name]	= UPPER	(	tp.name
							+	CASE tp.name	WHEN N''BINARY''			THEN N''('' + CAST(c.max_length AS NVARCHAR) + N'')''
												WHEN N''CHAR''				THEN N''('' + CAST(c.max_length AS NVARCHAR) + N'')''
												WHEN N''DATETIME2''			THEN N''('' + CAST(c.scale AS NVARCHAR) + N'')''
												WHEN N''DATETIMEOFFSET''	THEN N''('' + CAST(c.scale AS NVARCHAR) + N'')''
												WHEN N''DECIMAL''			THEN N''('' + CAST(c.precision AS NVARCHAR) + N'','' + CAST(c.scale AS NVARCHAR) + N'')''
												WHEN N''NCHAR''				THEN N''('' + CAST(c.max_length / 2 AS NVARCHAR) + N'')''
												WHEN N''NUMERIC''			THEN N''('' + CAST(c.precision AS NVARCHAR) + N'','' + CAST(c.scale AS NVARCHAR) + N'')''
												WHEN N''NVARCHAR''			THEN N''('' + CASE c.max_length WHEN -1 THEN N''MAX'' ELSE CAST(c.max_length / 2 AS NVARCHAR) END + N'')''
												WHEN N''TIME''				THEN N''('' + CAST(c.scale AS NVARCHAR) + N'')''
												WHEN N''VARBINARY''			THEN N''('' + CASE c.max_length WHEN -1 THEN N''MAX'' ELSE CAST(c.max_length AS NVARCHAR) END + N'')''
												WHEN N''VARCHAR''			THEN N''('' + CASE c.max_length WHEN -1 THEN N''MAX'' ELSE CAST(c.max_length AS NVARCHAR) END + N'')''
												ELSE N''''
								END
							)
) AS ft
OUTER APPLY	(
	SELECT	[pk]	= ic.key_ordinal
	FROM		sys.indexes AS i WITH (NOLOCK)
	INNER JOIN	sys.index_columns AS ic WITH (NOLOCK)
			ON	ic.object_id = i.object_id
			AND	ic.index_id = i.index_id
	WHERE	i.object_id = t.object_id
		AND	ic.column_id = c.column_id
		AND	i.is_primary_key = 1
) AS idx
WHERE	s.name = @SchName
	AND	t.name = @TblName
	AND	tp.name NOT IN (N''timestamp'');';

		SELECT	@Param = N'';
		SELECT	@Param += N'@TargetId INT, @SchName NVARCHAR(128), @TblName NVARCHAR(128)';

		-- Get schema for all targets --
		UPDATE	@Targets
		SET		TargetStatus = 0;

		WHILE 0 = 0
		BEGIN;
			UPDATE	TOP(1) t
			SET		@TargetId	= t.TargetId
				,	@Server		= t.TargetServer
				,	@Database	= t.TargetDatabase
				,	TargetStatus = 1
			FROM	@Targets AS t
			WHERE	t.TargetStatus = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			SELECT	@ExecuteSP = QUOTENAME(@Server) + N'.' + QUOTENAME(@Database) + N'.sys.sp_executesql';

			INSERT INTO	@TargetSchemas (TargetId, RowNum, ColName, ColType, PK, ID)
			EXECUTE	@ExecuteSP @Query, @Param, @TargetId, @Schema, @Table;
		END;

		DELETE	ts
		FROM		@TargetSchemas AS ts
		INNER JOIN	chksum.CheckExcluded AS ex
				ON	ex.TblName = @Table
				AND	ts.ColName = ex.ColName;

		UPDATE	t
		SET		TargetStatus	= CASE	WHEN chk.Cnt = src.Cnt AND chk.ChkSum = src.ChkSum AND chk.Stdev = src.Stdev AND chk.ChkSumOrder = src.ChkSumOrder AND chk.StdevOrder = src.StdevOrder
											THEN 2
										WHEN chk.Cnt = src.Cnt AND chk.ChkSum = src.ChkSum AND chk.Stdev = src.Stdev AND NOT(chk.ChkSumOrder = src.ChkSumOrder AND chk.StdevOrder = src.StdevOrder)
											THEN 1
										ELSE 0
								  END
		FROM		@Targets AS t
		CROSS APPLY	(
			SELECT	[Cnt]			= COUNT(1)
				,	[ChkSum]		= CHECKSUM_AGG(BINARY_CHECKSUM(_ts.ColName, _ts.ColType))
				,	[Stdev]			= STDEV(BINARY_CHECKSUM(_ts.ColName, _ts.ColType))
				,	[ChkSumOrder]	= CHECKSUM_AGG(BINARY_CHECKSUM(_ts.RowNum, _ts.ColName, _ts.ColType))
				,	[StdevOrder]	= STDEV(BINARY_CHECKSUM(_ts.RowNum, _ts.ColName, _ts.ColType))
			FROM	@TargetSchemas AS _ts
			WHERE	_ts.TargetId = t.TargetId
		) AS chk
		CROSS APPLY	(
			SELECT	[Cnt]			= COUNT(1)
				,	[ChkSum]		= CHECKSUM_AGG(BINARY_CHECKSUM(_ts.ColName, _ts.ColType))
				,	[Stdev]			= STDEV(BINARY_CHECKSUM(_ts.ColName, _ts.ColType))
				,	[ChkSumOrder]	= CHECKSUM_AGG(BINARY_CHECKSUM(_ts.RowNum, _ts.ColName, _ts.ColType))
				,	[StdevOrder]	= STDEV(BINARY_CHECKSUM(_ts.RowNum, _ts.ColName, _ts.ColType))
			FROM		@Targets AS _t
			INNER JOIN	@TargetSchemas AS _ts
					ON	_t.TargetId = _ts.TargetId
			WHERE	_t.isSource = 1
		) AS src

		IF	NOT EXISTS (SELECT 1 FROM @Targets WHERE TargetStatus > 0 AND isSource = 0)
		BEGIN;
			SELECT	@Msg = N'';
			SELECT	@Msg += N'\
[Check Table Data] - ' + @Schema + N'.' + @Table + N'
All targets'' schema are not matching with source target. Exiting...';

			EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage 'BILLY', @Msg;
			RAISERROR(@Msg, 16, 1) WITH NOWAIT;

			RETURN 16;
		END;
		ELSE IF	EXISTS (SELECT 1 FROM @Targets WHERE TargetStatus = 0 AND isSource = 0)
		BEGIN;
			SELECT	@Msg = N'\
[Check Table Data] - ' + @Schema + N'.' + @Table + ts.str
			FROM	(
				SELECT	N'
Target ' + QUOTENAME(_t.TargetServer) + N'.' + QUOTENAME(_t.TargetDatabase) + N': Schema check failed. Ignoring...'
				FROM	@Targets AS _t
				WHERE	_t.isSource = 0
					AND	_t.TargetStatus = 0
				FOR XML PATH ('')
				,	TYPE
			) AS xt(xml)
			CROSS APPLY	(
				SELECT	xt.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS ts(str);

			EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage 'BILLY', @Msg;
			RAISERROR(@Msg, 0, 0) WITH NOWAIT;
		END;

		DELETE	@Targets
		WHERE	TargetStatus = 0;
	END;

	-- Initial result --
	INSERT INTO	chksum.CheckResults (ChkDate, ItemId, IntervalFrom, IntervalTo)
	SELECT	[ChkDate]		= @CheckTime
		,	[ItemId]		= l.ItemId
		,	[IntervalFrom]	= i.IntervalFrom
		,	[IntervalTo]	= i.IntervalTo
	FROM		chksum.Checklist AS l WITH (NOLOCK)
	INNER JOIN	@Targets AS t
			ON	l.TargetId = t.TargetId
	CROSS APPLY	@Intervals AS i
	WHERE	l.TableId = @TableId
		AND	l.isActive = 1;


	-- Prepare checksum query --
	SELECT	@Query = N'';
	SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

DECLARE	@Start		DATETIME;
SELECT	@Start = GETDATE();

SELECT	@Count		= COUNT(1)
	,	@Chksum		= ISNULL(CHECKSUM_AGG(BINARY_CHECKSUM(' + cols.str + N')), 0)
	,	@Stdev		= ISNULL(STDEV(BINARY_CHECKSUM(' + cols.str + N')), 0)
FROM	' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N' WITH (NOLOCK)
WHERE	' + QUOTENAME(@PartitionCol) + N' >= @IntervalFrom
	AND	' + QUOTENAME(@PartitionCol) + N' <= @IntervalTo;

SELECT	@Duration = DATEDIFF(MILLISECOND, @Start, GETDATE());'
	FROM	(
		SELECT	QUOTENAME(ts.ColName) + N', '
		FROM		@TargetSchemas AS ts
		INNER JOIN	@Targets AS t
				ON	ts.TargetId = t.TargetId
		WHERE	t.isSource = 1
		ORDER BY ts.RowNum
		FOR XML PATH ('')
		,	TYPE
	) AS xcol(xml)
	CROSS APPLY (
		SELECT	LEFT(xq.str, LEN(xq.str) - 1)
		FROM	(
			SELECT	xcol.xml.value('.[1]', 'NVARCHAR(MAX)')
		) AS xq(str)
	) AS cols(str);

	SELECT	@Param = N'';
	SELECT	@Param += N'@IntervalFrom BIGINT, @IntervalTo BIGINT, @Count INT OUTPUT, @Chksum INT OUTPUT, @Stdev INT OUTPUT, @Duration INT OUTPUT';

	-- Run checksum by interval --
	WHILE	0 = 0
	BEGIN;
		SELECT	TOP(1)
				@IntervalFrom	= i.IntervalFrom
			,	@IntervalTo		= i.IntervalTo
		FROM	@Intervals AS i;

		IF	@@ROWCOUNT = 0
			BREAK;

		-- Run through each target --
		UPDATE	@Targets
		SET		TargetStatus = 0;

		WHILE	0 = 0
		BEGIN;
			UPDATE	TOP(1)
					@Targets
			SET		@TargetId	= TargetId
				,	@Server		= TargetServer
				,	@Database	= TargetDatabase
				,	TargetStatus = 1
			WHERE	TargetStatus = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			SELECT	@ExecuteSP = N'';
			SELECT	@ExecuteSP = N'\
-- Task_CheckTableData --

DECLARE	@Query			NVARCHAR(MAX)
	,	@Param			NVARCHAR(MAX)

	,	@CheckTime		DATETIME
	,	@TableId		INT
	,	@TargetId		INT

	,	@IntervalFrom	BIGINT
	,	@IntervalTo		BIGINT
	,	@Count			INT
	,	@Chksum			INT
	,	@Stdev			INT
	,	@Duration		INT
	;

SELECT	@Query = N'''';
SELECT	@Query += N''' + REPLACE(@Query, NCHAR(39), NCHAR(39) + NCHAR(39)) + N''';

SELECT	@Param = N'''';
SELECT	@Param += N''' + REPLACE(@Param, NCHAR(39), NCHAR(39) + NCHAR(39)) + N''';

SELECT	@CheckTime		= ''' + CONVERT(NVARCHAR, @CheckTime, 121) + N'''
	,	@TableId		= ' + CAST(@TableId AS NVARCHAR) + N'
	,	@TargetId		= ' + CAST(@TargetId AS NVARCHAR) + N'
	,	@IntervalFrom	= ' + CAST(@IntervalFrom AS NVARCHAR) + N'
	,	@IntervalTo		= ' + CAST(@IntervalTo AS NVARCHAR) + N'
	;

EXECUTE	' + QUOTENAME(@Server) + N'.' + QUOTENAME(@Database) + N'.sys.sp_executesql @Query, @Param, @IntervalFrom, @IntervalTo, @Count OUTPUT, @Chksum OUTPUT, @Stdev OUTPUT, @Duration OUTPUT;

UPDATE	r
SET		r.SrcCount		= CASE	WHEN @TargetId = c.SrcTarget THEN @Count
								ELSE r.SrcCount
							END
	,	r.SrcChecksum	= CASE	WHEN @TargetId = c.SrcTarget THEN @Chksum
								ELSE r.SrcChecksum
							END
	,	r.SrcStdev		= CASE	WHEN @TargetId = c.SrcTarget THEN @Stdev
								ELSE r.SrcStdev
							END
	,	r.SrcDuration	= CASE	WHEN @TargetId = c.SrcTarget THEN @Duration
								ELSE r.SrcDuration
							END
	,	r.DstCount		= CASE	WHEN @TargetId = c.TargetId THEN @Count
								ELSE r.DstCount
							END
	,	r.DstChecksum	= CASE	WHEN @TargetId = c.TargetId THEN @Chksum
								ELSE r.DstChecksum
							END
	,	r.DstStdev		= CASE	WHEN @TargetId = c.TargetId THEN @Stdev
								ELSE r.DstStdev
							END
	,	r.DstDuration	= CASE	WHEN @TargetId = c.TargetId THEN @Duration
								ELSE r.DstDuration
							END
FROM		chksum.CheckResults AS r WITH (ROWLOCK)
INNER JOIN	chksum.Checklist AS c WITH (NOLOCK)
		ON	r.ItemId = c.ItemId
WHERE	r.ChkDate = @CheckTime
	AND	r.IntervalFrom = @IntervalFrom
	AND	r.IntervalTo = @IntervalTo
	AND	c.TableId = @TableId
OPTION (RECOMPILE);
';

			EXECUTE	async.ASyncExecution @ExecuteSP;
		END;

		DELETE	@Intervals
		WHERE	IntervalFrom	= @IntervalFrom
			AND	IntervalTo		= @IntervalTo;
	END;
END;
GO
/*<info serverAlias="DBDCHK-CheckDataDB" executers="" viewers="" isFunction="0" isNested="1"></info>*/
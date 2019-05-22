USE	bodb02;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE	dbo.Task_Sync_Check_bettrans_mnl
						@SessionId		UNIQUEIDENTIFIER	OUTPUT
					,	@FromDate		SMALLDATETIME
					,	@ToDate			SMALLDATETIME
AS
/*
	Creator:	20190510@Billy
	Task:		bettrans - [Redmine: #000000]
	Database:	bodb02

	Revisions:
		- 20190510@Billy:	Initial - [Redmine: #000000]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	IF	@FromDate IS NULL OR @ToDate IS NULL
	BEGIN;
		RAISERROR('Date range is NULL', 16, 1) WITH NOWAIT;
		RETURN -1;
	END;

	DECLARE	@Table			NVARCHAR(128)
		,	@SrcServer		NVARCHAR(128)
		;

	DECLARE	@MaxTransId		BIGINT
		,	@IsMovingBet	BIT
		;

	-- Dynamic Query --
	DECLARE	@Query			NVARCHAR(MAX)
		,	@Param			NVARCHAR(MAX)
		,	@Execute		NVARCHAR(MAX)
		,	@ChecksumQuery	NVARCHAR(MAX)
		,	@ChecksumParam	NVARCHAR(MAX)
		;

	-- Debug --
	DECLARE	@Message		NVARCHAR(MAX)
		,	@Start			DATETIME
		,	@Duration		INT
		;

	DECLARE	@MovingBet AS TABLE (
				winlostdate		SMALLDATETIME
			);

	IF	OBJECT_ID('tempdb..#SrcChecksum') IS NOT NULL
		DROP TABLE	#SrcChecksum;
	CREATE TABLE	#SrcChecksum (
						category	NVARCHAR(128)
					,	winlostdate	SMALLDATETIME
					,	transid		BIGINT
					,	chk			INT
					,	binchk		INT
					,	PRIMARY KEY CLUSTERED (category, winlostdate, transid)
					);

	IF	OBJECT_ID('tempdb..#DstChecksum') IS NOT NULL
		DROP TABLE	#DstChecksum;
	CREATE TABLE	#DstChecksum (
						category	NVARCHAR(128)
					,	winlostdate	SMALLDATETIME
					,	transid		BIGINT
					,	chk			INT
					,	binchk		INT
					,	PRIMARY KEY CLUSTERED (category, winlostdate, transid)
					);

	SELECT	@SessionId	= ISNULL(@SessionId, NEWID())
		,	@Table		= N'bettrans'
		,	@SrcServer	= CASE	WHEN @@SERVERNAME = N'DBMNL' THEN N'DB061'
								WHEN @@SERVERNAME = N'DBTRANS' THEN N'DBMNL'
								ELSE N'DBTRANS'
						  END
		;

	SELECT	@Message = N'
@SessionId	= ' + CONVERT(NVARCHAR(36), @SessionId) + N'
@SrcServer	= ' + @SrcServer + N'
@Table		= ' + @Table + N'
@FromDate	= ' + CONVERT(NVARCHAR, @FromDate, 121) + N'
@ToDate		= ' + CONVERT(NVARCHAR, @ToDate, 121) + N'

';

	RAISERROR(@Message, 0, 0) WITH NOWAIT;

	--	BEGIN STEP 1:
	--		Checksum
	----------------------------------------------------------------------------------------------------

	SELECT	@Message = N'	- Start checksum:'
		,	@Start = GETDATE()
		;
	RAISERROR(@Message, 0, 0) WITH NOWAIT;

	SELECT	@ChecksumQuery = N'';
	SELECT	@ChecksumQuery = @ChecksumQuery + N'
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT	[category]		= cat.category
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM	dbo.bettrans AS b WITH (NOLOCK)
CROSS APPLY	(
	SELECT	[category]	= CASE	WHEN b.bettype = 20000 THEN N''BALANCE''
								WHEN b.bettype = 19999 THEN N''SUM''
								WHEN b.bettype = 8000 THEN N''EXCHANGE''
								WHEN b.bettype = 8001 THEN N''CHARGE COMM''
								WHEN b.bettype IN (1700, 1800, 1900) THEN N''DEPOSIT''
								WHEN b.bettype > 20000 THEN N''TRANSFER''
						  END
) AS cat
WHERE	b.matchid = 0
	AND	b.transid < @MaxTransId
	AND	b.winlostdate >= @FromDate
	AND	b.winlostdate <= @ToDate
UNION ALL
SELECT	[category]		= N''PARLAY''
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM	dbo.bettrans AS b WITH (NOLOCK)
WHERE	b.matchid IN (29, 2799)
	AND	b.transid < @MaxTransId
	AND	b.winlostdate >= @FromDate
	AND	b.winlostdate <= @ToDate
UNION ALL
SELECT	[category]		= N''NONSPORT''
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM	dbo.bettrans AS b WITH (NOLOCK)
WHERE	b.matchid >= 202
	AND	b.matchid <= 255
	AND	b.transid < @MaxTransId
	AND	b.winlostdate >= @FromDate
	AND	b.winlostdate <= @ToDate
UNION ALL
SELECT	[category]		= N''NG2''
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM	dbo.bettrans AS b WITH (NOLOCK)
WHERE	b.matchid >= 21300
	AND	b.matchid <= 21899
	AND	b.transid < @MaxTransId
	AND	b.winlostdate >= @FromDate
	AND	b.winlostdate <= @ToDate
UNION ALL
SELECT	[category]		= N''MATCH''
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	dbo.match AS m WITH (NOLOCK)
		ON	b.matchid = m.matchid
WHERE	b.transid < @MaxTransId
	AND	m.eventstatus <> ''running''
	AND	m.eventdate >= @FromDate
	AND	m.eventdate <= @ToDate
UNION ALL
SELECT	[category]		= N''MATCH3RD''
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	dbo.Match3rd AS m WITH (NOLOCK)
		ON	b.matchid = m.Match3rdId
WHERE	b.transid < @MaxTransId
	AND	m.EventStatus <> ''running''
	AND	m.EventDate >= @FromDate
	AND	m.EventDate <= @ToDate
UNION ALL
SELECT	[category]		= N''OUTRIGHT''
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	dbo.outright AS o WITH (NOLOCK)
		ON	b.matchid = o.orid
WHERE	b.transid < @MaxTransId
	AND	o.status <> ''running''
	AND	o.eventdate >= @FromDate
	AND	o.eventdate <= @ToDate
UNION ALL
SELECT	[category]		= N''VSOUTRIGHT''
	,	[winlostdate]	= b.winlostdate
	,	[transid]		= b.transid
	,	[chk]			= CHECKSUM(~~Columns~~)
	,	[binchk]		= BINARY_CHECKSUM(~~Columns~~)
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	(
	SELECT	DISTINCT _o.EventId
	FROM	dbo.VSOutright AS _o WITH (NOLOCK)
	WHERE	_o.EventStatus <> ''running''
		AND	_o.EventDate >= @FromDate
		AND	_o.EventDate <= @ToDate
) AS o
		ON	b.matchid = o.EventId
WHERE	b.transid < @MaxTransId
OPTION(QUERYTRACEON 8649, MAXDOP 8);
';
	SELECT	@ChecksumQuery = REPLACE(@ChecksumQuery, N'~~Columns~~', dbo.f_GetColumnList_mnl(@Table, N'SELECT', 'b'));

	SELECT	@ChecksumParam = N'';
	SELECT	@ChecksumParam = @ChecksumParam + N'@MaxTransId BIGINT, @FromDate SMALLDATETIME, @ToDate SMALLDATETIME';

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
EXECUTE	[~~Server~~].bodb02.sys.sp_executesql @Query, @Param, @MaxTransId, @FromDate, @ToDate;
';

	SELECT	@Param = N'';
	SELECT	@Param = @Param + N'@Query NVARCHAR(MAX), @Param NVARCHAR(MAX), ' + @ChecksumParam;

	SELECT	TOP(1)
			@MaxTransId = transid
	FROM	dbo.bettrans WITH (NOLOCK)
	ORDER BY transid DESC;

	SELECT	@IsMovingBet = CASE WHEN VValue <> '0' THEN 1 ELSE 0 END
	FROM	dbo.SystemSettings WITH (NOLOCK)
	WHERE	VName = 'isMovingBet_Local';

	INSERT INTO	@MovingBet (winlostdate)
	SELECT	MovingDay
	FROM	dbo.tf_GetMovingBetDays_mnl(NULL)
	WHERE	@IsMovingBet <> 0;

	SELECT	@Message	= N'		+ [%8d ms]	Done preparation'
		,	@Duration	= DATEDIFF(MILLISECOND, @Start, GETDATE())
		;
	RAISERROR(@Message, 0, 0, @Duration) WITH NOWAIT;

	SELECT	@Execute = REPLACE(@Query, N'~~Server~~', @SrcServer);
	INSERT INTO	#SrcChecksum (category, winlostdate, transid, chk, binchk)
	EXECUTE	sys.sp_executesql @Execute, @Param, @ChecksumQuery, @ChecksumParam, @MaxTransId, @FromDate, @ToDate;

	SELECT	@Message	= N'		+ [%8d ms]	Done checksum data from SOURCE'
		,	@Duration	= DATEDIFF(MILLISECOND, @Start, GETDATE())
		;
	RAISERROR(@Message, 0, 0, @Duration) WITH NOWAIT;

	INSERT INTO	#DstChecksum (category, winlostdate, transid, chk, binchk)
	EXECUTE	sys.sp_executesql @ChecksumQuery, @ChecksumParam, @MaxTransId, @FromDate, @ToDate;

	SELECT	@Message	= N'		+ [%8d ms]	Done checksum data from TARGET'
		,	@Duration	= DATEDIFF(MILLISECOND, @Start, GETDATE())
		;
	RAISERROR(@Message, 0, 0, @Duration) WITH NOWAIT;

	IF	@IsMovingBet = 1 AND EXISTS (SELECT 1 FROM @MovingBet WHERE winlostdate BETWEEN @FromDate AND @ToDate)
	BEGIN;
		DELETE	tmp
		FROM		#SrcChecksum AS tmp WITH (TABLOCK)
		INNER JOIN	@MovingBet AS mb
				ON	tmp.winlostdate = mb.winlostdate;

		DELETE	tmp
		FROM		#DstChecksum AS tmp WITH (TABLOCK)
		INNER JOIN	@MovingBet AS mb
				ON	tmp.winlostdate = mb.winlostdate;

		SELECT	@Message	= N'		+ [%8d ms]	*** MOVING BET RUNNING ***'
			,	@Duration	= DATEDIFF(MILLISECOND, @Start, GETDATE())
			;
		RAISERROR(@Message, 0, 0, @Duration) WITH NOWAIT;
	END;

	DELETE	dbo.Task_Sync_ChecksumResult_mnl WITH (ROWLOCK)
	WHERE	SessionId = @SessionId
		AND	TableName = @Table;

	INSERT INTO	dbo.Task_Sync_ChecksumResult_mnl
		(	 SessionId,  TableName, Category                          , WinLostDate                             , Key01                           , Key02, Key03, SrcCount, SrcChecksum, SrcBinaryChecksum, DstCount, DstChecksum, DstBinaryChecksum)
	SELECT	@SessionId , @Table   , ISNULL(src.category, dst.category), ISNULL(src.winlostdate, dst.winlostdate), ISNULL(src.transid, dst.transid), NULL , NULL , 1       , src.chk    , src.binchk       , 1       , dst.chk    , dst.binchk
	FROM			#SrcChecksum AS src WITH (NOLOCK)
	FULL OUTER JOIN	#DstChecksum AS dst WITH (NOLOCK)
				ON	src.category = dst.category
				AND	src.winlostdate = dst.winlostdate
				AND	src.transid = dst.transid
	WHERE	src.category IS NULL
		OR	dst.category IS NULL
		OR	src.chk <> dst.chk
		OR	src.binchk <> dst.binchk;

	SELECT	@Message	= N'		+ [%8d ms]	FINISHED checksum'
		,	@Duration	= DATEDIFF(MILLISECOND, @Start, GETDATE())
		;
	RAISERROR(@Message, 0, 0, @Duration) WITH NOWAIT;

	RAISERROR(N'', 0, 0) WITH NOWAIT;

	RETURN	0;
END;
GO
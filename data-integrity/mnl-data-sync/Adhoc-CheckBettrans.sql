USE	bodb02;
GO

DECLARE	@Table			NVARCHAR(128)	= N'bettrans'
	,	@SrcServer		NVARCHAR(128)	= N'DB061'
	;

DECLARE	@SessionId		UNIQUEIDENTIFIER
	,	@MaxTransId		BIGINT
	,	@MoveBetsDay	SMALLDATETIME
	,	@MaxWinLostDate	SMALLDATETIME
	,	@IsMovingBet	BIT
	;

DECLARE	@Query			NVARCHAR(MAX)
	,	@Param			NVARCHAR(MAX)
	,	@Execute		NVARCHAR(MAX)
	,	@ChecksumQuery	NVARCHAR(MAX)
	,	@ChecksumParam	NVARCHAR(MAX)
	;

DECLARE	@MovingBet AS TABLE (
			winlostdate		SMALLDATETIME
		);

IF	OBJECT_ID('tempdb..#SrcChecksum') IS NOT NULL
	DROP TABLE	#SrcChecksum;
CREATE TABLE	#SrcChecksum (
					category	NVARCHAR(128)
				,	winlostdate	SMALLDATETIME
				,	matchid		INT
				,	cnt			INT
				,	chk			INT
				,	binchk		INT
				,	PRIMARY KEY CLUSTERED (category, winlostdate, matchid)
				);

IF	OBJECT_ID('tempdb..#DstChecksum') IS NOT NULL
	DROP TABLE	#DstChecksum;
CREATE TABLE	#DstChecksum (
					category	NVARCHAR(128)
				,	winlostdate	SMALLDATETIME
				,	matchid		INT
				,	cnt			INT
				,	chk			INT
				,	binchk		INT
				,	PRIMARY KEY CLUSTERED (category, winlostdate, matchid)
				);

SELECT	@ChecksumQuery = N'';
SELECT	@ChecksumQuery = @ChecksumQuery + N'
SELECT	[category]		= cat.category
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= 0
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
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
	AND	(	b.bettype IN (19999, 20000)
		OR	b.winlostdate > @MoveBetsDay
		)
GROUP BY cat.category, b.winlostdate
UNION ALL
SELECT	[category]		= N''PARLAY''
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= 0
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
FROM	dbo.bettrans AS b WITH (NOLOCK)
WHERE	b.matchid IN (29, 2799)
	AND	b.transid < @MaxTransId
	AND	b.winlostdate > @MoveBetsDay
	AND	b.winlostdate < @MaxWinLostDate
GROUP BY b.winlostdate
UNION ALL
SELECT	[category]		= N''3RD''
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= 0
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
FROM	dbo.bettrans AS b WITH (NOLOCK)
WHERE	b.matchid >= 202
	AND	b.matchid <= 255
	AND	b.transid < @MaxTransId
	AND	b.winlostdate > @MoveBetsDay
	AND	b.winlostdate < @MaxWinLostDate
GROUP BY b.winlostdate
UNION ALL
SELECT	[category]		= N''NG2''
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= 0
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
FROM	dbo.bettrans AS b WITH (NOLOCK)
WHERE	b.matchid >= 21300
	AND	b.matchid <= 21899
	AND	b.transid < @MaxTransId
	AND	b.winlostdate > @MoveBetsDay
	AND	b.winlostdate < @MaxWinLostDate
GROUP BY b.winlostdate
UNION ALL
SELECT	[category]		= N''MATCH''
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= b.matchid
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	dbo.match AS m WITH (NOLOCK)
		ON	b.matchid = m.matchid
WHERE	b.transid < @MaxTransId
	AND	m.eventstatus <> ''running''
	AND	m.eventdate > @MoveBetsDay
	AND	m.eventdate < @MaxWinLostDate
GROUP BY b.winlostdate, b.matchid
UNION ALL
SELECT	[category]		= N''MATCH3RD''
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= b.matchid
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	dbo.Match3rd AS m WITH (NOLOCK)
		ON	b.matchid = m.Match3rdId
WHERE	b.transid < @MaxTransId
	AND	m.EventStatus <> ''running''
	AND	m.EventDate > @MoveBetsDay
	AND	m.EventDate < @MaxWinLostDate
GROUP BY b.winlostdate, b.matchid
UNION ALL
SELECT	[category]		= N''OUTRIGHT''
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= b.matchid
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	dbo.outright AS o WITH (NOLOCK)
		ON	b.matchid = o.orid
WHERE	b.transid < @MaxTransId
	AND	o.status <> ''running''
	AND	o.eventdate > @MoveBetsDay
	AND	o.eventdate < @MaxWinLostDate
GROUP BY b.winlostdate, b.matchid
UNION ALL
SELECT	[category]		= N''VSOUTRIGHT''
	,	[winlostdate]	= b.winlostdate
	,	[matchid]		= b.matchid
	,	[cnt]			= COUNT(1)
	,	[chk]			= CHECKSUM_AGG(CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
	,	[binchk]		= CHECKSUM_AGG(BINARY_CHECKSUM(' + dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b') + '))
FROM		dbo.bettrans AS b WITH (NOLOCK)
INNER JOIN	dbo.VSOutright AS o WITH (NOLOCK)
		ON	b.matchid = o.EventId
WHERE	b.transid < @MaxTransId
	AND	o.EventStatus <> ''running''
	AND	o.EventDate > @MoveBetsDay
	AND	o.EventDate < @MaxWinLostDate
GROUP BY b.winlostdate, b.matchid
';

SELECT	@ChecksumParam = N'';
SELECT	@ChecksumParam = @ChecksumParam + N'@MaxTransId BIGINT, @MaxWinLostDate SMALLDATETIME, @MoveBetsDay SMALLDATETIME';

SELECT	@Query = N'';
SELECT	@Query = @Query + N'
EXECUTE	[~~Server~~].bodb02.sys.sp_executesql @Query, @Param, @MaxTransId, @MaxWinLostDate, @MoveBetsDay;
';

SELECT	@Param = N'';
SELECT	@Param = @Param + N'@Query NVARCHAR(MAX), @Param NVARCHAR(MAX), ' + @ChecksumParam;

SELECT	@SessionId = NEWID();

SELECT	@SrcServer	= CASE	WHEN @@SERVERNAME = N'DBMNL' THEN N'DB061'
							WHEN @@SERVERNAME = N'DBTRANS' THEN N'DBMNL'
							ELSE N'DBTRANS'
					  END;

SELECT	[@SessionId] = @SessionId
	,	[@SrcServer] = @SrcServer
	;

RAISERROR(N'', 0, 0) WITH NOWAIT;

SELECT	TOP(1)
		@MaxTransId = transid
FROM	dbo.bettrans WITH (NOLOCK)
ORDER BY transid DESC;

SELECT	@MoveBetsDay = MoveBetsDay
	,	@MaxWinLostDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) - 1, 0)
FROM	dbo.tf_GetMBUDay_mnl();

SELECT	@IsMovingBet = CASE WHEN VValue <> '0' THEN 1 ELSE 0 END
FROM	dbo.SystemSettings WITH (NOLOCK)
WHERE	VName = 'isMovingBet_Local';

INSERT INTO	@MovingBet (winlostdate)
SELECT	MovingDay
FROM	dbo.tf_GetMovingBetDays_mnl(NULL)
WHERE	@IsMovingBet <> 0;


SELECT	@Execute = REPLACE(@Query, N'~~Server~~', @SrcServer);
INSERT INTO	#SrcChecksum (category, winlostdate, matchid, cnt, chk, binchk)
EXECUTE	sys.sp_executesql @Execute, @Param, @ChecksumQuery, @ChecksumParam, @MaxTransId, @MaxWinLostDate, @MoveBetsDay;

RAISERROR(N'', 0, 0) WITH NOWAIT;

INSERT INTO	#DstChecksum (category, winlostdate, matchid, cnt, chk, binchk)
EXECUTE	sys.sp_executesql @ChecksumQuery, @ChecksumParam, @MaxTransId, @MaxWinLostDate, @MoveBetsDay;

RAISERROR(N'', 0, 0) WITH NOWAIT;

DELETE	tmp
FROM		#SrcChecksum AS tmp WITH (TABLOCK)
INNER JOIN	@MovingBet AS mb
		ON	tmp.winlostdate = mb.winlostdate;

DELETE	tmp
FROM		#DstChecksum AS tmp WITH (TABLOCK)
INNER JOIN	@MovingBet AS mb
		ON	tmp.winlostdate = mb.winlostdate;

BEGIN TRANSACTION;

DELETE	dbo.Task_Sync_ChecksumResult_mnl WITH (ROWLOCK)
WHERE	TableName = @Table;

INSERT INTO	dbo.Task_Sync_ChecksumResult_mnl
	(	 SessionId,  TableName, Category                          , WinLostDate                             , Key01                           , Key02, Key03, SrcCount, SrcChecksum, SrcBinaryChecksum, DstCount, DstChecksum, DstBinaryChecksum)
SELECT	@SessionId , @Table   , ISNULL(src.category, dst.category), ISNULL(src.winlostdate, dst.winlostdate), ISNULL(src.matchid, dst.matchid), NULL , NULL , src.cnt , src.chk    , src.binchk       , dst.cnt , dst.chk    , dst.binchk
FROM			#SrcChecksum AS src WITH (NOLOCK)
FULL OUTER JOIN	#DstChecksum AS dst WITH (NOLOCK)
			ON	src.category = dst.category
			AND	src.winlostdate = dst.winlostdate
			AND	src.matchid = dst.matchid
WHERE	src.category IS NULL
	OR	dst.category IS NULL
	OR	src.cnt <> dst.cnt
	OR	src.chk <> dst.chk
	OR	src.binchk <> dst.binchk;

COMMIT;

SELECT	*
FROM	dbo.Task_Sync_ChecksumResult_mnl
WHERE	SessionId = @SessionId;
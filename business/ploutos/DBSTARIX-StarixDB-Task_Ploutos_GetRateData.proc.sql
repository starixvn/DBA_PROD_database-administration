SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	plo.Task_Ploutos_GetRateData
						@From				DATETIME		= NULL
					,	@To					DATETIME		= NULL
AS
/*
	Creator:	20191219@Billy
	Task:		Get Ploutos Rate Statistics Data - [Redmine: #125807]
	Database:	DBSTARIX.StarixDB

	Revisions:
		- 20191219@Billy:	Initial - [Redmine: #125807]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@Query		NVARCHAR(MAX)
		,	@Param		NVARCHAR(MAX)
		,	@ExecuteSP	NVARCHAR(256)
		;

	DECLARE	@_From		DATETIME
		,	@_To		DATETIME
		;

	CREATE TABLE	#TmpData (
						BrandCode		VARCHAR(20)
					,	SecondStamp		INT
					,	DataCount		INT
					,	PRIMARY KEY CLUSTERED (BrandCode, SecondStamp)
					);

	-- Determine data range -- If NULL then get data from the last 10 minutes
	SELECT	@_From	= ISNULL(@From, DATEADD(MINUTE, DATEDIFF(MINUTE, '2000-01-01', GETDATE()) -10, '2000-01-01'))
		,	@_To	= ISNULL(@To, DATEADD(MINUTE, DATEDIFF(MINUTE, '2000-01-01', GETDATE()), '2000-01-01'))
		;

	-- Execute SP --
	SELECT	@ExecuteSP = N'KBTDBPLO.bodb_Ploutos.sys.sp_executesql';

	-- Incoming Ticket Rate --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[BrandCode]		= b.BrandCode
	,	[SecondStamp]	= t.sec
	,	[DataCount]		= COUNT(DISTINCT b.TransactionId)
FROM		dbo.BetTicket AS b WITH (NOLOCK)
CROSS APPLY	(
	SELECT	[sec] = DATEDIFF(SECOND, ''2019-01-01'', b.CreatedDate)
) AS t
WHERE	b.CreatedDate >= @From
	AND	b.CreatedDate < @To
GROUP BY b.BrandCode, t.sec;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@From DATETIME, @To DATETIME';

		TRUNCATE TABLE #TmpData;
		INSERT INTO	#TmpData (BrandCode, SecondStamp, DataCount)
		EXECUTE	@ExecuteSP @Query, @Param, @_From, @_To;

		MERGE INTO	plo.IncomingTicketRate WITH (ROWLOCK) AS rpt
		USING		#TmpData AS src
				ON	rpt.BrandCode = src.BrandCode
				AND	rpt.SecondStamp = src.SecondStamp
		WHEN MATCHED AND rpt.TicketCount <> src.DataCount
			THEN UPDATE SET TicketCount = src.DataCount
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (    BrandCode,     SecondStamp,   TicketCount)
				 VALUES (src.BrandCode, src.SecondStamp, src.DataCount)
		;
	END;

	-- API Pushing Ticket Rate --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[BrandCode]		= b.BrandCode
	,	[SecondStamp]	= t.sec
	,	[DataCount]		= COUNT(DISTINCT b.TransactionId)
FROM		dbo.BetTicket AS b WITH (NOLOCK)
INNER JOIN	dbo.APIHistory_BetTicket_Detail AS h WITH (NOLOCK)
		ON	b.TransactionId = h.TransID
INNER JOIN	dbo.APIHistory_BetTicket_Batch AS _b WITH (NOLOCK)
		ON	h.BatchID = _b.BatchID
CROSS APPLY	(
	SELECT	[sec] = DATEDIFF(SECOND, ''2019-01-01'', _b.ResponseTime)
) AS t
WHERE	_b.ResponseTime >= @From
	AND	_b.ResponseTime < @To
GROUP BY b.BrandCode, t.sec;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@From DATETIME, @To DATETIME';

		TRUNCATE TABLE #TmpData;
		INSERT INTO	#TmpData (BrandCode, SecondStamp, DataCount)
		EXECUTE	@ExecuteSP @Query, @Param, @_From, @_To;

		MERGE INTO	plo.APIPushingTicketRate WITH (ROWLOCK) AS rpt
		USING		#TmpData AS src
				ON	rpt.BrandCode = src.BrandCode
				AND	rpt.SecondStamp = src.SecondStamp
		WHEN MATCHED AND rpt.TicketCount <> src.DataCount
			THEN UPDATE SET TicketCount = src.DataCount
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (    BrandCode,     SecondStamp,   TicketCount)
				 VALUES (src.BrandCode, src.SecondStamp, src.DataCount)
		;
	END;

	-- Incoming Player Rate --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[BrandCode]		= p.BrandCode
	,	[SecondStamp]	= t.sec
	,	[DataCount]		= COUNT(DISTINCT p.CustID)
FROM		dbo.PlayerProfile AS p WITH (NOLOCK)
CROSS APPLY	(
	SELECT	[sec] = DATEDIFF(SECOND, ''2019-01-01'', p.CreatedDate)
) AS t
WHERE	p.CreatedDate >= @From
	AND	p.CreatedDate < @To
GROUP BY p.BrandCode, t.sec;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@From DATETIME, @To DATETIME';

		TRUNCATE TABLE #TmpData;
		INSERT INTO	#TmpData (BrandCode, SecondStamp, DataCount)
		EXECUTE	@ExecuteSP @Query, @Param, @_From, @_To;

		MERGE INTO	plo.IncomingPlayerRate WITH (ROWLOCK) AS rpt
		USING		#TmpData AS src
				ON	rpt.BrandCode = src.BrandCode
				AND	rpt.SecondStamp = src.SecondStamp
		WHEN MATCHED AND rpt.PlayerCount <> src.DataCount
			THEN UPDATE SET PlayerCount = src.DataCount
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (    BrandCode,     SecondStamp,   PlayerCount)
				 VALUES (src.BrandCode, src.SecondStamp, src.DataCount)
		;
	END;

	-- API Pushing Player Rate --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[BrandCode]		= p.BrandCode
	,	[SecondStamp]	= t.sec
	,	[DataCount]		= COUNT(DISTINCT p.CustID)
FROM		dbo.PlayerProfile AS p WITH (NOLOCK)
INNER JOIN	dbo.APIHistory_PlayerProfile AS h WITH (NOLOCK)
		ON	h.PlayerNo = p.CustID
CROSS APPLY	(
	SELECT	[sec] = DATEDIFF(SECOND, ''2019-01-01'', h.ResponseTime)
) AS t
WHERE	h.ResponseTime >= @From
	AND	h.ResponseTime < @To
GROUP BY p.BrandCode, t.sec;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@From DATETIME, @To DATETIME';

		TRUNCATE TABLE #TmpData;
		INSERT INTO	#TmpData (BrandCode, SecondStamp, DataCount)
		EXECUTE	@ExecuteSP @Query, @Param, @_From, @_To;

		MERGE INTO	plo.APIPushingPlayerRate WITH (ROWLOCK) AS rpt
		USING		#TmpData AS src
				ON	rpt.BrandCode = src.BrandCode
				AND	rpt.SecondStamp = src.SecondStamp
		WHEN MATCHED AND rpt.PlayerCount <> src.DataCount
			THEN UPDATE SET PlayerCount = src.DataCount
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (    BrandCode,     SecondStamp,   PlayerCount)
				 VALUES (src.BrandCode, src.SecondStamp, src.DataCount)
		;
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
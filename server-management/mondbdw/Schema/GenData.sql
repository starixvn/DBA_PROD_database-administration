DECLARE	@StartTime	SMALLDATETIME;

IF	OBJECT_ID('tempdb..#TempData') IS NOT NULL
	DROP TABLE	#TempData;
CREATE TABLE	#TempData (
					ServerId		TINYINT
				,	SPId			INT
				,	EventTime		SMALLDATETIME
				,	ExecutionCount	BIGINT
				,	CPUTime			BIGINT
				,	LogicalReads	BIGINT
				,	LogicalWrites	BIGINT
				,	ElapsedTime		BIGINT
				,	PRIMARY KEY CLUSTERED (ServerId, SPID, EventTime)
				);

SELECT	@StartTime = '2019-01-01'

WHILE	0 = 0
BEGIN;
	TRUNCATE TABLE	#TempData;

	IF	@StartTime >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
		BREAK;

	INSERT INTO	#TempData (ServerId, SPID, EventTime, ExecutionCount, CPUTime, LogicalReads, LogicalWrites, ElapsedTime)
	SELECT	r.ServerId, r.SPID, r.EventTime, r.Execution_Count, r.CPU_Time, r.Logical_Reads, r.Logical_Writes, r.Elapsed_Time
	FROM		dbo.Mon_SPPF_Report AS r WITH (NOLOCK)
	INNER JOIN	dbo.vnDBA_SPPF_ServerList_Filtered AS s WITH (NOLOCK)
			ON	r.ServerId = s.ServerId
	WHERE	r.EventTime >= @StartTime
		AND	r.EventTime < DATEADD(HOUR, 1, @StartTime);

	IF	@@ROWCOUNT = 0
		CONTINUE;

	DELETE	dbo.vnDBA_SPPF_HourlySummary_ExecutionCount
	WHERE	EventTime = @StartTime;

	DELETE	dbo.vnDBA_SPPF_HourlySummary_CPUTime
	WHERE	EventTime = @StartTime;

	DELETE	dbo.vnDBA_SPPF_HourlySummary_LogicalReads
	WHERE	EventTime = @StartTime;

	DELETE	dbo.vnDBA_SPPF_HourlySummary_LogicalWrites
	WHERE	EventTime = @StartTime;

	DELETE	dbo.vnDBA_SPPF_HourlySummary_ElapsedTime
	WHERE	EventTime = @StartTime;


	INSERT INTO	dbo.vnDBA_SPPF_HourlySummary_ExecutionCount
		(	ServerId, SPId, EventTime, ValCount, ValSum, ValStdDev, ValMin, ValFirstQuartile, ValMedian, ValThirdQuartile, ValMax)
	SELECT	[ServerId]			= agg.ServerId
		,	[SPId]				= agg.SPId
		,	[EventTime]			= agg.EventTime
		,	[ValCount]			= agg.ValCount
		,	[ValSum]			= agg.ValSum
		,	[ValStdDev]			= agg.ValStdDev
		,	[ValMin]			= agg.ValMin
		,	[ValFirstQuartile]	= FirstQuartile.ExecutionCount
		,	[ValMedian]			= Median.ExecutionCount
		,	[ValThirdQuartile]	= ThirdQuartile.ExecutionCount
		,	[ValMax]			= agg.ValMax
	FROM	(
		SELECT	[ServerId]			= _tmp.ServerId
			,	[SPId]				= _tmp.SPId
			,	[EventTime]			= @StartTime
			,	[ValCount]			= COUNT(1)
			,	[ValSum]			= SUM(_tmp.ExecutionCount)
			,	[ValStdDev]			= STDEV(_tmp.ExecutionCount)
			,	[ValMin]			= MIN(_tmp.ExecutionCount)
			,	[ValMax]			= MAX(_tmp.ExecutionCount)
		FROM	#TempData AS _tmp
		GROUP BY _tmp.ServerId, _tmp.SPId
	) AS agg
	CROSS APPLY	(
		SELECT	_ana.ExecutionCount
		FROM	(
			SELECT	_rn.ExecutionCount, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.ExecutionCount ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.25)
	) AS FirstQuartile
	CROSS APPLY	(
		SELECT	_ana.ExecutionCount
		FROM	(
			SELECT	_rn.ExecutionCount, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.ExecutionCount ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.5)
	) AS Median
	CROSS APPLY	(
		SELECT	_ana.ExecutionCount
		FROM	(
			SELECT	_rn.ExecutionCount, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.ExecutionCount ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.75)
	) AS ThirdQuartile;


	INSERT INTO	dbo.vnDBA_SPPF_HourlySummary_CPUTime
		(	ServerId, SPId, EventTime, ValCount, ValSum, ValStdDev, ValMin, ValFirstQuartile, ValMedian, ValThirdQuartile, ValMax)
	SELECT	[ServerId]			= agg.ServerId
		,	[SPId]				= agg.SPId
		,	[EventTime]			= agg.EventTime
		,	[ValCount]			= agg.ValCount
		,	[ValSum]			= agg.ValSum
		,	[ValStdDev]			= agg.ValStdDev
		,	[ValMin]			= agg.ValMin
		,	[ValFirstQuartile]	= FirstQuartile.CPUTime
		,	[ValMedian]			= Median.CPUTime
		,	[ValThirdQuartile]	= ThirdQuartile.CPUTime
		,	[ValMax]			= agg.ValMax
	FROM	(
		SELECT	[ServerId]			= _tmp.ServerId
			,	[SPId]				= _tmp.SPId
			,	[EventTime]			= @StartTime
			,	[ValCount]			= COUNT(1)
			,	[ValSum]			= SUM(_tmp.CPUTime)
			,	[ValStdDev]			= STDEV(_tmp.CPUTime)
			,	[ValMin]			= MIN(_tmp.CPUTime)
			,	[ValMax]			= MAX(_tmp.CPUTime)
		FROM	#TempData AS _tmp
		GROUP BY _tmp.ServerId, _tmp.SPId
	) AS agg
	CROSS APPLY	(
		SELECT	_ana.CPUTime
		FROM	(
			SELECT	_rn.CPUTime, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.CPUTime ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.25)
	) AS FirstQuartile
	CROSS APPLY	(
		SELECT	_ana.CPUTime
		FROM	(
			SELECT	_rn.CPUTime, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.CPUTime ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.5)
	) AS Median
	CROSS APPLY	(
		SELECT	_ana.CPUTime
		FROM	(
			SELECT	_rn.CPUTime, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.CPUTime ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.75)
	) AS ThirdQuartile;


	INSERT INTO	dbo.vnDBA_SPPF_HourlySummary_LogicalReads
		(	ServerId, SPId, EventTime, ValCount, ValSum, ValStdDev, ValMin, ValFirstQuartile, ValMedian, ValThirdQuartile, ValMax)
	SELECT	[ServerId]			= agg.ServerId
		,	[SPId]				= agg.SPId
		,	[EventTime]			= agg.EventTime
		,	[ValCount]			= agg.ValCount
		,	[ValSum]			= agg.ValSum
		,	[ValStdDev]			= agg.ValStdDev
		,	[ValMin]			= agg.ValMin
		,	[ValFirstQuartile]	= FirstQuartile.LogicalReads
		,	[ValMedian]			= Median.LogicalReads
		,	[ValThirdQuartile]	= ThirdQuartile.LogicalReads
		,	[ValMax]			= agg.ValMax
	FROM	(
		SELECT	[ServerId]			= _tmp.ServerId
			,	[SPId]				= _tmp.SPId
			,	[EventTime]			= @StartTime
			,	[ValCount]			= COUNT(1)
			,	[ValSum]			= SUM(_tmp.LogicalReads)
			,	[ValStdDev]			= STDEV(_tmp.LogicalReads)
			,	[ValMin]			= MIN(_tmp.LogicalReads)
			,	[ValMax]			= MAX(_tmp.LogicalReads)
		FROM	#TempData AS _tmp
		GROUP BY _tmp.ServerId, _tmp.SPId
	) AS agg
	CROSS APPLY	(
		SELECT	_ana.LogicalReads
		FROM	(
			SELECT	_rn.LogicalReads, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.LogicalReads ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.25)
	) AS FirstQuartile
	CROSS APPLY	(
		SELECT	_ana.LogicalReads
		FROM	(
			SELECT	_rn.LogicalReads, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.LogicalReads ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.5)
	) AS Median
	CROSS APPLY	(
		SELECT	_ana.LogicalReads
		FROM	(
			SELECT	_rn.LogicalReads, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.LogicalReads ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.75)
	) AS ThirdQuartile;


	INSERT INTO	dbo.vnDBA_SPPF_HourlySummary_LogicalWrites
		(	ServerId, SPId, EventTime, ValCount, ValSum, ValStdDev, ValMin, ValFirstQuartile, ValMedian, ValThirdQuartile, ValMax)
	SELECT	[ServerId]			= agg.ServerId
		,	[SPId]				= agg.SPId
		,	[EventTime]			= agg.EventTime
		,	[ValCount]			= agg.ValCount
		,	[ValSum]			= agg.ValSum
		,	[ValStdDev]			= agg.ValStdDev
		,	[ValMin]			= agg.ValMin
		,	[ValFirstQuartile]	= FirstQuartile.LogicalWrites
		,	[ValMedian]			= Median.LogicalWrites
		,	[ValThirdQuartile]	= ThirdQuartile.LogicalWrites
		,	[ValMax]			= agg.ValMax
	FROM	(
		SELECT	[ServerId]			= _tmp.ServerId
			,	[SPId]				= _tmp.SPId
			,	[EventTime]			= @StartTime
			,	[ValCount]			= COUNT(1)
			,	[ValSum]			= SUM(_tmp.LogicalWrites)
			,	[ValStdDev]			= STDEV(_tmp.LogicalWrites)
			,	[ValMin]			= MIN(_tmp.LogicalWrites)
			,	[ValMax]			= MAX(_tmp.LogicalWrites)
		FROM	#TempData AS _tmp
		GROUP BY _tmp.ServerId, _tmp.SPId
	) AS agg
	CROSS APPLY	(
		SELECT	_ana.LogicalWrites
		FROM	(
			SELECT	_rn.LogicalWrites, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.LogicalWrites ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.25)
	) AS FirstQuartile
	CROSS APPLY	(
		SELECT	_ana.LogicalWrites
		FROM	(
			SELECT	_rn.LogicalWrites, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.LogicalWrites ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.5)
	) AS Median
	CROSS APPLY	(
		SELECT	_ana.LogicalWrites
		FROM	(
			SELECT	_rn.LogicalWrites, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.LogicalWrites ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.75)
	) AS ThirdQuartile;


	INSERT INTO	dbo.vnDBA_SPPF_HourlySummary_ElapsedTime
		(	ServerId, SPId, EventTime, ValCount, ValSum, ValStdDev, ValMin, ValFirstQuartile, ValMedian, ValThirdQuartile, ValMax)
	SELECT	[ServerId]			= agg.ServerId
		,	[SPId]				= agg.SPId
		,	[EventTime]			= agg.EventTime
		,	[ValCount]			= agg.ValCount
		,	[ValSum]			= agg.ValSum
		,	[ValStdDev]			= agg.ValStdDev
		,	[ValMin]			= agg.ValMin
		,	[ValFirstQuartile]	= FirstQuartile.ElapsedTime
		,	[ValMedian]			= Median.ElapsedTime
		,	[ValThirdQuartile]	= ThirdQuartile.ElapsedTime
		,	[ValMax]			= agg.ValMax
	FROM	(
		SELECT	[ServerId]			= _tmp.ServerId
			,	[SPId]				= _tmp.SPId
			,	[EventTime]			= @StartTime
			,	[ValCount]			= COUNT(1)
			,	[ValSum]			= SUM(_tmp.ElapsedTime)
			,	[ValStdDev]			= STDEV(_tmp.ElapsedTime)
			,	[ValMin]			= MIN(_tmp.ElapsedTime)
			,	[ValMax]			= MAX(_tmp.ElapsedTime)
		FROM	#TempData AS _tmp
		GROUP BY _tmp.ServerId, _tmp.SPId
	) AS agg
	CROSS APPLY	(
		SELECT	_ana.ElapsedTime
		FROM	(
			SELECT	_rn.ElapsedTime, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.ElapsedTime ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.25)
	) AS FirstQuartile
	CROSS APPLY	(
		SELECT	_ana.ElapsedTime
		FROM	(
			SELECT	_rn.ElapsedTime, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.ElapsedTime ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.5)
	) AS Median
	CROSS APPLY	(
		SELECT	_ana.ElapsedTime
		FROM	(
			SELECT	_rn.ElapsedTime, [rn] = ROW_NUMBER() OVER(ORDER BY _rn.ElapsedTime ASC)
			FROM	#TempData AS _rn
			WHERE	_rn.ServerId = agg.ServerId
				AND	_rn.SPId = agg.SPId
		) AS _ana
		WHERE	_ana.rn = FLOOR(agg.ValCount * 0.75)
	) AS ThirdQuartile;

	SELECT	@StartTime = DATEADD(HOUR, 1, @StartTime);
	PRINT	'-------------------------------------------------------------------------------------------------------------------';
	RAISERROR('', 0, 0) WITH NOWAIT;
END;
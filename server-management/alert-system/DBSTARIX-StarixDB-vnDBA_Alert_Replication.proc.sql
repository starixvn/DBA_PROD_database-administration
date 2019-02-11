SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_Alert_Replication
AS
/*
	Creator:	20190124@Billy
	Task:		Alert Procedure for Replication - [Redmine: #107814]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20190124@Billy:	Initial - [Redmine: #107814]
		- 20190201@Billy:	Replication Monitor Phase 2 - [Redmine: #107814]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;
	SET DATEFIRST 7; -- First day of week is SUNDAY

	-- Variables --
	DECLARE	@CounterName	VARCHAR(1024)
		,	@Now			DATETIME
		,	@Today			DATETIME
		,	@Case			TINYINT
		;

	DECLARE	@Msg			NVARCHAR(MAX)
		;

	DECLARE	@ReplInstances AS TABLE (
				Publisher		NVARCHAR(128)
			,	PublishDB		NVARCHAR(128)
			,	Publication		NVARCHAR(128)
			,	Subscriber		NVARCHAR(128)
			,	CounterId		INT
			,	PRIMARY KEY CLUSTERED (CounterId)
			);

	DECLARE	@RegularJobs AS TABLE (
				ScheduleId		INT
			,	ServerName		NVARCHAR(128)
			,	JobName			NVARCHAR(128)
			,	StartTime		DATETIME
			,	AvgEndTime		DATETIME
			,	MaxEndTime		DATETIME
			);

	DECLARE	@Results AS TABLE (
				Publisher		NVARCHAR(128)
			,	PublishDB		NVARCHAR(128)
			,	Publication		NVARCHAR(128)
			,	Subscriber		NVARCHAR(128)
			,	CounterTime		DATETIME
			,	ViolatedCnt		INT
			,	CounterValue	BIGINT
			,	AlertCase		TINYINT
			,	Status			CHAR(1)
			);

	-- Initials --
	SELECT	@CounterName = 'Dist:Delivery Latency'
		,	@Now = GETDATE()
		,	@Today = CAST(GETDATE() AS DATE)
		;

	-- Get latest replication instances
	INSERT INTO	@ReplInstances (Publisher, PublishDB, Publication, Subscriber, CounterId)
	SELECT	[Publisher]		= publisher.val
		,	[PublishDB]		= publishdb.val
		,	[Publication]	= publication.val
		,	[Subscriber]	= subscriber.val
		,	[CounterID]		= MAX(c.CounterID)
	FROM		dbo.CounterDetails AS c WITH (NOLOCK)
	CROSS APPLY	dbo.tf_SplitString(c.InstanceName, '-', 1) AS publisher
	CROSS APPLY	dbo.tf_SplitString(c.InstanceName, '-', 2) AS publishdb
	CROSS APPLY	dbo.tf_SplitString(c.InstanceName, '-', 3) AS publication
	CROSS APPLY	dbo.tf_SplitString(c.InstanceName, '-', 4) AS subscriber
	WHERE	c.CounterName = @CounterName
	GROUP BY publisher.val, publishdb.val, publication.val, subscriber.val;

	-- Check regular job schedule --
	INSERT INTO	@RegularJobs (ScheduleId, ServerName, JobName, StartTime, AvgEndTime, MaxEndTime)
	SELECT	[ScheduleId]	= js.ScheduleId
		,	[ServerName]	= js.ServerName
		,	[JobName]		= js.JobName
		,	[StartTime]		= today.StartTime
		,	[AvgEndTime]	= today.AvgEndTime
		,	[MaxEndTime]	= today.MaxEndTime
	FROM	dbo.vnDBA_Alert_RegularJobSchedules AS js WITH (NOLOCK)
	CROSS APPLY	(
		SELECT	[StartTime] = @Today + CAST(js.StartTime AS DATETIME)
			,	[AvgEndTime] = DATEADD(SECOND, js.AvgDuration, @Today + CAST(js.StartTime AS DATETIME))
			,	[MaxEndTime] = DATEADD(SECOND, js.MaxDuration, @Today + CAST(js.StartTime AS DATETIME))
	) AS today
	WHERE	js.StartWeekDay & POWER(2, DATEPART(WEEKDAY, @Today)) <> 0
		AND	@Now BETWEEN today.StartTime AND today.AvgEndTime;

	-- Check Replication Latency --
	INSERT INTO	@Results
		(	   Publisher,    PublishDB,    Publication,    Subscriber,   CounterTime,   ViolatedCnt,      CounterValue,     AlertCase)
	SELECT	ri.Publisher, ri.PublishDB, ri.Publication, ri.Subscriber, d.CounterTime, d.ViolatedCnt, d.MaxCounterValue, ars.AlertCase
	FROM		@ReplInstances AS ri
	INNER JOIN	dbo.vnDBA_Alert_Repl_Publications AS arp WITH (NOLOCK)
			ON	ri.Publication = arp.Publication
	INNER JOIN	dbo.vnDBA_Alert_Repl_Subsribers AS ars WITH (NOLOCK)
			ON	ri.Subscriber = ars.Subscriber
	INNER JOIN	dbo.vnDBA_Alert_Repl_Thresholds AS art WITH (NOLOCK)
			ON	art.AlertLevel = CASE WHEN arp.AlertLevel > ars.AlertLevel THEN arp.AlertLevel ELSE ars.AlertLevel END
	CROSS APPLY	(
		SELECT	[Threshold]			= CASE WHEN EXISTS (SELECT 1 FROM @RegularJobs) THEN art.RegTimeThreshold ELSE art.TimeThreshold END
	) AS th
	CROSS APPLY	(
		SELECT	[CounterTime]		= MIN(_ad.CounterTime)
			,	[ViolatedCnt]		= SUM(_ad.Violated)
			,	[MaxCounterValue]	= MAX(_ad.CounterValue)
		FROM	(
			SELECT	TOP(art.Samples)
					_d.CounterTime
				,	_d.CounterValue
				,	[Violated] = CASE WHEN _d.CounterValue > th.Threshold THEN 1 ELSE 0 END
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = ri.CounterId
			ORDER BY _d.CounterTime DESC
		) AS _ad
	) AS d
	WHERE	d.ViolatedCnt > art.Violates
		AND	d.CounterTime > DATEADD(SECOND, -5 * (art.Samples + 2), @Now);

	-- Check Ticket Latency --
	INSERT INTO	@Results
		(	 Publisher, PublishDB,       Publication,     Subscriber,   CounterTime,   ViolatedCnt,      CounterValue,     AlertCase)
	SELECT	N'DBTRANS', N'bodb02', N'Ticket Latency', ars.Subscriber, d.CounterTime, d.ViolatedCnt, d.MaxCounterValue, ars.AlertCase
	FROM		dbo.vnDBA_Alert_Repl_Subsribers AS ars WITH (NOLOCK)
	INNER JOIN	dbo.vnDBA_Alert_Repl_Thresholds AS art WITH (NOLOCK)
			ON	art.AlertLevel = ars.AlertLevel
	CROSS APPLY	(
		SELECT	[Threshold]			= CASE WHEN EXISTS (SELECT 1 FROM @RegularJobs) THEN art.RegIdThreshold ELSE art.IdThreshold END
	) AS th
	CROSS APPLY	(
		SELECT	[CounterTime]		= MIN(_ad.CounterTime)
			,	[ViolatedCnt]		= SUM(_ad.Violated)
			,	[MaxCounterValue]	= MAX(_ad.CounterValue)
		FROM	(
			SELECT	[CounterTime]	= txn.CaptureTime
				,	[CounterValue]	= txn.LastTicketId - d.LastTicketId
				,	[Violated]		= CASE WHEN txn.LastTicketId - d.LastTicketId > th.Threshold THEN 1 ELSE 0 END
			FROM	(
				SELECT	TOP(art.Samples)
						_txn.CaptureTime, _txn.LastTicketId
				FROM	dbo.vnDBA_Monitor_TicketLatency AS _txn WITH (NOLOCK)
				WHERE	_txn.ServerName = N'DBTRANS'
				ORDER BY _txn.CaptureTime DESC
			) AS txn
			CROSS APPLY	(
				SELECT	_d.LastTicketId
				FROM	dbo.vnDBA_Monitor_TicketLatency AS _d WITH (NOLOCK)
				WHERE	_d.ServerName = ars.Subscriber
					AND	_d.CaptureTime BETWEEN DATEADD(SECOND, -2, txn.CaptureTime) AND DATEADD(SECOND, 2, txn.CaptureTime)
			) AS d
		) AS _ad
	) AS d
	WHERE	d.ViolatedCnt > art.Violates
		AND	d.CounterTime > DATEADD(SECOND, -5 * (art.Samples + 2), @Now);

	-- Alerting --
	UPDATE	r
	SET		Status = CASE WHEN arr.CounterTime IS NULL THEN '+' WHEN ABS(DATEDIFF(SECOND, arr.CounterTime, r.CounterTime)) >= art.AlertInterval THEN '|' ELSE N'' END
	FROM		@Results AS r
	LEFT JOIN	dbo.vnDBA_Alert_Repl_Result AS arr WITH (NOLOCK)
			ON	r.Publisher = arr.Publisher
			AND	r.PublishDB = arr.PublishDB
			AND	r.Publication = arr.Publication
			AND	r.Subscriber = arr.Subscriber
	INNER JOIN	dbo.vnDBA_Alert_Repl_Publications AS arp WITH (NOLOCK)
			ON	r.Publication = arp.Publication
	INNER JOIN	dbo.vnDBA_Alert_Repl_Subsribers AS ars WITH (NOLOCK)
			ON	r.Subscriber = ars.Subscriber
	INNER JOIN	dbo.vnDBA_Alert_Repl_Thresholds AS art WITH (NOLOCK)
			ON	art.AlertLevel = CASE WHEN arp.AlertLevel > ars.AlertLevel THEN arp.AlertLevel ELSE ars.AlertLevel END;

	INSERT INTO	@Results
		(	    Publisher,     PublishDB,     Publication,     Subscriber,     CounterTime, ViolatedCnt, CounterValue,     AlertCase, Status)
	SELECT	arr.Publisher, arr.PublishDB, arr.Publication, arr.Subscriber,            @Now,        NULL,         NULL, arr.AlertCase,    '-'
	FROM		@Results AS r
	RIGHT JOIN	dbo.vnDBA_Alert_Repl_Result AS arr WITH (NOLOCK)
			ON	r.Publisher = arr.Publisher
			AND	r.PublishDB = arr.PublishDB
			AND	r.Publication = arr.Publication
			AND	r.Subscriber = arr.Subscriber
	WHERE	r.CounterTime IS NULL;

	IF	EXISTS (SELECT 1 FROM @Results WHERE Status <> N'')
	BEGIN;
		-- Send to VN room --
		SELECT	@Case = 1;

		IF	EXISTS (SELECT 1 FROM @Results WHERE AlertCase & @Case <> 0)
		BEGIN;
			SELECT	@Msg = N'(policecar)  REPLICATION DELAY  (policecar)' + ISNULL(js.str, N'') + rss.str
			FROM	(
				SELECT	N'
[' + j.JobName + N']: ' + CONVERT(NVARCHAR(MAX), j.StartTime, 120) + N' ~ ' + CONVERT(NVARCHAR(MAX), j.AvgEndTime, 120) + N' GMT-4'
				FROM	@RegularJobs AS j
				FOR XML PATH ('')
				,	TYPE
			) AS xj(xml)
			CROSS APPLY	(
				SELECT	xj.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS js(str)
			CROSS APPLY	(
				SELECT	N'

[' + rp.Publication + N']' + N' @ (' + CONVERT(NVARCHAR(MAX), rp.CounterTime, 120) + N') GMT-4' + _rs.str
				FROM	(
					SELECT	TOP(1000)
							_rp.Publisher, _rp.PublishDB, _rp.Publication, [CounterTime] = CAST(AVG(CAST(_rp.CounterTime AS DECIMAL(19,8))) AS DATETIME)
					FROM	@Results AS _rp
					WHERE	_rp.AlertCase & @Case <> 0
					GROUP BY _rp.Publisher, _rp.PublishDB, _rp.Publication
					ORDER BY CASE _rp.Publisher WHEN N'DBTRANS' THEN 1 WHEN N'DBCUST' THEN 2 ELSE 3 END, CASE _rp.Publication WHEN N'Ticket Latency' THEN 1 ELSE 2 END, _rp.Publication
				) AS rp
				CROSS APPLY	(
					SELECT	N'
    \- ' + f.formater + _rs.Subscriber + CASE _rs.Status WHEN '-' THEN N'' ELSE N': ' END + CASE _rs.Publication WHEN N'Ticket Latency' THEN CAST(ISNULL(_rs.CounterValue, N'') AS NVARCHAR(MAX)) ELSE ISNULL(dr.duration, N'') END + f.formater
					FROM		@Results AS _rs
					CROSS APPLY	(
						SELECT	[formater] = CASE _rs.Status WHEN '+' THEN N'__' WHEN '-' THEN N'~~' ELSE N'' END
					) AS f
					OUTER APPLY	dbo.tf_Format_Duration(_rs.CounterValue / 1000, 0) AS dr
					WHERE	_rs.Publisher = rp.Publisher
						AND	_rs.PublishDB = rp.PublishDB
						AND	_rs.Publication = rp.Publication
						AND	_rs.AlertCase & @Case <> 0
					ORDER BY _rs.Subscriber
					FOR XML PATH ('')
					,	TYPE
				) AS _xrs(xml)
				CROSS APPLY	(
					SELECT	_xrs.xml.value('.[1]', 'NVARCHAR(MAX)')
				) AS _rs(str)
				FOR XML PATH ('')
				,	TYPE
			) AS xrs(xml)
			CROSS APPLY	(
				SELECT	xrs.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS rss(str);

			EXECUTE	DBMONDW.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = N'STANDBY', @JobId = NULL, @JobName = N'Standby Alert', @Message = @Msg, @isSimple = 1, @CaseId = @Case;
		END;

		-- Send to TW room --
		SELECT	@Case = 2;

		IF	EXISTS (SELECT 1 FROM @Results WHERE AlertCase & @Case <> 0)
		BEGIN;
			SELECT	@Msg = N'(policecar)  REPLICATION DELAY  (policecar)' + ISNULL(js.str, N'') + rss.str
			FROM	(
				SELECT	N'
[' + j.JobName + N']: ' + CONVERT(NVARCHAR(MAX), j.StartTime, 120) + N' ~ ' + CONVERT(NVARCHAR(MAX), j.AvgEndTime, 120) + N' GMT-4'
				FROM	@RegularJobs AS j
				FOR XML PATH ('')
				,	TYPE
			) AS xj(xml)
			CROSS APPLY	(
				SELECT	xj.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS js(str)
			CROSS APPLY	(
				SELECT	N'

[' + rp.Publication + N']' + N' @ (' + CONVERT(NVARCHAR(MAX), rp.CounterTime, 120) + N') GMT-4' + _rs.str
				FROM	(
					SELECT	TOP(1000)
							_rp.Publisher, _rp.PublishDB, _rp.Publication, [CounterTime] = CAST(AVG(CAST(_rp.CounterTime AS DECIMAL(19,8))) AS DATETIME)
					FROM	@Results AS _rp
					WHERE	_rp.AlertCase & @Case <> 0
					GROUP BY _rp.Publisher, _rp.PublishDB, _rp.Publication
					ORDER BY CASE _rp.Publisher WHEN N'DBTRANS' THEN 1 WHEN N'DBCUST' THEN 2 ELSE 3 END, CASE _rp.Publication WHEN N'Ticket Latency' THEN 1 ELSE 2 END, _rp.Publication
				) AS rp
				CROSS APPLY	(
					SELECT	N'
    \- ' + f.formater + _rs.Subscriber + CASE _rs.Status WHEN '-' THEN N'' ELSE N': ' END + CASE _rs.Publication WHEN N'Ticket Latency' THEN CAST(ISNULL(_rs.CounterValue, N'') AS NVARCHAR(MAX)) ELSE ISNULL(dr.duration, N'') END + f.formater
					FROM		@Results AS _rs
					CROSS APPLY	(
						SELECT	[formater] = CASE _rs.Status WHEN '+' THEN N'__' WHEN '-' THEN N'~~' ELSE N'' END
					) AS f
					OUTER APPLY	dbo.tf_Format_Duration(_rs.CounterValue / 1000, 0) AS dr
					WHERE	_rs.Publisher = rp.Publisher
						AND	_rs.PublishDB = rp.PublishDB
						AND	_rs.Publication = rp.Publication
						AND	_rs.AlertCase & @Case <> 0
					ORDER BY _rs.Subscriber
					FOR XML PATH ('')
					,	TYPE
				) AS _xrs(xml)
				CROSS APPLY	(
					SELECT	_xrs.xml.value('.[1]', 'NVARCHAR(MAX)')
				) AS _rs(str)
				FOR XML PATH ('')
				,	TYPE
			) AS xrs(xml)
			CROSS APPLY	(
				SELECT	xrs.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS rss(str);

			EXECUTE	DBMONDW.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = N'STANDBY', @JobId = NULL, @JobName = N'Standby Alert', @Message = @Msg, @isSimple = 1, @CaseId = @Case;
		END;

		BEGIN TRANSACTION;
		TRUNCATE TABLE	dbo.vnDBA_Alert_Repl_Result;
		INSERT INTO	dbo.vnDBA_Alert_Repl_Result
			(	  Publisher,   PublishDB,   Publication,   Subscriber,   CounterTime,   AlertCase)
		SELECT	r.Publisher, r.PublishDB, r.Publication, r.Subscriber, r.CounterTime, r.AlertCase
		FROM	@Results AS r
		WHERE	ISNULL(r.Status, '') NOT IN ('-');
		COMMIT;
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
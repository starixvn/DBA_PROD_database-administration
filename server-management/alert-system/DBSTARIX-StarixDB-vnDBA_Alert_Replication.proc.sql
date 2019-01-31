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
			
	DECLARE	@Thresholds AS TABLE (
				AlertType		NVARCHAR(128)
			,	Samples			INT
			,	Threshold		DECIMAL(19, 8)
			,	Method			NVARCHAR(128)
			,	Pattern			VARCHAR(MAX)
			);

	DECLARE	@Results AS TABLE (
				Publisher		NVARCHAR(128)
			,	PublishDB		NVARCHAR(128)
			,	Publication		NVARCHAR(128)
			,	Subscriber		NVARCHAR(128)
			,	CounterTime		DATETIME
			,	ViolatedCnt		INT
			,	MaxCounterValue	BIGINT
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

	-- Get threshold --
	IF	EXISTS (SELECT 1 FROM @RegularJobs)
	BEGIN;
		INSERT INTO	@Thresholds
			(	   AlertType,    Samples,           Threshold,    Method,    Pattern)
		SELECT	th.AlertType, th.Samples, th.RegularThreshold, th.Method, th.Pattern
		FROM	dbo.vnDBA_Alert_Thresholds AS th WITH (NOLOCK)
		WHERE	th.AlertType IN (N'Replication Latency', N'Ticket Latency');
	END;
	ELSE
	BEGIN;
		INSERT INTO	@Thresholds
			(	   AlertType,    Samples,    Threshold,    Method,    Pattern)
		SELECT	th.AlertType, th.Samples, th.Threshold, th.Method, th.Pattern
		FROM	dbo.vnDBA_Alert_Thresholds AS th WITH (NOLOCK)
		WHERE	th.AlertType IN (N'Replication Latency', N'Ticket Latency');
	END;

	-- Check Replication Latency --
	INSERT INTO	@Results (Publisher, PublishDB, Publication, Subscriber, CounterTime, ViolatedCnt, MaxCounterValue)
	SELECT	ri.Publisher, ri.PublishDB, ri.Publication, ri.Subscriber, d.CounterTime, d.ViolatedCnt, d.MaxCounterValue
	FROM		@ReplInstances AS ri
	CROSS APPLY	(
		SELECT	TOP(1)
				_th.Samples, _th.Threshold
		FROM	@Thresholds AS _th
		WHERE	_th.AlertType = N'Replication Latency'
	) AS th
	CROSS APPLY	(
		SELECT	[CounterTime]		= MIN(_ad.CounterTime)
			,	[ViolatedCnt]		= SUM(_ad.Violated)
			,	[MaxCounterValue]	= MAX(_ad.CounterValue)
		FROM	(
			SELECT	TOP(th.Samples)
					_d.CounterTime
				,	_d.CounterValue
				,	[Violated] = CASE WHEN _d.CounterValue > th.Threshold THEN 1 ELSE 0 END
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = ri.CounterId
			ORDER BY _d.CounterTime DESC
		) AS _ad
	) AS d
	WHERE	d.ViolatedCnt > 0
		AND	d.CounterTime > DATEADD(SECOND, -5 * (th.Samples + 2), @Now);

	-- Check Ticket Latency --
	INSERT INTO	@Results (Publisher, PublishDB, Publication, Subscriber, CounterTime, ViolatedCnt, MaxCounterValue)
	SELECT	N'DBTRANS', N'bodb02', N'Ticket Latency', tl.ServerName, tl.CounterTime, tl.ViolatedCnt, tl.MaxCounterValue
	FROM		@Thresholds AS th
	CROSS APPLY	(
		SELECT	[ServerName]		= _ad.ServerName
			,	[CounterTime]		= MIN(_ad.CounterTime)
			,	[ViolatedCnt]		= SUM(_ad.Violated)
			,	[MaxCounterValue]	= MAX(_ad.CounterValue)
		FROM	(
			SELECT	[ServerName]	= d.ServerName
				,	[CounterTime]	= txn.CaptureTime
				,	[CounterValue]	= txn.LastTicketId - d.LastTicketId
				,	[Violated]		= CASE WHEN txn.LastTicketId - d.LastTicketId > th.Threshold THEN 1 ELSE 0 END
			FROM	(
				SELECT	TOP(th.Samples)
						_txn.CaptureTime, _txn.LastTicketId
				FROM	dbo.vnDBA_Monitor_TicketLatency AS _txn WITH (NOLOCK)
				WHERE	_txn.ServerName = N'DBTRANS'
				ORDER BY _txn.CaptureTime DESC
			) AS txn
			CROSS APPLY	(
				SELECT	_d.ServerName, _d.LastTicketId
				FROM	dbo.vnDBA_Monitor_TicketLatency AS _d WITH (NOLOCK)
				WHERE	_d.CaptureTime BETWEEN DATEADD(SECOND, -2, txn.CaptureTime) AND DATEADD(SECOND, 2, txn.CaptureTime)
					AND	_d.ServerName <> N'DBTRANS'
			) AS d
		) AS _ad
		GROUP BY _ad.ServerName
	) AS tl
	WHERE	tl.ViolatedCnt > 0
		AND	tl.CounterTime > DATEADD(SECOND, -5 * (th.Samples + 2), @Now)
		AND	th.AlertType = N'Ticket Latency';


	-- Alerting --
	IF	EXISTS (SELECT 1 FROM @Results WHERE Subscriber <> N'DB05')
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
				GROUP BY _rp.Publisher, _rp.PublishDB, _rp.Publication
				ORDER BY CASE _rp.Publisher WHEN N'DBTRANS' THEN 1 WHEN N'DBCUST' THEN 2 ELSE 3 END, CASE _rp.Publication WHEN N'Ticket Latency' THEN 1 ELSE 2 END
			) AS rp
			CROSS APPLY	(
				SELECT	N'
    \- ' + _rs.Subscriber + N': ' + CASE _rs.Publication WHEN N'Ticket Latency' THEN CAST(_rs.MaxCounterValue AS NVARCHAR(MAX)) ELSE dr.duration END
				FROM		@Results AS _rs
				CROSS APPLY	dbo.tf_Format_Duration(_rs.MaxCounterValue / 1000, 0) AS dr
				WHERE	_rs.Publisher = rp.Publisher
					AND	_rs.PublishDB = rp.PublishDB
					AND	_rs.Publication = rp.Publication
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

		EXECUTE	DBMONDW.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = N'STANDBY', @JobId = NULL, @JobName = N'Standby Alert', @Message = @Msg, @isSimple = 1, @CaseId = 1;
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
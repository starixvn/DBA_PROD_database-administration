USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_WarningStateCaptureRequests
					@get_system_request			BIT				= 0
AS
/*
	Creator:	20180704@Billy
	Task:		Capture Warning State information - Requests - [Redmine: #00000]
	Database:	MonDB

	Revisions:
		- 20180704@Billy:	Initialize - [Redmine: #00000]
*/
BEGIN;
	SET NOCOUNT ON;

	SELECT	[ServerName]			= @@SERVERNAME
		,	[CaptureDate]			= GETDATE()
		,	[SessionId]				= rqs.session_id
		,	[BlockingSession]		= rqs.blocking_session_id
		,	[DB]					= DB_NAME(ISNULL(stx.dbid ,rqs.database_id))
		,	[ObjectName]			= ISNULL(OBJECT_NAME(stx.objectid, stx.dbid), SUBSTRING(LTRIM(stx.text), rqs.statement_start_offset / 2, CASE WHEN rqs.statement_end_offset <= 0 THEN LEN(stx.text) ELSE rqs.statement_end_offset / 2 END - rqs.statement_start_offset / 2 + 1))
		,	[WaitType]				= rqs.wait_type
		,	[WaitTime]				= rqs.wait_time
		,	[WaitResource]			= rqs.wait_resource
		,	[CPUTime]				= rqs.cpu_time
		,	[ElapsedTime]			= rqs.total_elapsed_time
		,	[DOP]					= qmg.dop
		,	[GrantedMemoryKB]		= qmg.granted_memory_kb
		,	[UsedMemoryKB]			= qmg.used_memory_kb
		,	[RequestId]				= rqs.request_id
		,	[Reads]					= rqs.reads
		,	[LogicalReads]			= rqs.logical_reads
		,	[Writes]				= rqs.writes
		,	[PercentComplete]		= rqs.percent_complete
		,	[RunningStartOffset]	= rqs.statement_start_offset
		,	[RequestStart]			= rqs.start_time
		,	[RequestStatus]			= rqs.status
		,	[RequestCommand]		= rqs.command
		,	[SchedulerId]			= rqs.scheduler_id
		,	[HostName]				= sss.host_name
		,	[Program]				= sss.program_name
		,	[LoginName]				= sss.login_name
		,	[SessionStatus]			= sss.status
	FROM		sys.dm_exec_requests AS rqs WITH (NOLOCK)
	OUTER APPLY	sys.dm_exec_sql_text(rqs.sql_handle) AS stx
	OUTER APPLY	sys.dm_exec_text_query_plan(rqs.plan_handle, rqs.statement_start_offset, rqs.statement_end_offset) AS qrp
	LEFT JOIN	sys.dm_exec_sessions AS sss WITH (NOLOCK)
			ON	rqs.session_id = sss.session_id
	LEFT JOIN	sys.dm_exec_query_memory_grants AS qmg WITH (NOLOCK)
			ON	rqs.session_id = qmg.session_id
			AND	rqs.request_id = qmg.request_id
	WHERE	rqs.session_id <> @@SPID
		AND	rqs.session_id > CASE @get_system_request WHEN 1 THEN 50 ELSE 0 END
		AND	rqs.command NOT IN ('RESOURCE MONITOR', 'LAZY WRITER', 'TASK MANAGER', 'XE TIMER', 'XE DISPATCHER');
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Monitor_WarningStateCaptureRequests TO sqlLink AS dbo;
GO
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureRequests
BY CERTIFICATE serverlevel_cert
WITH PASSWORD = '!@h19hPrIv()';
GO

USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_WarningStateCaptureSchedulers
AS
/*
	Creator:	20180704@Billy
	Task:		Capture Warning State information - Schedulers - [Redmine: #00000]
	Database:	MonDB

	Revisions:
		- 20180704@Billy:	Initialize - [Redmine: #00000]
*/
BEGIN;
	SET NOCOUNT ON;

	SELECT	[ServerName]			= @@SERVERNAME
		,	[CaptureDate]			= GETDATE()
		,	[SchedulerId]			= sch.scheduler_id
		,	[CPUId]					= sch.cpu_id
		,	[CurrentTasks]			= sch.current_tasks_count
		,	[RunnableTasks]			= sch.runnable_tasks_count
		,	[PendingTasks]			= sch.work_queue_count
		,	[ActiveWorkers]			= sch.active_workers_count
		,	[TotalWorkers]			= sch.current_workers_count
	FROM	sys.dm_os_schedulers AS sch WITH (NOLOCK)
	WHERE	sch.scheduler_id < 1000000;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Monitor_WarningStateCaptureSchedulers TO sqlLink AS dbo;
GO
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureSchedulers
BY CERTIFICATE serverlevel_cert
WITH PASSWORD = '!@h19hPrIv()';
GO

USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_WarningStateCapturePlans
					@SessionList				VARCHAR(MAX)
				,	@get_system_request			BIT				= 0
AS
/*
	Creator:	20180705@Billy
	Task:		Capture Warning State information - Plans - [Redmine: #00000]
	Database:	MonDB

	Revisions:
		- 20180705@Billy:	Initialize - [Redmine: #00000]
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@Sessions AS TABLE (
				SessionId		INT
			);

	WITH cte AS (
		SELECT	[start]		= CAST(1 AS INT)
			,	[finish]	= CASE WHEN CHARINDEX(',', @SessionList, 1) = 0 THEN LEN(@SessionList) + 1 ELSE CHARINDEX(',', @SessionList, 1) END
		UNION ALL
		SELECT	[start]		= CAST(cte.finish + 1 AS INT)
			,	[finish]	= CASE WHEN CHARINDEX(',', @SessionList, cte.finish + 1) = 0 THEN LEN(@SessionList) + 1 ELSE CHARINDEX(',', @SessionList, cte.finish + 1) END
		FROM	cte
		WHERE	cte.finish < LEN(@SessionList)
	)
	INSERT INTO	@Sessions (SessionId)
	SELECT	c.SessionId
	FROM	cte
	CROSS APPLY	(
		SELECT	[SessionId]		= LTRIM(RTRIM(SUBSTRING(@SessionList, cte.start, cte.finish - cte.start)))
	) AS c
	WHERE	ISNULL(c.SessionId, '') <> ''
	OPTION (MAXRECURSION 0);

	SELECT	[ServerName]			= @@SERVERNAME
		,	[SessionId]				= rqs.session_id
		,	[RequestStart]			= rqs.start_time
		,	[RunningStartOffset]	= rqs.statement_start_offset
		,	[BaseText]				= ISNULL('[' + DB_NAME(stx.dbid) + '] ' + OBJECT_NAME(stx.objectid, stx.dbid), stx.text)
		,	[RunningText]			= SUBSTRING(LTRIM(stx.text), rqs.statement_start_offset / 2, CASE WHEN rqs.statement_end_offset <= 0 THEN LEN(stx.text) ELSE rqs.statement_end_offset / 2 END - rqs.statement_start_offset / 2 + 1)
		,	[RunningPlan]			= qrp.query_plan
	FROM		sys.dm_exec_requests AS rqs WITH (NOLOCK)
	INNER JOIN	@Sessions AS sss
			ON	rqs.session_id = sss.SessionId
	OUTER APPLY	sys.dm_exec_sql_text(rqs.sql_handle) AS stx
	OUTER APPLY	sys.dm_exec_text_query_plan(rqs.plan_handle, rqs.statement_start_offset, rqs.statement_end_offset) AS qrp
	WHERE	rqs.session_id <> @@SPID
		AND	rqs.session_id > CASE @get_system_request WHEN 1 THEN 50 ELSE 0 END
		AND	rqs.command NOT IN ('WAITFOR', 'RESOURCE MONITOR', 'LAZY WRITER', 'TASK MANAGER', 'XE TIMER', 'XE DISPATCHER');
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Monitor_WarningStateCapturePlans TO sqlLink AS dbo;
GO
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCapturePlans
BY CERTIFICATE serverlevel_cert
WITH PASSWORD = '!@h19hPrIv()';
GO

USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_LukasCapture
AS
BEGIN;
	SET NOCOUNT ON;

	SELECT [servername] = @@SERVERNAME, [capturedate] = GETDATE()
	 , [spid] = er.session_Id, ecid, [blockedBy] = er.blocking_session_id 
	 , [database_login] = REPLACE(DB_NAME(sp.dbid) + ' [' + RTRIM(LTRIM(loginame)) + ']','[]','[--]')
	 , [CMD_status] = RTRIM(sp.cmd) + ' [' +er.status + ']', [wait] = er.wait_type,wt.wait_type,sp.waitresource
	 , [current_stmt] = SUBSTRING (qt.text, er.statement_start_offset/2,
				(CASE WHEN er.statement_end_offset = -1 THEN DATALENGTH(qt.text)  
				 ELSE er.statement_end_offset END - er.statement_start_offset)/2)
	 ,sp.lastwaittype,wt.resource_description , wait_duration_ms
		,[current_batch] = qt.text, reads, logical_reads, cpu, [time_elapsed_ms] = DATEDIFF(mi, start_time,getdate()), program = program_name
	 ,tq.query_plan AS batch_plan  --, hostname, start_time, qt.objectid,wt.*
	FROM sys.dm_exec_requests er
	 INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
	 LEFT JOIN sys.dm_os_waiting_tasks wt ON sp.spid = wt.session_id AND sp.ecid = wt.exec_context_id
	 CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
	 CROSS APPLY sys.dm_exec_text_query_plan(er.plan_handle, er.statement_start_offset, er.statement_end_offset) AS tq
	WHERE er.session_Id > 50              -- Ignore system spids.
	AND er.session_Id NOT IN (@@SPID)     -- Ignore this current statement.
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Monitor_LukasCapture TO sqlLink AS dbo;
GO
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_LukasCapture
BY CERTIFICATE serverlevel_cert
WITH PASSWORD = '!@h19hPrIv()';
GO

USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_WarningStateCaptureRequestPlans
					@get_system_request			BIT				= 0
AS
/*
	Creator:	20180707@Billy
	Task:		Capture Warning State information - Requests & Plans - [Redmine: #00000]
	Database:	MonDB

	Revisions:
		- 20180707@Billy:	Initialize - [Redmine: #00000]
*/
BEGIN;
	SET NOCOUNT ON;

	SELECT	[ServerName]			= @@SERVERNAME
		,	[CaptureDate]			= GETDATE()
		,	[SessionId]				= rqs.session_id
		,	[BlockingSession]		= rqs.blocking_session_id
		,	[DB]					= DB_NAME(ISNULL(stx.dbid ,rqs.database_id))
		,	[ObjectName]			= OBJECT_NAME(stx.objectid, stx.dbid)
		,	[WaitType]				= rqs.wait_type
		,	[WaitTime]				= rqs.wait_time
		,	[WaitResource]			= rqs.wait_resource
		,	[CPUTime]				= rqs.cpu_time
		,	[ElapsedTime]			= rqs.total_elapsed_time
		,	[DOP]					= qmg.dop
		,	[GrantedMemoryKB]		= qmg.granted_memory_kb
		,	[UsedMemoryKB]			= qmg.used_memory_kb
		,	[RequestId]				= rqs.request_id
		,	[Reads]					= rqs.reads
		,	[LogicalReads]			= rqs.logical_reads
		,	[Writes]				= rqs.writes
		,	[PercentComplete]		= rqs.percent_complete
		,	[RunningStartOffset]	= rqs.statement_start_offset
		,	[RequestStart]			= rqs.start_time
		,	[RequestStatus]			= rqs.status
		,	[RequestCommand]		= rqs.command
		,	[SchedulerId]			= rqs.scheduler_id
		,	[HostName]				= sss.host_name
		,	[Program]				= sss.program_name
		,	[LoginName]				= sss.login_name
		,	[SessionStatus]			= sss.status
		,	[BaseText]				= ISNULL('[' + DB_NAME(stx.dbid) + '] ' + OBJECT_NAME(stx.objectid, stx.dbid), stx.text)
		,	[RunningText]			= SUBSTRING(LTRIM(stx.text), rqs.statement_start_offset / 2, CASE WHEN rqs.statement_end_offset <= 0 THEN LEN(stx.text) ELSE rqs.statement_end_offset / 2 END - rqs.statement_start_offset / 2 + 1)
		,	[RunningPlan]			= CASE WHEN rqs.command IN ('wAITFOR') THEN NULL ELSE qrp.query_plan END
	FROM		sys.dm_exec_requests AS rqs WITH (NOLOCK)
	OUTER APPLY	sys.dm_exec_sql_text(rqs.sql_handle) AS stx
	OUTER APPLY	sys.dm_exec_text_query_plan(rqs.plan_handle, rqs.statement_start_offset, rqs.statement_end_offset) AS qrp
	LEFT JOIN	sys.dm_exec_sessions AS sss WITH (NOLOCK)
			ON	rqs.session_id = sss.session_id
	LEFT JOIN	sys.dm_exec_query_memory_grants AS qmg WITH (NOLOCK)
			ON	rqs.session_id = qmg.session_id
			AND	rqs.request_id = qmg.request_id
	WHERE	rqs.session_id <> @@SPID
		AND	rqs.session_id > CASE @get_system_request WHEN 1 THEN 50 ELSE 0 END
		AND	rqs.command NOT IN ('RESOURCE MONITOR', 'LAZY WRITER', 'TASK MANAGER', 'XE TIMER', 'XE DISPATCHER');
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Monitor_WarningStateCaptureRequestPlans TO sqlLink AS dbo;
GO
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureRequestPlans
BY CERTIFICATE serverlevel_cert
WITH PASSWORD = '!@h19hPrIv()';
GO
/*<info serverAlias="DTRANS-MonDB,DBCUST-MonDB,DB02-MonDB,DB05-MonDB,DB052-MonDB,DB053-MonDB,DB054-MonDB,DB06-MonDB,DBTP-MonDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
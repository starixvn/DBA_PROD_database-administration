/*
	Created: 20190103@Helen
	Task: capture query running info, SP statistics info, remote query info
	DB: 
*/
-- #1 - Running queries
SELECT	[ServerName]		= @@SERVERNAME

		-- Priority --
	,	[BaseText]			= ISNULL('[' + DB_NAME(stx.dbid) + '] ' + OBJECT_NAME(stx.objectid, stx.dbid), stx.text)
	,	[SessionId]			= rqs.session_id
	,	[BlockingSession]	= rqs.blocking_session_id
	,	[WaitInfo]			= rqs.wait_type + ' [' + CAST(rqs.wait_time AS VARCHAR) + 'ms]'
	,	[CPUTime]			= rqs.cpu_time
	,	[ElapsedTime]		= rqs.total_elapsed_time
	,	[RunningText]		= SUBSTRING(LTRIM(stx.text), rqs.statement_start_offset / 2 + 1, CASE WHEN rqs.statement_end_offset <= 0 THEN LEN(stx.text) ELSE rqs.statement_end_offset / 2 END - rqs.statement_start_offset / 2 + 1)
	,	[RunningPlan]		= CAST(qrp.query_plan AS XML)
	,	[WaitResource]		= rqs.wait_resource
	,	[PercentDone]		= rqs.percent_complete

		-- Memory --
	,	[DOP]				= qmg.dop
	,	[GrantedMemoryKB]	= qmg.granted_memory_kb
	,	[MaxUsedMemoryKB]	= qmg.max_used_memory_kb
	,	[UsedMemoryKB]		= qmg.used_memory_kb
	
		-- Request --
	,	[RequestStart]		= rqs.start_time
	,	[RequestStatus]		= rqs.status
	,	[RequestCommand]	= rqs.command
	,	[SchedulerId]		= rqs.scheduler_id
	,	[Read]				= rqs.reads
	,	[LogicalRead]		= rqs.logical_reads
	,	[Write]				= rqs.writes

		-- Sql Text --
	,	[Database]			= DB_NAME(rqs.database_id)
	
		-- Sessions --
	,	[HostName]			= sss.host_name
	,	[Program]			= sss.program_name
	,	[LoginName]			= sss.login_name
	,	[SessionStatus]		= sss.status
		-- Scheduler --
	,	[CPUId]				= sch.cpu_id
	,	[CurrentTasks]		= sch.current_tasks_count
	,	[RunnableTasks]		= sch.runnable_tasks_count
	,	[PendingTasks]		= sch.work_queue_count
	,	[Workers]			= CAST(sch.active_workers_count AS VARCHAR) + '/' + CAST(sch.current_workers_count AS VARCHAR)
	,	[ClientIP]			= cnn.client_net_address
	,	[ClientPort]		= cnn.client_tcp_port
FROM		sys.dm_exec_requests AS rqs WITH (NOLOCK)
	OUTER APPLY	sys.dm_exec_sql_text(rqs.sql_handle) AS stx
	OUTER APPLY	sys.dm_exec_text_query_plan(rqs.plan_handle, rqs.statement_start_offset, rqs.statement_end_offset) AS qrp
	LEFT JOIN	sys.dm_exec_sessions AS sss WITH (NOLOCK)
			ON	rqs.session_id = sss.session_id
	LEFT JOIN	sys.dm_os_schedulers AS sch WITH (NOLOCK)
			ON	rqs.scheduler_id = sch.scheduler_id
	LEFT JOIN	sys.dm_exec_query_memory_grants AS qmg WITH (NOLOCK)
			ON	rqs.session_id = qmg.session_id
			AND	rqs.request_id = qmg.request_id
	LEFT JOIN	sys.dm_exec_connections AS cnn WITH (NOLOCK)
			ON	rqs.session_id = cnn.session_id
WHERE	rqs.session_id <> @@SPID
		AND	(rqs.session_id > 50 OR stx.text IS NOT NULL OR rqs.blocking_session_id <> 0 OR EXISTS(SELECT 1 FROM sys.dm_exec_requests AS _rqs WITH (NOLOCK) WHERE rqs.session_id = _rqs.blocking_session_id))
		AND	rqs.command NOT IN ('WAITFOR')
ORDER BY BlockingSession DESC, rqs.total_elapsed_time DESC

GO

EXEC mondb.dbo.vndba_sp_whoisactive @get_outer_command = 1 

GO
--#2 - Capture SP plan
SELECT TOP 100 SUBSTRING(t.TEXT, statement_start_offset / 2 + 1, (
    (CASE 
     WHEN qs.statement_end_offset = - 1 THEN (LEN(CONVERT(NVARCHAR(max), t.TEXT)) * 2)
     ELSE qs.statement_end_offset END
     ) - qs.statement_start_offset
    ) / 2 + 1) AS statement_text
 , creation_time
     ,last_execution_time, execution_count
     ,total_elapsed_time/execution_count as avg_elapsed_time
     ,total_elapsed_time, last_elapsed_time, min_elapsed_time, max_elapsed_time  
     ,last_worker_time, min_worker_time, max_worker_time
     ,total_logical_reads, last_logical_reads, min_logical_reads, max_logical_reads    
     ,p.query_plan

     ,cast(tq.query_plan as XML) as batch_plan
     , qs.creation_time
from sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) t 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) p
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) as tq
WHERE OBJECT_NAME(t.objectid,t.dbid) = 'ExecRep_09' AND t.dbid = DB_ID('bodb02') 

GO
-- #2 - Capture remote query plan
SELECT TOP 100 getdate() AS logdate
	,OBJECT_NAME(t.objectid, t.dbid) objname
	,qs.creation_time
	,SUBSTRING(t.TEXT, statement_start_offset / 2 + 1, (
	(CASE 
	WHEN qs.statement_end_offset = - 1 THEN (LEN(CONVERT(NVARCHAR(max), t.TEXT)) * 2)
	ELSE qs.statement_end_offset END
	) - qs.statement_start_offset
	) / 2 + 1) AS statement_text
	,last_execution_time
	,execution_count, last_elapsed_time, last_worker_time, total_worker_time, total_elapsed_time, total_logical_reads, last_logical_reads
	,cast(tq.query_plan AS XML) AS batch_plan

FROM sys.dm_exec_query_stats qs with (nolock)
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) t
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) p
	CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS tq
WHERE t.text like '%CustSuperProfile%' and t.objectid is null
ORDER BY creation_time desc 

-- --> Remote sample
--SELECT "Tbl1001"."custid" "Col1027","Tbl1001"."firstname" "Col1028","Tbl1001"."lastname" "Col1029","Tbl1001"."phone" "Col1030"
GO

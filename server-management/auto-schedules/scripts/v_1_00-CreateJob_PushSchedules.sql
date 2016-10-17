/*
	Creator:	20160630@Billy
	Task:		Create job for synchronizing schedules between host and remote servers - [Redmine: #60126]
	Server:		KBT		- DBTP
				SIT		- SITDB06
*/


--	BEGIN STEP :	*SERVER*.msdb
--		Create job script
----------------------------------------------------------------------------------------------------

USE msdb;
GO

BEGIN TRANSACTION;
DECLARE	@ReturnCode				INT;

SELECT	@ReturnCode = 0;

IF	NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'Starix Jobs Monitoring' AND category_class = 1)
BEGIN
	EXECUTE	@ReturnCode =	msdb.dbo.sp_add_category
								@class				= N'JOB'
							,	@type				= N'LOCAL'
							,	@name				= N'Starix Jobs Monitoring'
							;

	IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
		GOTO QuitWithRollback;
END;

DECLARE	@jobId					BINARY(16);

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_job
							@job_name				= N'vnDBA : Push Jobs Schedules'
						,	@enabled				= 1
						,	@notify_level_eventlog	= 0
						,	@notify_level_email		= 0
						,	@notify_level_netsend	= 0
						,	@notify_level_page		= 0
						,	@delete_level			= 0
						,	@description			= N'Job for synchronizing schedules between host and remote servers'
						,	@category_name			= N'Starix Jobs Monitoring'
						,	@owner_login_name		= N'sa'
						,	@job_id					= @jobId OUTPUT
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Check available log'
						,	@step_id				= 1
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 1
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'IF 	NOT EXISTS (SELECT 1 FROM vnDBA_Jobs_schedules_logs WITH (NOLOCK))
	RAISERROR(''No changes to push to remote servers!'', 11, 0) WITH NOWAIT;'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DBCUST'
						,	@step_id				= 2
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DBCUST.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DBTRANS'
						,	@step_id				= 3
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DBTRANS.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DB02'
						,	@step_id				= 4
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DB02.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DB04'
						,	@step_id				= 5
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DB04.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DB05'
						,	@step_id				= 6
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DB05.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DB052'
						,	@step_id				= 7
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DB052.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DB053'
						,	@step_id				= 8
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DB053.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DB054'
						,	@step_id				= 9
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DB054.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'DB07'
						,	@step_id				= 10
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 3
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DECLARE	@delete_data	NVARCHAR(MAX)
	,	@insert_data	NVARCHAR(MAX)
	;

SELECT	TOP(1)
		@delete_data = delete_data
	,	@insert_data = insert_data
FROM	vnDBA_Jobs_schedules_logs WITH (NOLOCK)
ORDER BY changed_date ASC;

EXECUTE	DB07.MonDB.dbo.vnDBA_sp_UpdateSchedules
			@delete_data = @delete_data
		,	@insert_data = @insert_data
		;
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Finish pushing'
						,	@step_id				= 11
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 4
						,	@on_success_step_id		= 1
						,	@on_fail_action			= 2
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'DELETE	vnDBA_Jobs_schedules_logs
WHERE	changed_date IN (SELECT TOP 1 changed_date FROM vnDBA_Jobs_schedules_logs ORDER BY changed_date ASC);'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_update_job
							@job_id					= @jobId
						,	@start_step_id			= 1
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobschedule
							@job_id					= @jobId
						,	@name					= N'Push schedules'
						,	@enabled				= 1
						,	@freq_type				= 4
						,	@freq_interval			= 1
						,	@freq_subday_type		= 4
						,	@freq_subday_interval	= 1
						,	@freq_relative_interval	= 0
						,	@freq_recurrence_factor	= 0
						,	@active_start_date		= 20160701
						,	@active_end_date		= 99991231
						,	@active_start_time		= 000000
						,	@active_end_time		= 235959
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobserver
							@job_id					= @jobId
						,	@server_name			= N'(local)'
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

COMMIT TRANSACTION;

GOTO EndSave;

QuitWithRollback:
    IF	(@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

EndSave:
GO



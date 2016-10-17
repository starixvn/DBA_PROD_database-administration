/*
	Creator:	20160803@Billy
	Task:		Create job for collecting data for Objects Monitoring Function - [Redmine: #58941]
	Server:		*ALL_SERVERS*
*/

--	BEGIN STEP 1:	*ALL_SERVERS*.msdb
--		Create job script
----------------------------------------------------------------------------------------------------

USE msdb;
GO

BEGIN TRANSACTION;
DECLARE	@ReturnCode		INT;

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

DECLARE	@jobId			BINARY(16)

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_job
							@job_name				= N'vnDBA : Objects Monitoring - Collect Data'
						,	@enabled				= 1
						,	@notify_level_eventlog	= 0
						,	@notify_level_email		= 0
						,	@notify_level_netsend	= 0
						,	@notify_level_page		= 0
						,	@delete_level			= 0
						,	@description			= N'Job for collecting data for Objects Monitoring Function.'
						,	@category_name			= N'Starix Jobs Monitoring'
						,	@owner_login_name		= N'sa'
						,	@job_id					= @jobId OUTPUT
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Schedule - Staging Jobs Information'
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
						,	@command				= N'DECLARE @isRun BIT = 0;

EXECUTE vnDBA_sp_CheckSchedules @schedule_type = ''MON_STAGING'', @isRun = @isRun OUTPUT;

IF @isRun = 0
RAISERROR(''Wait for scheduled time...'', 11, 0) WITH NOWAIT
'
						,	@database_name			= N'MonDB'
						,	@flags					= 0
						;

IF	(@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Staging Objects Information'
						,	@step_id				= 2
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 1
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 2
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'EXECUTE vnDBA_sp_Monitor_CollectInfo;'
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
						,	@name					= N'Auto Schedule'
						,	@enabled				= 1
						,	@freq_type				= 4
						,	@freq_interval			= 1
						,	@freq_subday_type		= 2
						,	@freq_subday_interval	= 10
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



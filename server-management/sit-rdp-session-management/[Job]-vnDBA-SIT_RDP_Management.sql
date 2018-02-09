/*
	Creator:	20180209@Billy
	Task:		SIT RDP Session Management - Notification Job - [Redmine: #90722]
	Server:		DBSPARE
*/

USE	msdb;
GO

BEGIN TRANSACTION;

DECLARE	@ReturnCode		INT;
SELECT	@ReturnCode		= 0;

IF	NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'SIT Administration' AND category_class = 1)
BEGIN;
	EXECUTE	@ReturnCode =	msdb.dbo.sp_add_category
								@class					= N'JOB'
							,	@type					= N'LOCAL'
							,	@name					= N'SIT Administration'
							;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;
END;

DECLARE	@jobId			BINARY(16);

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_job
							@job_name				= N'vnDBA : SIT RDP Management'
						,	@enabled				= 1
						,	@notify_level_eventlog	= 0
						,	@notify_level_email		= 0
						,	@notify_level_netsend	= 0
						,	@notify_level_page		= 0
						,	@delete_level			= 0
						,	@category_name			= N'SIT Administration'
						,	@owner_login_name		= N'sa'
						,	@job_id					= @jobId	OUTPUT
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Check and Send Notification'
						,	@step_id				= 1
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 1
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 2
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'TSQL'
						,	@command				= N'EXECUTE dbo.vnDBA_sp_RDP_NotifySessionInfo;'
						,	@database_name			= N'MONDB'
						,	@flags					= 0
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_update_job
							@job_id					= @jobId
						,	@start_step_id			= 1
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobschedule
							@job_id					= @jobId
						,	@name					= N'CheckRDP'
						,	@enabled				= 1
						,	@freq_type				= 4
						,	@freq_interval			= 1
						,	@freq_subday_type		= 4
						,	@freq_subday_interval	= 1
						,	@freq_relative_interval	= 0
						,	@freq_recurrence_factor	= 0
						,	@active_start_date		= 20180201
						,	@active_end_date		= 99991231
						,	@active_start_time		= 000010
						,	@active_end_time		= 235959
						,	@schedule_uid			= N'8887522e-c1a8-4e86-afd6-561c18fe6425'
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobserver
							@job_id					= @jobId
						,	@server_name			= N'(local)'
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

COMMIT TRANSACTION;

GOTO EndSave;

QuitWithRollback:
    IF	@@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

EndSave:

GO


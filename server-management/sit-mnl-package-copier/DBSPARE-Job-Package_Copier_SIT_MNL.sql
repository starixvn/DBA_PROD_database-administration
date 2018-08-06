/*
	Creator:	20180319@Billy
	Task:		Job for copying packages to SIT and MNL - [Redmine: #00000]
	Server:		DBSPARE
*/


USE	msdb;
GO

BEGIN TRANSACTION;

DECLARE	@ReturnCode		INT;

SELECT	@ReturnCode		= 0;

IF	NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WITH (NOLOCK) WHERE name = N'Deployment Process' AND category_class = 1)
BEGIN;
	EXECUTE	@ReturnCode		= msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Deployment Process';
	
	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;
END;

DECLARE	@jobId			BINARY(16);

EXECUTE	@ReturnCode		= msdb.dbo.sp_add_job
							@job_name				= N'vnDBA: Synchronize Deployed Package to SIT and MNL'
						,	@enabled				= 1
						,	@notify_level_eventlog	= 0
						,	@notify_level_email		= 0
						,	@notify_level_netsend	= 0
						,	@notify_level_page		= 0
						,	@delete_level			= 0
						,	@category_name			= N'Deployment Process'
						,	@owner_login_name		= N'sa'
						,	@job_id					= @jobId OUTPUT
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode		= msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Sync package to SIT & MNL'
						,	@step_id				= 1
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 1
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 2
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'CmdExec'
						,	@command				= N'powershell.exe -ExecutionPolicy ByPass "G:\vnDBA\PackageCopier-SIT-MNL.ps1"'
						,	@flags					= 0
						,	@proxy_name				= N'vnTask@DBSPARE'
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode		= msdb.dbo.sp_update_job
							@job_id					= @jobId
						,	@start_step_id			= 1
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode		= msdb.dbo.sp_add_jobschedule
							@job_id					= @jobId
						,	@name					= N'Every 10 minutes'
						,	@enabled				= 1
						,	@freq_type				= 4
						,	@freq_interval			= 1
						,	@freq_subday_type		= 4
						,	@freq_subday_interval	= 10
						,	@freq_relative_interval	= 0
						,	@freq_recurrence_factor	= 0
						,	@active_start_date		= 20180301
						,	@active_end_date		= 99991231
						,	@active_start_time		= 0
						,	@active_end_time		= 235959
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode		= msdb.dbo.sp_add_jobserver
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



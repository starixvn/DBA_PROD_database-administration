/*
	Creator:	20180209@Billy
	Task:		Update new IP2Location table for FPS system - [Redmine: #90857]
	Server:		DBFRAUD
*/

USE	msdb;
GO

BEGIN TRANSACTION;

DECLARE	@ReturnCode		INT;
SELECT	@ReturnCode		= 0;

IF	NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'IPDB' AND category_class = 1)
BEGIN;
	EXECUTE	@ReturnCode =	msdb.dbo.sp_add_category
								@class					= N'JOB'
							,	@type					= N'LOCAL'
							,	@name					= N'IPDB'
							;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;
END;

DECLARE	@jobId			BINARY(16);

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_job
							@job_name				= N'[IPDB] - Import IP2Location'
						,	@enabled				= 1
						,	@notify_level_eventlog	= 0
						,	@notify_level_email		= 0
						,	@notify_level_netsend	= 0
						,	@notify_level_page		= 0
						,	@delete_level			= 0
						,	@category_name			= N'IPDB'
						,	@owner_login_name		= N'sa'
						,	@job_id					= @jobId	OUTPUT
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Uncompress data file'
						,	@step_id				= 1
						,	@cmdexec_success_code	= 0
						,	@on_success_action		= 3
						,	@on_success_step_id		= 0
						,	@on_fail_action			= 2
						,	@on_fail_step_id		= 0
						,	@retry_attempts			= 0
						,	@retry_interval			= 0
						,	@os_run_priority		= 0
						,	@subsystem				= N'CmdExec'
						,	@command				= N'"C:\Program Files\7-Zip\7z.exe" e G:\IP2Location\DB4-IP-COUNTRY-REGION-CITY-ISP.CSV.ZIP -oG:\IP2Location IP-*.csv -y'
						,	@database_name			= N'master'
						,	@flags					= 0
						;

IF	@@ERROR <> 0 OR @ReturnCode <> 0
	GOTO QuitWithRollback;
	
EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobstep
							@job_id					= @jobId
						,	@step_name				= N'Import IP2Location Table'
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
						,	@command				= N'EXECUTE dbo.Task_ImportIP2Location;'
						,	@database_name			= N'IPDB'
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

EXECUTE	@ReturnCode =	msdb.dbo.sp_add_jobserver
							@job_id					= @jobId
						,	@server_name			= N'DBFRAUD'
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


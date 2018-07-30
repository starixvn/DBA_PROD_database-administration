/*
	Creator:	yyyymmdd@Creator
	Job Name:	[JobName]
	Server:		ServerName
	Revision:
		- yyyymmdd@Creator:	Initiate on GIT - [Redmine: #00000]
*/

SET NOCOUNT ON;

USE msdb;
GO

BEGIN TRANSACTION;

DECLARE @ReturnCode		INT
	,	@jobId			BINARY(16)
	,	@loop			INT
	,	@stepname		NVARCHAR(128)
	,	@msg			NVARCHAR(MAX)
	;

-- Input --
DECLARE	@category		NVARCHAR(128)	= N''
	,	@jobname		NVARCHAR(128)	= N''
	,	@description	NVARCHAR(512)	= N''
	,	@emailoperator	NVARCHAR(128)	= N''
	,	@steps			INT				= 0
	;

SELECT	@ReturnCode		= 0;

IF	ISNULL(@category, N'') = N''
OR	ISNULL(@jobname, N'') = N''
BEGIN;
	RAISERROR('Invalid Input!', 16, 1) WITH NOWAIT;
	RETURN;
END;

-- Add category --
IF	NOT EXISTS (
		SELECT	ctg.name
		FROM	msdb.dbo.syscategories AS ctg WITH (NOLOCK)
		WHERE	ctg.name = @category
			AND	ctg.category_class = 1
	)
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_category
							@class	= N'JOB'
						,	@type	= N'LOCAL'
						,	@name	= @category
						;
	
	IF	@@ERROR <> 0 OR	@ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'CATEGORY ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Add job --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_job
							@job_name					= @jobname
						,	@job_id						= @jobId OUTPUT
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'JOB ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Init job steps --
BEGIN;
	SELECT	@loop	= 1
		;

	WHILE	@loop <= @steps
	BEGIN;
		SELECT	@stepname	= N'Step ' + CAST(@loop AS NVARCHAR);

		EXECUTE	@ReturnCode	= msdb.dbo.sp_add_jobstep
								@job_id						= @jobId
							,	@step_name					= @stepname
							,	@step_id					= @loop
							;
					
		IF	@@ERROR <> 0 OR @ReturnCode <> 0
			GOTO QuitWithRollback;

		SELECT	@loop = @loop + 1;
	END;

	SELECT	@msg = N'INITIATED ' + CAST(@steps AS NVARCHAR) + N' STEPS';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Define job --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_job
							@job_id						= @jobId
						,	@new_name					= @jobname
						,	@enabled					= 1
						,	@notify_level_eventlog		= 0
						,	@notify_level_email			= 2
						,	@notify_level_netsend		= 0
						,	@notify_level_page			= 0
						,	@delete_level				= 0
						,	@description				= @description
						,	@category_name				= @category
						,	@owner_login_name			= N'sa'
						,	@notify_email_operator_name	= @emailoperator
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'JOB ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Define job steps --
---- Step 1 ----
BEGIN;
	SELECT	@loop = 1;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'CmdExec'
						,	@step_id					= @loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'CmdExec'
						,	@flags						= 0
						,	@proxy_name					= N''
						,	@command					= N'';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP %d ADDED';
	RAISERROR(@msg, 0, 0, @loop) WITH NOWAIT;
END;

---- Step 2 ----
BEGIN;
	SELECT	@loop = 2;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'TSQL'
						,	@step_id					= @loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N''
						,	@flags						= 0
						,	@command					= N'';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP %d ADDED';
	RAISERROR(@msg, 0, 0, @loop) WITH NOWAIT;
END;

---- Job start at step ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_job
							@job_id						= @jobId
						,	@start_step_id				= 1
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'UPDATED START STEP';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Job schedule --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_jobschedule
							@job_id						= @jobId
						,	@name						= N''
						,	@enabled					= 1
						,	@freq_type					= 8
						,	@freq_interval				= 9
						,	@freq_subday_type			= 1
						,	@freq_subday_interval		= 0
						,	@freq_relative_interval		= 0
						,	@freq_recurrence_factor		= 1
						,	@active_start_date			= 20170401
						,	@active_end_date			= 99991231
						,	@active_start_time			= 133000
						,	@active_end_time			= 235959
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'ADDED JOB SCHEDULE';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Job server --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_jobserver
							@job_id						= @jobId
						,	@server_name				= N'(local)'
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'JOB SERVER ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- All success -- Commit changes --
COMMIT TRANSACTION;
SELECT	@msg = N'*** JOB CREATED SUCCESSFULLY ***';
RAISERROR(@msg, 0, 0) WITH NOWAIT;
GOTO EndSave;

-- Jump point -- Failure --
QuitWithRollback:
IF	@@TRANCOUNT > 0
	ROLLBACK TRANSACTION;

-- Jump point -- Finish --
EndSave:
GO
/*
	Creator:	20180209@Billy
	Job Name:	[[IPDB] - Import IP2Location]
	Server:		DBFRAUD
	Revision:
		- 20180209@Billy:	Initiate on GIT - [Redmine: #90857]
*/

SET NOCOUNT ON;

USE msdb;
GO

BEGIN TRANSACTION;

DECLARE @ReturnCode		INT
	,	@JobId			BINARY(16)
	,	@StepId			INT
	,	@StepName		NVARCHAR(128)
	,	@Msg			NVARCHAR(MAX)
	;

-- Input --
DECLARE	@Category		NVARCHAR(128)	= N'IPDB'
	,	@JobName		NVARCHAR(128)	= N'[IPDB] - Import IP2Location'
	,	@Description	NVARCHAR(512)	= N''
	,	@EmailOperator	NVARCHAR(128)	= N'FPS_DBA'
	,	@Steps			INT				= 3
	;

SELECT	@ReturnCode		= 0;

IF	ISNULL(@Category, N'') = N''
OR	ISNULL(@JobName, N'') = N''
BEGIN;
	RAISERROR('Invalid Input!', 16, 1) WITH NOWAIT;
	RETURN;
END;

-- Add category --
IF	NOT EXISTS (
		SELECT	ctg.name
		FROM	msdb.dbo.syscategories AS ctg WITH (NOLOCK)
		WHERE	ctg.name = @Category
			AND	ctg.category_class = 1
	)
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_category
							@class	= N'JOB'
						,	@type	= N'LOCAL'
						,	@name	= @Category
						;
	
	IF	@@ERROR <> 0 OR	@ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'CATEGORY [%s] ADDED';
	RAISERROR(@Msg, 0, 0, @Category) WITH NOWAIT;
END;

-- Add job --
SELECT	@JobId	= job.job_id
FROM	msdb.dbo.sysjobs AS job WITH (NOLOCK)
WHERE	job.name = @JobName;

IF	@@ROWCOUNT = 0 AND @JobId IS NULL
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_job
							@job_name					= @JobName
						,	@job_id						= @JobId OUTPUT
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'JOB [%s] ADDED';
	RAISERROR(@Msg, 0, 0, @JobName) WITH NOWAIT;
END;
ELSE
BEGIN;
	SELECT	@Msg = N'~~ JOB EXISTS ~~';
	RAISERROR(@Msg, 0, 0) WITH NOWAIT;
	
	GOTO QuitWithRollback;
END;

-- Init job steps --
BEGIN;
	SELECT	@StepId	= 1
		;

	WHILE	@StepId <= @Steps
	BEGIN;
		SELECT	@StepName	= N'Step ' + CAST(@StepId AS NVARCHAR);

		EXECUTE	@ReturnCode	= msdb.dbo.sp_add_jobstep
								@job_id						= @JobId
							,	@step_name					= @StepName
							,	@step_id					= @StepId
							;
					
		IF	@@ERROR <> 0 OR @ReturnCode <> 0
			GOTO QuitWithRollback;

		SELECT	@StepId = @StepId + 1;
	END;

	SELECT	@Msg = N'INITIATED ' + CAST(@Steps AS NVARCHAR) + N' STEPS';
	RAISERROR(@Msg, 0, 0) WITH NOWAIT;
END;

-- Define job --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_job
							@job_id						= @JobId
						,	@new_name					= @JobName
						,	@enabled					= 1
						,	@notify_level_eventlog		= 0
						,	@notify_level_email			= 2
						,	@notify_level_netsend		= 0
						,	@notify_level_page			= 0
						,	@delete_level				= 0
						,	@description				= @Description
						,	@category_name				= @Category
						,	@owner_login_name			= N'sa'
						,	@notify_email_operator_name	= @EmailOperator
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'JOB [%s] UPDATED';
	RAISERROR(@Msg, 0, 0, @JobName) WITH NOWAIT;
END;

-- Define job steps --
---- Step 1 ----
BEGIN;
	SELECT	@StepId = 1;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Uncompress data file'
						,	@step_id					= @StepId
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
						,	@command					= N'\
"C:\Program Files\7-Zip\7z.exe" e G:\IP2Location\DB4-IP-COUNTRY-REGION-CITY-ISP.CSV.ZIP -oG:\IP2Location IP-*.csv -y'
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d ADDED';
	RAISERROR(@Msg, 0, 0, @StepId) WITH NOWAIT;
END;

---- Step 2 ----
BEGIN;
	SELECT	@StepId = 1;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Uncompress data file IPv6'
						,	@step_id					= @StepId
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
						,	@command					= N'\
"C:\Program Files\7-Zip\7z.exe" e G:\IP2Location\DB4-IPV6-COUNTRY-REGION-CITY-ISP.CSV.ZIP -oG:\IP2Location IPV6-*.csv -y';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d ADDED';
	RAISERROR(@Msg, 0, 0, @StepId) WITH NOWAIT;
END;

---- Step 3 ----
BEGIN;
	SELECT	@StepId = 3;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Import IP2Location Table'
						,	@step_id					= @StepId
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 1
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'IPDB'
						,	@flags						= 0
						,	@command					= N'\
EXECUTE dbo.Task_ImportIP2Location;
EXECUTE dbo.Task_ImportIPv62Location;
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @StepId) WITH NOWAIT;
END;

---- Job start at step ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_job
							@job_id						= @JobId
						,	@start_step_id				= 1
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'UPDATED START STEP';
	RAISERROR(@Msg, 0, 0) WITH NOWAIT;
END;

-- Job server --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_jobserver
							@job_id						= @JobId
						,	@server_name				= N'(local)'
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'JOB SERVER ADDED';
	RAISERROR(@Msg, 0, 0) WITH NOWAIT;
END;

-- All success -- Commit changes --
COMMIT TRANSACTION;
SELECT	@Msg = N'*** JOB CREATED SUCCESSFULLY ***';
RAISERROR(@Msg, 0, 0) WITH NOWAIT;
GOTO EndSave;

-- Jump point -- Failure --
QuitWithRollback:
IF	@@TRANCOUNT > 0
	ROLLBACK TRANSACTION;

-- Jump point -- Finish --
EndSave:
GO
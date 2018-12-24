/*
	Creator:	20181221@Billy
	Job Name:	[_SYNC: [KBT-DBMNL] Staging Archive Data]
	Server:		DBMNL
	Revision:
		- 20181221@Billy:	Initiate on GIT - [Redmine: #000000]
		- 20181221@Billy:	Add [oddsES_bk], [ResultDetailES_bk], [Transfer_Coll_bk] & Update [match_remark], [bettransRnG_bk] - [Redmine: #106070]
*/

SET NOCOUNT ON;

USE msdb;
GO

BEGIN TRANSACTION;

DECLARE @ReturnCode		INT
	,	@JobId			BINARY(16)
	,	@Loop			INT
	,	@StepName		NVARCHAR(128)
	,	@Msg			NVARCHAR(MAX)
	;

-- Input --
DECLARE	@Category		NVARCHAR(128)	= N'Archive Data Synchronization'
	,	@JobName		NVARCHAR(128)	= N'_SYNC: [KBT-DBMNL] Staging Archive Data'
	,	@Description	NVARCHAR(512)	= N''
	,	@EmailOperator	NVARCHAR(128)	= N'DBAAdmin'
	,	@Steps			INT				= 40
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
	SELECT	@Loop	= 1
		;

	WHILE	@Loop <= @Steps
	BEGIN;
		SELECT	@StepName	= N'Step ' + CAST(@Loop AS NVARCHAR);

		EXECUTE	@ReturnCode	= msdb.dbo.sp_add_jobstep
								@job_id						= @JobId
							,	@step_name					= @StepName
							,	@step_id					= @Loop
							;
					
		IF	@@ERROR <> 0 OR @ReturnCode <> 0
			GOTO QuitWithRollback;

		SELECT	@Loop = @Loop + 1;
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
						,	@notify_level_email			= 3
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
	SELECT	@Loop = 1;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Check Rowcount'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive_staging'
						,	@flags						= 0
						,	@command					= N'
EXECUTE dbo.Task_MNL_CheckRowcount;
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d ADDED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 2 ----
BEGIN;
	SELECT	@Loop = 2;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Mark Unsync Dates'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive_staging'
						,	@flags						= 0
						,	@command					= N'
EXECUTE dbo.Task_MNL_Archive_SelectDate;
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 3 ----
BEGIN;
	SELECT	@Loop = 3;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Check date'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4
						,	@on_fail_step_id			= 40
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive_staging'
						,	@flags						= 0
						,	@command					= N'
IF	NOT EXISTS (SELECT 1 FROM Task_MNL_ArchiveData WITH (NOLOCK) WHERE isStaged = 0)
	RAISERROR(''All date are synced!'', 11, 0);
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 4 ----
BEGIN;
	SELECT	@Loop = 4;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'match_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\match_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 5 ----
BEGIN;
	SELECT	@Loop = 5;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'bettrans_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\bettrans_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 6 ----
BEGIN;
	SELECT	@Loop = 6;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'bettransG'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\bettransLC_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 7 ----
BEGIN;
	SELECT	@Loop = 7;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'bettransLC_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\bettransLC_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 8 ----
BEGIN;
	SELECT	@Loop = 8;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'bettransm'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\bettransm.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 9 ----
BEGIN;
	SELECT	@Loop = 9;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'bettransRnG_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\bettransRnG_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 10 ----
BEGIN;
	SELECT	@Loop = 10;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'transfer_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\transfer_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 11 ----
BEGIN;
	SELECT	@Loop = 11;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'translog_BK'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\translog_BK.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 12 ----
BEGIN;
	SELECT	@Loop = 12;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'AutoPayoutResult_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\AutoPayoutResult_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 13 ----
BEGIN;
	SELECT	@Loop = 13;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'BetParlayResult'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\BetParlayResult.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 14 ----
BEGIN;
	SELECT	@Loop = 14;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'bingoBall_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\bingoBall_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 15 ----
BEGIN;
	SELECT	@Loop = 15;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Dot_Admin_Assignment_Operator_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\Dot_Admin_Assignment_Operator_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 16 ----
BEGIN;
	SELECT	@Loop = 16;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Dot_Admin_LiveLog'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\Dot_Admin_LiveLog.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 17 ----
BEGIN;
	SELECT	@Loop = 17;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'MatchMaxbet_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\MatchMaxbet_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 18 ----
BEGIN;
	SELECT	@Loop = 18;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'odds_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\odds_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 19 ----
BEGIN;
	SELECT	@Loop = 19;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'outright_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\outright_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 20 ----
BEGIN;
	SELECT	@Loop = 20;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'ProviderResultDetail_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\ProviderResultDetail_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 21 ----
BEGIN;
	SELECT	@Loop = 21;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'ResultDetail_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\ResultDetail_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 22 ----
BEGIN;
	SELECT	@Loop = 22;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'ResultDetail3rd_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\ResultDetail3rd_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 23 ----
BEGIN;
	SELECT	@Loop = 23;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'SS_GameState_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\SS_GameState_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 24 ----
BEGIN;
	SELECT	@Loop = 24;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'VSOutright_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\VSOutright_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 25 ----
BEGIN;
	SELECT	@Loop = 25;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'BetTradeSelling180'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\BetTradeSelling180.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 26 ----
BEGIN;
	SELECT	@Loop = 26;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'BetTradeSellingCancelled180'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\BetTradeSellingCancelled180.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 27 ----
BEGIN;
	SELECT	@Loop = 27;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'match_remark'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\match_remark.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 28 ----
BEGIN;
	SELECT	@Loop = 28;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'VendorBettypeStatus_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\VendorBettypeStatus_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 29 ----
BEGIN;
	SELECT	@Loop = 29;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'VendorStatus_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\VendorStatus_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 30 ----
BEGIN;
	SELECT	@Loop = 30;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Statement'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\Statement.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 31 ----
BEGIN;
	SELECT	@Loop = 31;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Match3rd_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\Match3rd_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 32 ----
BEGIN;
	SELECT	@Loop = 32;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'BalNetPosition_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\BalNetPosition_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 33 ----
BEGIN;
	SELECT	@Loop = 33;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'NetPositionCalculationLog_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\NetPositionCalculationLog_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 34 ----
BEGIN;
	SELECT	@Loop = 34;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'NetPositionTrans_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\NetPositionTrans_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 35 ----
BEGIN;
	SELECT	@Loop = 35;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Odds3rd_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\odds3rd_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 36 ----
BEGIN;
	SELECT	@Loop = 36;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'OddsES_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\oddsES_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 37 ----
BEGIN;
	SELECT	@Loop = 37;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'ResultDetailES_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\ResultDetailES_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 38 ----
BEGIN;
	SELECT	@Loop = 38;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Transfer_Coll_bk'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "G:\IBC_DB\_SSIS\KBT_Staging_DBMNL\Transfer_Coll_bk.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 39 ----
BEGIN;
	SELECT	@Loop = 39;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Task_MNL_ArchiveData'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4
						,	@on_success_step_id			= 3
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive_staging'
						,	@flags						= 0
						,	@command					= N'
UPDATE	TOP(1) tbl
SET		isStaged = 1
FROM	dbo.Task_MNL_ArchiveData tbl
WHERE	winlostdate = (SELECT MIN(winlostdate) FROM Task_MNL_ArchiveData WITH (NOLOCK) WHERE isStaged = 0);

IF	@@ROWCOUNT <> 1
	RAISERROR(''Something wrong is happening!'', 11, 0);
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
END;

---- Step 40 ----
BEGIN;
	SELECT	@Loop = 40;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Start synchronize job'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 1
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'msdb'
						,	@flags						= 0
						,	@command					= N'
EXECUTE dbo.sp_start_job @job_name = ''_SYNC: [DBMNL-DB06@MNL] Synchonizing Archive Data'', @step_name = ''Check date'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'STEP %d UPDATED';
	RAISERROR(@Msg, 0, 0, @Loop) WITH NOWAIT;
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

-- Job schedule --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_jobschedule
							@job_id						= @JobId
						,	@name						= N'SYNC [KBT-DBMNL]'
						,	@enabled					= 1
						,	@freq_type					= 8
						,	@freq_interval				= 32
						,	@freq_subday_type			= 1
						,	@freq_subday_interval		= 0
						,	@freq_relative_interval		= 0
						,	@freq_recurrence_factor		= 1
						,	@active_start_date			= 20160624
						,	@active_end_date			= 99991231
						,	@active_start_time			= 170000
						,	@active_end_time			= 235959
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@Msg = N'ADDED JOB SCHEDULE';
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
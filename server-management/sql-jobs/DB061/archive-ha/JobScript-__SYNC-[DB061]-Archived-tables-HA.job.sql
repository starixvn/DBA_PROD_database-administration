/*
	Creator:	20181219@Billy
	Job Name:	[__SYNC: [DB061] Archived tables HA]
	Server:		DB061
	Revision:
		- 20181219@Billy:	Initiate on GIT - [Redmine: #000000]
		- 20181219@Billy:	Add [oddsES_bk], [ResultDetailES_bk], [Transfer_Coll_bk] & Update [match_remark], [bettransRnG_bk] - [Redmine: #106070]
		- 20190313@Billy:	Add [transfer_fi] - [Redmine: #109016]
		- 20190401@Billy:	Add [SMP_Market_bk] & [SMP_MarketSelection_bk] - [Redmine: #109926]
		- 20190416@Billy:	DB061 Migration - [Redmine: #111418]
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
	,	@JobName		NVARCHAR(128)	= N'__SYNC: [DB061] Archived tables HA'
	,	@Description	NVARCHAR(512)	= N''
	,	@EmailOperator	NVARCHAR(128)	= N'vnDBA'
	,	@Steps			INT				= 18
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
	SELECT	@Loop = 1;

	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @JobId
						,	@step_name					= N'Check Rowcount'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
EXECUTE dbo.Task_ArchiveHA_SyncMetaTables;
EXECUTE dbo.Task_ArchiveHA_CheckRowcount;
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
						,	@step_name					= N'Validate for Type 1'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 4		-- [Validate for Type 2]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
DECLARE @ReturnCode INT;

EXECUTE @ReturnCode = dbo.Task_ArchiveHA_SSIS_GetSyncInfo @TableType = 1;

IF @ReturnCode = 0 RAISERROR (''Type 1 [OK]'', 16, 1) WITH NOWAIT;
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
						,	@step_name					= N'Sync Table Type 1'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4		-- Go to step
						,	@on_success_step_id			= 2		-- [Validate for Type 1]
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "I:\USER_DB\_SSIS_Library_\ArchiveHA\ArchiveHA-SyncType1.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

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
						,	@step_name					= N'Validate for Type 2'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 6		-- [Validate for Type 3]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
DECLARE @ReturnCode INT;

EXECUTE @ReturnCode = dbo.Task_ArchiveHA_SSIS_GetSyncInfo @TableType = 2;

IF @ReturnCode = 0 RAISERROR (''Type 2 [OK]'', 16, 1) WITH NOWAIT;
';

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
						,	@step_name					= N'Sync Table Type 2'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4		-- Go to step
						,	@on_success_step_id			= 4		-- [Validate for Type 2]
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "I:\USER_DB\_SSIS_Library_\ArchiveHA\ArchiveHA-SyncType2.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

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
						,	@step_name					= N'Validate for Type 3'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 8		-- [Validate for Type 4]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
DECLARE @ReturnCode INT;

EXECUTE @ReturnCode = dbo.Task_ArchiveHA_SSIS_GetSyncInfo @TableType = 3;

IF @ReturnCode = 0 RAISERROR (''Type 3 [OK]'', 16, 1) WITH NOWAIT;
';

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
						,	@step_name					= N'Sync Table Type 3'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4		-- Go to step
						,	@on_success_step_id			= 6		-- [Validate for Type 3]
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "I:\USER_DB\_SSIS_Library_\ArchiveHA\ArchiveHA-SyncType3.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

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
						,	@step_name					= N'Validate for Type 4'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 10	-- [Validate for Type 5]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
DECLARE @ReturnCode INT;

EXECUTE @ReturnCode = dbo.Task_ArchiveHA_SSIS_GetSyncInfo @TableType = 4;

IF @ReturnCode = 0 RAISERROR (''Type 4 [OK]'', 16, 1) WITH NOWAIT;
';

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
						,	@step_name					= N'Sync Table Type 4'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4		-- Go to step
						,	@on_success_step_id			= 8		-- [Validate for Type 4]
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "I:\USER_DB\_SSIS_Library_\ArchiveHA\ArchiveHA-SyncType4.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

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
						,	@step_name					= N'Validate for Type 5'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 12	-- [Validate for Type 6]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
DECLARE @ReturnCode INT;

EXECUTE @ReturnCode = dbo.Task_ArchiveHA_SSIS_GetSyncInfo @TableType = 5;

IF @ReturnCode = 0 RAISERROR (''Type 5 [OK]'', 16, 1) WITH NOWAIT;
';

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
						,	@step_name					= N'Sync Table Type 5'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4		-- Go to step
						,	@on_success_step_id			= 10	-- [Validate for Type 5]
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "I:\USER_DB\_SSIS_Library_\ArchiveHA\ArchiveHA-SyncType5.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

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
						,	@step_name					= N'Validate for Type 6'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 14	-- [Validate for Type 7]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
DECLARE @ReturnCode INT;

EXECUTE @ReturnCode = dbo.Task_ArchiveHA_SSIS_GetSyncInfo @TableType = 6;

IF @ReturnCode = 0 RAISERROR (''Type 6 [OK]'', 16, 1) WITH NOWAIT;
';

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
						,	@step_name					= N'Sync Table Type 6'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4		-- Go to step
						,	@on_success_step_id			= 12	-- [Validate for Type 6]
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "I:\USER_DB\_SSIS_Library_\ArchiveHA\ArchiveHA-SyncType6.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

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
						,	@step_name					= N'Validate for Type 7'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 16	-- [Re-check Rowcount]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
DECLARE @ReturnCode INT;

EXECUTE @ReturnCode = dbo.Task_ArchiveHA_SSIS_GetSyncInfo @TableType = 7;

IF @ReturnCode = 0 RAISERROR (''Type 7 [OK]'', 16, 1) WITH NOWAIT;
';

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
						,	@step_name					= N'Sync Table Type 7'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 4		-- Go to step
						,	@on_success_step_id			= 14	-- [Validate for Type 7]
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'SSIS'
						,	@database_name				= N'master'
						,	@flags						= 0
						,	@command					= N'/FILE "I:\USER_DB\_SSIS_Library_\ArchiveHA\ArchiveHA-SyncType7.dtsx" /DECRYPT "ss1s@w3e" /CHECKPOINTING OFF /REPORTING E';

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
						,	@step_name					= N'Re-check Rowcount'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2		-- Quit with FAILURE
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
EXECUTE dbo.Task_ArchiveHA_SyncMetaTables;
EXECUTE dbo.Task_ArchiveHA_CheckRowcount;
';

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
						,	@step_name					= N'Loop if there are still mismatch'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3		-- Next step
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 4		-- Go to step
						,	@on_fail_step_id			= 2		-- [Validate for Type 1]
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb_Archive'
						,	@flags						= 0
						,	@command					= N'
IF EXISTS (SELECT 1 FROM dbo.Task_ArchiveHA_RowcountResult WITH (NOLOCK) WHERE TimeType = ''DAY'')
    RAISERROR (''Recheck [NG]'', 16, 1) WITH NOWAIT;
';

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
						,	@step_name					= N'Instant Notification'
						,	@step_id					= @Loop
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 1		-- Quit with SUCCESS
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 1		-- Quit with SUCCESS
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'msdb'
						,	@flags						= 0
						,	@command					= N'
EXECUTE dbo.Task_Job_InstantResultNotification @JobName = N''__SYNC: [DB061] Archived tables HA''
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
						,	@name						= N'Daily@9PM (server time)'
						,	@enabled					= 1
						,	@freq_type					= 4
						,	@freq_interval				= 1
						,	@freq_subday_type			= 1
						,	@freq_subday_interval		= 0
						,	@freq_relative_interval		= 0
						,	@freq_recurrence_factor		= 0
						,	@active_start_date			= 20190401
						,	@active_end_date			= 99991231
						,	@active_start_time			= 210000
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
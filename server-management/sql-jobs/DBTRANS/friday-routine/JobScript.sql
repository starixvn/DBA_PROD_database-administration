/*
	Creator:	@
	Job Name:	[Joe : DBTRANS_bodb02 : Friday routine]
	Server:		DBTRANS
	Revision:
		- 20180725@Billy:	Initiate on GIT - [Redmine: #00000]
		- 20180725@Billy:	Change the way of deleting data (except [bettransm14]) - [Redmine: #98857]
*/

SET NOCOUNT ON;

USE msdb;
GO

BEGIN TRANSACTION;

DECLARE @ReturnCode		INT
	,	@jobId			BINARY(16)
	,	@steps			INT
	,	@loop			INT
	,	@stepname		NVARCHAR(128)
	,	@msg			NVARCHAR(MAX)
	;

SELECT	@ReturnCode		= 0;

-- Add category --
IF	NOT EXISTS (
		SELECT	ctg.name
		FROM	msdb.dbo.syscategories AS ctg WITH (NOLOCK)
		WHERE	ctg.name = N'[Uncategorized (Local)]'
			AND	ctg.category_class = 1
	)
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_category
							@class	= N'JOB'
						,	@type	= N'LOCAL'
						,	@name	= N'[Uncategorized (Local)]'
						;
	
	IF	@@ERROR <> 0 OR	@ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'CATEGORY ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Add job --
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_add_job
							@job_name					= N'Joe : DBTRANS_bodb02 : Friday routine'
						,	@enabled					= 1
						,	@notify_level_eventlog		= 0
						,	@notify_level_email			= 3
						,	@notify_level_netsend		= 0
						,	@notify_level_page			= 0
						,	@delete_level				= 0
						,	@description				= N'No description available.'
						,	@category_name				= N'[Uncategorized (Local)]'
						,	@owner_login_name			= N'sa'
						,	@notify_email_operator_name	= N'DBAAdmin'
						,	@job_id						= @jobId OUTPUT
						;

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'JOB ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

-- Init job steps --
BEGIN;
	SELECT	@steps	= 9
		,	@loop	= 1
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

-- Define job steps --
---- Step 1 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'Archive Event'
						,	@step_id					= 1
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid int PRIMARY KEY IDENTITY(1,1), winlostdate smalldatetime)
INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate FROM dbo.task_archivedate
ORDER BY 1

Declare @wldate smalldatetime

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 1   EXEC DB02.bodb02.dbo.Task_Archive_Event @wldate, @Action = ''delete''
WAITFOR DELAY ''00:00:05''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 2   EXEC DB02.bodb02.dbo.Task_Archive_Event @wldate, @Action = ''delete''
WAITFOR DELAY ''00:01:05''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 3   EXEC DB02.bodb02.dbo.Task_Archive_Event @wldate, @Action = ''delete''
WAITFOR DELAY ''00:00:05''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 4   EXEC DB02.bodb02.dbo.Task_Archive_Event @wldate, @Action = ''delete''
WAITFOR DELAY ''00:01:05''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 5   EXEC DB02.bodb02.dbo.Task_Archive_Event @wldate, @Action = ''delete''
WAITFOR DELAY ''00:00:05''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 6   EXEC DB02.bodb02.dbo.Task_Archive_Event @wldate, @Action = ''delete''
WAITFOR DELAY ''00:01:05''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 7   EXEC DB02.bodb02.dbo.Task_Archive_Event @wldate, @Action = ''delete''

WAITFOR DELAY ''00:01:10''

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 1
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayResult''
WAITFOR DELAY ''00:00:30''
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayDetail''
WAITFOR DELAY ''00:01:00''

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 2
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayResult''
WAITFOR DELAY ''00:00:30''
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayDetail''
WAITFOR DELAY ''00:01:00''

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 3
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayResult''
WAITFOR DELAY ''00:00:30''
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayDetail''
WAITFOR DELAY ''00:01:00''

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 4
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayResult''
WAITFOR DELAY ''00:00:30''
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayDetail''
WAITFOR DELAY ''00:01:00''

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 5
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayResult''
WAITFOR DELAY ''00:00:30''
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayDetail''
WAITFOR DELAY ''00:01:00''

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 6
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayResult''
WAITFOR DELAY ''00:00:30''
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayDetail''
WAITFOR DELAY ''00:01:00''

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 7
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayResult''
WAITFOR DELAY ''00:00:30''
EXEC Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''betParlayDetail''

WAITFOR DELAY ''00:01:30''

SELECT @wldate = MAX(winlostdate) FROM @archiveDate;
EXECUTE dbo.Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''Task_bettrans14_IP2Country''
WAITFOR DELAY ''00:00:30'';
EXECUTE dbo.Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''Task_bettransRNG14_IP2Country''
WAITFOR DELAY ''00:00:30'';
EXECUTE dbo.Task_Archive_Bet @winlostdate = @wldate, @DeletedTarget = ''Task_bettransLC14_IP2Country''
WAITFOR DELAY ''00:00:30'';

--- delete old data for NG2
SELECT @wldate = MAX(winlostdate)
FROM @archiveDate 

DELETE b 
FROM dbo.bettrans_Staging b 
	INNER JOIN SettlementNG2_Message m WITH(NOLOCK) ON b.SeqId = m.SeqID
WHERE
	m.EventDate <= @wldate
WAITFOR DELAY ''00:01:20''

DELETE FROM SettlementNG2_Message
WHERE EventDate <= @wldate

WAITFOR DELAY ''00:01:30''
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 1 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 2 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'1'
						,	@step_id					= 2
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME);
DECLARE @wldate SMALLDATETIME
, @WaitFor NVARCHAR(MAX);

-- Dynamic Delay Time --
SELECT	@WaitFor = N'''';
SELECT	@WaitFor = @WaitFor + N''WAITFOR DELAY '''''' + dbo.f_BU_GetDelayTime(''FriRoutine'') + N'''''';'';

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate

SELECT @wldate = winlostdate
FROM @archiveDate
WHERE rid = 1;

DECLARE @rowcount INT;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettrans14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransm14'';
WAITFOR DELAY ''00:00:03'';

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''sum_winloss'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''translog14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransLC14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransRNG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;
 
EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''others'';
WAITFOR DELAY ''00:00:03'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 2 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 3 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'2'
						,	@step_id					= 3
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME);
DECLARE @wldate SMALLDATETIME
, @WaitFor NVARCHAR(MAX);

-- Dynamic Delay Time --
SELECT	@WaitFor = N'''';
SELECT	@WaitFor = @WaitFor + N''WAITFOR DELAY '''''' + dbo.f_BU_GetDelayTime(''FriRoutine'') + N'''''';'';

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate

SELECT @wldate = winlostdate
FROM @archiveDate
WHERE rid = 2;

DECLARE @rowcount INT;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettrans14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransm14'';
WAITFOR DELAY ''00:00:03'';

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''sum_winloss'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''translog14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransLC14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransRNG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;
 
EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''others'';
WAITFOR DELAY ''00:00:03'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 3 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 4 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'3'
						,	@step_id					= 4
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME);
DECLARE @wldate SMALLDATETIME
, @WaitFor NVARCHAR(MAX);

-- Dynamic Delay Time --
SELECT	@WaitFor = N'''';
SELECT	@WaitFor = @WaitFor + N''WAITFOR DELAY '''''' + dbo.f_BU_GetDelayTime(''FriRoutine'') + N'''''';'';

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate

SELECT @wldate = winlostdate
FROM @archiveDate
WHERE rid = 3;

DECLARE @rowcount INT;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettrans14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransm14'';
WAITFOR DELAY ''00:00:03'';

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''sum_winloss'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''translog14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransLC14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransRNG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;
 
EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''others'';
WAITFOR DELAY ''00:00:03'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 4 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 5 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'4'
						,	@step_id					= 5
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME);
DECLARE @wldate SMALLDATETIME
, @WaitFor NVARCHAR(MAX);

-- Dynamic Delay Time --
SELECT	@WaitFor = N'''';
SELECT	@WaitFor = @WaitFor + N''WAITFOR DELAY '''''' + dbo.f_BU_GetDelayTime(''FriRoutine'') + N'''''';'';

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate

SELECT @wldate = winlostdate
FROM @archiveDate
WHERE rid = 4;

DECLARE @rowcount INT;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettrans14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransm14'';
WAITFOR DELAY ''00:00:03'';

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''sum_winloss'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''translog14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransLC14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransRNG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;
 
EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''others'';
WAITFOR DELAY ''00:00:03'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 5 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 6 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'5'
						,	@step_id					= 6
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME);
DECLARE @wldate SMALLDATETIME
, @WaitFor NVARCHAR(MAX);

-- Dynamic Delay Time --
SELECT	@WaitFor = N'''';
SELECT	@WaitFor = @WaitFor + N''WAITFOR DELAY '''''' + dbo.f_BU_GetDelayTime(''FriRoutine'') + N'''''';'';

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate

SELECT @wldate = winlostdate
FROM @archiveDate
WHERE rid = 5;

DECLARE @rowcount INT;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettrans14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransm14'';
WAITFOR DELAY ''00:00:03'';

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''sum_winloss'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''translog14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransLC14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransRNG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;
 
EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''others'';
WAITFOR DELAY ''00:00:03'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 6 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 7 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'6'
						,	@step_id					= 7
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME);
DECLARE @wldate SMALLDATETIME
, @WaitFor NVARCHAR(MAX);

-- Dynamic Delay Time --
SELECT	@WaitFor = N'''';
SELECT	@WaitFor = @WaitFor + N''WAITFOR DELAY '''''' + dbo.f_BU_GetDelayTime(''FriRoutine'') + N'''''';'';

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate

SELECT @wldate = winlostdate
FROM @archiveDate
WHERE rid = 6;

DECLARE @rowcount INT;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettrans14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransm14'';
WAITFOR DELAY ''00:00:03'';

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''sum_winloss'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''translog14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransLC14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransRNG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;
 
EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''others'';
WAITFOR DELAY ''00:00:03'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 7 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 8 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'7'
						,	@step_id					= 8
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 3
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME);
DECLARE @wldate SMALLDATETIME
, @WaitFor NVARCHAR(MAX);

-- Dynamic Delay Time --
SELECT	@WaitFor = N'''';
SELECT	@WaitFor = @WaitFor + N''WAITFOR DELAY '''''' + dbo.f_BU_GetDelayTime(''FriRoutine'') + N'''''';'';

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate

SELECT @wldate = winlostdate
FROM @archiveDate
WHERE rid = 7;

DECLARE @rowcount INT;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettrans14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransm14'';
WAITFOR DELAY ''00:00:03'';

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''sum_winloss'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''translog14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransLC14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;

SELECT @rowcount = 1;
WHILE @rowcount <> 0
BEGIN;
	EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''bettransRNG14'', @rowcount = @rowcount OUTPUT;
	EXECUTE sys.sp_executesql @Query = @WaitFor;
END;
 
EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'', @deletedTarget = ''others'';
WAITFOR DELAY ''00:00:03'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 8 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
END;

---- Step 9 ----
BEGIN;
	EXECUTE	@ReturnCode	= msdb.dbo.sp_update_jobstep
							@job_id						= @jobId
						,	@step_name					= N'Last Round'
						,	@step_id					= 9
						,	@cmdexec_success_code		= 0
						,	@on_success_action			= 1
						,	@on_success_step_id			= 0
						,	@on_fail_action				= 2
						,	@on_fail_step_id			= 0
						,	@retry_attempts				= 0
						,	@retry_interval				= 0
						,	@os_run_priority			= 0
						,	@subsystem					= N'TSQL'
						,	@database_name				= N'bodb02'
						,	@flags						= 0
						,	@command					= N'
DECLARE @archiveDate TABLE (rid INT PRIMARY KEY IDENTITY(1,1), winlostdate SMALLDATETIME)

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate
FROM dbo.Task_ArchiveDate WITH (NOLOCK)
ORDER BY winlostdate;

--- will edit ExecRep_02 to add last round later, which will cover data missmatch between servers

--DECLARE @wldate SMALLDATETIME;

--SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 1;
--EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'';

--SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 2;
--EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'';

--SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 3;
--EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'';

--SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 4;
--EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'';

--SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 5;
--EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'';

--SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 6;
--EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'';

--SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 7;
--EXECUTE dbo.ExecRep_02 @winlostdate = @wldate, @Command = ''ALL_DB'';
';

	IF	@@ERROR <> 0 OR @ReturnCode <> 0
		GOTO QuitWithRollback;

	SELECT	@msg = N'STEP 9 ADDED';
	RAISERROR(@msg, 0, 0) WITH NOWAIT;
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
/*<info serverAlias="DBTXN-msdb" executers="" viewers="" isFunction="0" isNested="0"></info>*/
/***
	- Created@2021224: Bobby
	- Host: Run on DB052N2
	- Task: Migrate SQLJobs
***/
USE [msdb]
GO

/****** Object:  Job [__SYNC: [DB052-DB054] RMS]    Script Date: 12/24/2021 6:26:14 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:14 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'__SYNC: [DB052-DB054] RMS', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'thien', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step1: STDBY Sync bodb_RMS]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step1: STDBY Sync bodb_RMS', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
---- Sync Data bodb_RMS 

EXEC bodb_RMS.dbo.[Task_STDBY_Sync_RMS]

', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sch: STDBY Sync', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130411, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'f3e4621d-f36f-4221-8369-a007366e4a68'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [__SYNC: [DB053 to DB052] - bodb_PlaytechCS]    Script Date: 12/24/2021 6:26:14 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:14 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'__SYNC: [DB053 to DB052] - bodb_PlaytechCS', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PlaytechCS - Sync data]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PlaytechCS - Sync data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Stdby_Sync_Dep_PlaytechCS', 
		@database_name=N'bodb_PlaytechCS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sync BK]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sync BK', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--exec dbo.Task_ImportQueue_Sync_BK', 
		@database_name=N'bodb_PlaytechCS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'3 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140527, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'8dff7995-270d-4748-a9e4-a5a2bf22c809'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [__SYNC: [DB053 to DB052] - bodb_PlaytechCS-2]    Script Date: 12/24/2021 6:26:14 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:14 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'__SYNC: [DB053 to DB052] - bodb_PlaytechCS-2', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sync bodb_PlayTechCS]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sync bodb_PlayTechCS', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_SYNC_bodb_PlayTechCS_NoRepTableFromDB053', 
		@database_name=N'bodb_PlaytechCS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 30 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181004, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'77ec5ebc-9f2a-4143-b627-d9c3a4b3fc57'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [__SYNC: [DB053-DB052] bodb_Age]    Script Date: 12/24/2021 6:26:14 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:14 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'__SYNC: [DB053-DB052] bodb_Age', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'syncing max limit loss', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sync]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sync', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.Task_Sync_Data_4_LossWinloss', 
		@database_name=N'bodb_AGE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sch00006', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210611, 
		@active_end_date=99991231, 
		@active_start_time=700, 
		@active_end_time=235959, 
		@schedule_uid=N'c0018b9f-bd50-4cbf-97ff-08a2552847a0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_12BET: Generate Data Daily]    Script Date: 12/24/2021 6:26:14 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:14 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_12BET: Generate Data Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate Member Info]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate Member Info', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_Member_Ins
	
EXEC dbo.Task_Aff_ImportMemberSignUp', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Parse XML Data]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Parse XML Data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_APIProduct_ImportQueue_Process_Job', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate Member Data]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate Member Data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ImportData_Job
	
EXEC dbo.Task_Aff_ImportData_API_Job', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Member Data]    Script Date: 12/24/2021 6:26:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Member Data', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ImportData_CheckData_Job
	
EXEC dbo.Task_Aff_ImportData_API_CheckData_Job', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 30 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd49ac940-a713-4b53-aabd-12919a749660'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_12BET: Summarize Data Monthly]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_12BET: Summarize Data Monthly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Click Statistics]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Click Statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_ClickStatistics_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Setting]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Setting', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Settings_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Calculate Commission]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Calculate Commission', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 5
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Monthly_Commission @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1st Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959, 
		@schedule_uid=N'15362431-c6db-48e0-accb-fa87eb245272'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5th Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=5, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e124bc32-07c2-4ac0-927f-2aad2760c611'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_12BET-On_user : clear login]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_12BET-On_user : clear login', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exec Task_Aff_ClearLogin_Loop]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exec Task_Aff_ClearLogin_Loop', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec Task_Aff_ClearLogin_Loop', 
		@database_name=N'Affiliate_12BET', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'On_User Clear Login', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110609, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'7538ed42-b81f-4060-88e9-e72c92757075'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_AonCash: Backup Commission Group]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_AonCash: Backup Commission Group', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Backup Commission Group]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Backup Commission Group', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'     DECLARE @date smalldatetime
      DECLARE @month int, @year int
      select @date = dateadd(mm,-1, convert(varchar(10),CURRENT_TIMESTAMP,120))
      select @month = DATEPART(month, @date ), @year = DATEPART(year, @date )

      EXEC [Task_Aff_GroupSettingBackup]  @month, @year ', 
		@database_name=N'Affiliate_AonCash', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month Backup', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'546dafe8-f498-4826-a9b3-f61d577715fb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_AonCash: Clear Login]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_AonCash: Clear Login', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear Login]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear Login', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' Exec Task_Aff_ClearLogin_Loop', 
		@database_name=N'Affiliate_AonCash', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Clear Login', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'b0398f17-07ba-4cf9-9696-dd0eae366b52'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_AonCash: Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_AonCash: Commission Monthly Transfer', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Affiliate Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Affiliate Commission Monthly Transfer', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @PreviousMonth smalldatetime
select @PreviousMonth = DATEADD(mm, -1, CURRENT_TIMESTAMP)

DECLARE @Month int, @Year int
SELECT @Month = MONTH(@PreviousMonth), @Year = YEAR(@PreviousMonth)

EXEC [dbo].[Task_Aff_MonthlyTransfer_Job]
	@Month = @Month,
	@Year = @Year', 
		@database_name=N'Affiliate_AonCash', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0c3dbf15-407b-41f5-8dd0-f1b85030db45'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_AonCash: Daily Summary Rate]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_AonCash: Daily Summary Rate', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Daily Summary]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Daily Summary', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [dbo].[Task_Aff_DailySummaryClickRate]', 
		@database_name=N'Affiliate_AonCash', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Daily occur', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'861741c0-ff16-4f91-9c98-8587cebb3ad8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_Athena000: Backup Commission Group]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_Athena000: Backup Commission Group', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Backup Commission Group]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Backup Commission Group', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'     DECLARE @date smalldatetime
      DECLARE @month int, @year int
      select @date = dateadd(mm,-1, convert(varchar(10),CURRENT_TIMESTAMP,120))
      select @month = DATEPART(month, @date ), @year = DATEPART(year, @date )

      EXEC [Task_Aff_GroupSettingBackup]  @month, @year ', 
		@database_name=N'Affiliate_Athena000', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month Backup', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'546dafe8-f498-4826-a9b3-f61d577715fb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_Athena000: Clear Login]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_Athena000: Clear Login', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear Login]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear Login', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' Exec Task_Aff_ClearLogin_Loop', 
		@database_name=N'Affiliate_Athena000', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Clear Login', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'b0398f17-07ba-4cf9-9696-dd0eae366b52'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_Athena000: Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_Athena000: Commission Monthly Transfer', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Affiliate Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Affiliate Commission Monthly Transfer', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @PreviousMonth smalldatetime
select @PreviousMonth = DATEADD(mm, -1, CURRENT_TIMESTAMP)

DECLARE @Month int, @Year int
SELECT @Month = MONTH(@PreviousMonth), @Year = YEAR(@PreviousMonth)

EXEC [dbo].[Task_Aff_MonthlyTransfer_Job]
	@Month = @Month,
	@Year = @Year', 
		@database_name=N'Affiliate_Athena000', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0c3dbf15-407b-41f5-8dd0-f1b85030db45'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_Athena000: Daily Summary Rate]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_Athena000: Daily Summary Rate', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Daily Summary]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Daily Summary', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [dbo].[Task_Aff_DailySummaryClickRate]', 
		@database_name=N'Affiliate_Athena000', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Daily occur', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'861741c0-ff16-4f91-9c98-8587cebb3ad8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_itcbet: Backup Commission Group]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_itcbet: Backup Commission Group', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Backup Commission Group]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Backup Commission Group', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'     DECLARE @date smalldatetime
      DECLARE @month int, @year int
      select @date = dateadd(mm,-1, convert(varchar(10),CURRENT_TIMESTAMP,120))
      select @month = DATEPART(month, @date ), @year = DATEPART(year, @date )

      EXEC [Task_Aff_GroupSettingBackup]  @month, @year ', 
		@database_name=N'Affiliate_itcbet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month Backup', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'546dafe8-f498-4826-a9b3-f61d577715fb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_itcbet: Clear Login]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_itcbet: Clear Login', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear Login]    Script Date: 12/24/2021 6:26:15 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear Login', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' Exec Task_Aff_ClearLogin_Loop', 
		@database_name=N'Affiliate_itcbet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Clear Login', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'b0398f17-07ba-4cf9-9696-dd0eae366b52'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_itcbet: Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:15 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:15 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_itcbet: Commission Monthly Transfer', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Affiliate Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Affiliate Commission Monthly Transfer', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @PreviousMonth smalldatetime
select @PreviousMonth = DATEADD(mm, -1, CURRENT_TIMESTAMP)

DECLARE @Month int, @Year int
SELECT @Month = MONTH(@PreviousMonth), @Year = YEAR(@PreviousMonth)

EXEC [dbo].[Task_Aff_MonthlyTransfer_Job]
	@Month = @Month,
	@Year = @Year', 
		@database_name=N'Affiliate_itcbet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0c3dbf15-407b-41f5-8dd0-f1b85030db45'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_itcbet: Daily Summary Rate]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_itcbet: Daily Summary Rate', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Daily Summary]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Daily Summary', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [dbo].[Task_Aff_DailySummaryClickRate]', 
		@database_name=N'Affiliate_itcbet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Daily occur', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'861741c0-ff16-4f91-9c98-8587cebb3ad8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_MacauBet: Backup Commission Group]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_MacauBet: Backup Commission Group', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Backup Commission Group]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Backup Commission Group', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'     DECLARE @date smalldatetime
      DECLARE @month int, @year int
      select @date = dateadd(mm,-1, convert(varchar(10),CURRENT_TIMESTAMP,120))
      select @month = DATEPART(month, @date ), @year = DATEPART(year, @date )

      EXEC [Task_Aff_GroupSettingBackup]  @month, @year ', 
		@database_name=N'Affiliate_MacauBet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month Backup', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'546dafe8-f498-4826-a9b3-f61d577715fb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_MacauBet: Clear Login]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_MacauBet: Clear Login', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear Login]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear Login', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' Exec Task_Aff_ClearLogin_Loop', 
		@database_name=N'Affiliate_MacauBet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Clear Login', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959, 
		@schedule_uid=N'b0398f17-07ba-4cf9-9696-dd0eae366b52'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_MacauBet: Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_MacauBet: Commission Monthly Transfer', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Affiliate Commission Monthly Transfer]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Affiliate Commission Monthly Transfer', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @PreviousMonth smalldatetime
select @PreviousMonth = DATEADD(mm, -1, CURRENT_TIMESTAMP)

DECLARE @Month int, @Year int
SELECT @Month = MONTH(@PreviousMonth), @Year = YEAR(@PreviousMonth)

EXEC [dbo].[Task_Aff_MonthlyTransfer_Job]
	@Month = @Month,
	@Year = @Year', 
		@database_name=N'Affiliate_MacauBet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Every Month', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0c3dbf15-407b-41f5-8dd0-f1b85030db45'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_MacauBet: Daily Summary Rate]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_MacauBet: Daily Summary Rate', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Daily Summary]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Daily Summary', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [dbo].[Task_Aff_DailySummaryClickRate]', 
		@database_name=N'Affiliate_MacauBet', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: Daily occur', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'861741c0-ff16-4f91-9c98-8587cebb3ad8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_N88: Generate Data Daily]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_N88: Generate Data Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import Exchange Oanda]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import Exchange Oanda', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_ExchangeOanda_Import', 
		@database_name=N'Affiliate_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Updated Member Info]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Updated Member Info', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_MemberInfo_Upd', 
		@database_name=N'Affiliate_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import Member Data]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import Member Data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ImportData_Job', 
		@database_name=N'Affiliate_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear user login]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear user login', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ClearLogin', 
		@database_name=N'Affiliate_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 30 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'97e27e60-5356-47dd-8150-b6a5d6fa8755'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_N88: Summarize Data Monthly]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_N88: Summarize Data Monthly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Click Statistics]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Click Statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_ClickStatistics_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Setting]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Setting', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Settings_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Calculate Commission]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Calculate Commission', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 5
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Monthly_Commission @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1st Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959, 
		@schedule_uid=N'52d69b2f-fdae-4814-99e7-093b68de0433'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5th Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=5, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'f66c63ee-4365-4c24-9bc2-dde7c9de31e1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_N8B: Generate Data Daily]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_N8B: Generate Data Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import Exchange Oanda]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import Exchange Oanda', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_ExchangeOanda_Import', 
		@database_name=N'Affiliate_N8B', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Updated Member Info]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Updated Member Info', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_MemberInfo_Upd', 
		@database_name=N'Affiliate_N8B', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import Member Data]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import Member Data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ImportData_Job', 
		@database_name=N'Affiliate_N8B', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear user login]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear user login', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ClearLogin', 
		@database_name=N'Affiliate_N8B', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 30 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'4469d699-ee64-4357-a2b1-75e0ca075752'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_N8B: Summarize Data Monthly]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_N8B: Summarize Data Monthly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Click Statistics]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Click Statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_ClickStatistics_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N8B', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Setting]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Setting', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Settings_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N8B', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Calculate Commission]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Calculate Commission', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 5
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Monthly_Commission @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N8B', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1st Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959, 
		@schedule_uid=N'2ef4ebfe-fd32-4d24-8b3d-1f334487265d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5th Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=5, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'bc30fb9e-949c-4b56-b6e3-b76f2a106996'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_N8G: Generate Data Daily]    Script Date: 12/24/2021 6:26:16 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:16 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_N8G: Generate Data Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import Exchange Oanda]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import Exchange Oanda', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_ExchangeOanda_Import', 
		@database_name=N'Affiliate_N8G', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Updated Member Info]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Updated Member Info', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_MemberInfo_Upd', 
		@database_name=N'Affiliate_N8G', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import Member Data]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import Member Data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ImportData_Job', 
		@database_name=N'Affiliate_N8G', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clear user login]    Script Date: 12/24/2021 6:26:16 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clear user login', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Aff_ClearLogin', 
		@database_name=N'Affiliate_N8G', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 30 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c8f6b8f6-8399-48a7-8514-88bb96b13013'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Affiliate_N8G: Summarize Data Monthly]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Affiliate_N8G: Summarize Data Monthly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Click Statistics]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Click Statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_ClickStatistics_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N8G', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive Setting]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive Setting', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 1
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Settings_Archive @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N8G', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Calculate Commission]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Calculate Commission', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF DAY(GETDATE()) <> 5
	RETURN

DECLARE @MonthDate SMALLDATETIME
SELECT  @MonthDate = DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))

EXEC dbo.Task_Aff_Monthly_Commission @MonthDate = @MonthDate', 
		@database_name=N'Affiliate_N8G', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1st Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959, 
		@schedule_uid=N'680f1541-d5a9-48e5-9819-653805b71ad2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5th Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=5, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'8d3e1695-f9b1-4837-ae3b-6177e011c381'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [BK : Clear Old Bet]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BK : Clear Old Bet', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [clear]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'clear', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_ClearOldBet

EXEC dbo.Task_ClearOldBetTranslog', 
		@database_name=N'bk', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20080416, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'31220b7d-2c31-426d-9959-3fb213c5c8b9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [BK : FC]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BK : FC', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FC]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @transid bigint
select @transid= max( transid) from bk.dbo.bets with (rowlock)
exec [dbo].[Task_Bets_TransForecast] @transid

EXEC [dbo].[Task_Bets_TranslogForecast]', 
		@database_name=N'bk', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [2]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=4, 
		@on_fail_step_id=1, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'waitfor delay ''00:00:10''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Together with SQL Server Agent', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20071223, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'2dc86709-25cc-4f22-8bef-248d0a6dc4cf'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [BK : FC Rej]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BK : FC Rej', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [1]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'waitfor delay ''00:00:30''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Rej]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Rej', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=4, 
		@on_fail_step_id=1, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @transid bigint
select @transid= max( transid) from bk.dbo.betsreject with (rowlock)
exec [dbo].[Task_Bets_TransReject] @transid

exec [dbo].[Task_Bets_TranslogReject]', 
		@database_name=N'bk', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Together with SQL Server Agent', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20071223, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'f3b2373f-a9e9-479d-ad34-d11a485fbb1c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_3rdProduct: Check Exchange data monthly]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_3rdProduct: Check Exchange data monthly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check data is done importing]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check data is done importing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=3, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_ImportData_Status', 
		@database_name=N'bodb_3rdProduct', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait for delay 15 mins]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait for delay 15 mins', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAIT FOR DELAY ''00:00:15''', 
		@database_name=N'bodb_3rdProduct', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Data]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Sum_winloss_Exchange_CheckData', 
		@database_name=N'bodb_3rdProduct', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monthly at 17', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=17, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190401, 
		@active_end_date=99991231, 
		@active_start_time=130000, 
		@active_end_time=235959, 
		@schedule_uid=N'34dbca5f-3904-4748-938d-bccd63ed0ca5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monthly at 3', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=3, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190401, 
		@active_end_date=99991231, 
		@active_start_time=130000, 
		@active_end_time=235959, 
		@schedule_uid=N'c722815b-aede-43b0-ad40-11cbd0685a26'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Age: LimitLoss_Setting totalBalance update]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Age: LimitLoss_Setting totalBalance update', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Task_LimitLoss_Setting_TotalBalanceUpd_Job]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Task_LimitLoss_Setting_TotalBalanceUpd_Job', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_LimitLoss_Setting_TotalBalanceUpd_Job', 
		@database_name=N'bodb_Age', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'3 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140527, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'8dff7995-270d-4748-a9e4-a5a2bf22c809'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_CRM: Delete old feedback info weekly]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_CRM: Delete old feedback info weekly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [call sp]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'call sp', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Acc_CRM_AutoFeedbackInfoDel', 
		@database_name=N'bodb_CRM', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=3, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20200520, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'92c9f457-8447-4386-9b2b-ac7de2195051'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_licenseeReport: Daily CHECKSUM DepositData]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_licenseeReport: Daily CHECKSUM DepositData', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Validate DepositData]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Validate DepositData', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_ValidateDepositData_SUMTable', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check LicenseeCustInfo missing data]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check LicenseeCustInfo missing data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_LicenseeCustInfo_DataCheck', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check LicenseeCust missing data]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check LicenseeCust missing data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_LicenseeCustInfo_DataCheck @CheckType = 1', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Everyday', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140319, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'88785497-ce47-4c4f-b23b-1d251c094584'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_LicenseeReport: Daily Gen Daily rptLicIpBetting]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_LicenseeReport: Daily Gen Daily rptLicIpBetting', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Go]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Go', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicIPBetting_Job', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily After MoveBet', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161031, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'71c9ea87-f4e5-4ad3-9283-94b6c39e8f34'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_LicenseeReport: Daily Summary Licensee Winloss]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_LicenseeReport: Daily Summary Licensee Winloss', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update statistics]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE STATISTICS rptLicWinloss2
UPDATE STATISTICS rptCustomerTurnover
UPDATE STATISTICS rptWinlostbyLeague
UPDATE STATISTICS rptCustomerMatch
UPDATE STATISTICS rpt_BettingParlay
UPDATE STATISTICS rpt_BettingColossusBets
UPDATE STATISTICS rptLicWinlossGMT', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive BA Transaction - Copy data]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive BA Transaction - Copy data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_LicenseeBATransaction_Archive_Copy', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rptLicWinloss2]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rptLicWinloss2', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_DailyRptLicWinloss2_Job] @TableName = ''rptLicWinloss2''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rptCustomerTurnover]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rptCustomerTurnover', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_DailyRptLicWinloss2_Job] @TableName = ''rptCustomerTurnover''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rptWinlostbyLeague]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rptWinlostbyLeague', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_DailyRptLicWinloss2_Job] @TableName = ''rptWinlostbyLeague''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rptCustomerMatch]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rptCustomerMatch', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_DailyRptLicWinloss2_Job] @TableName = ''rptCustomerMatch''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rpt_BettingParlay]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rpt_BettingParlay', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_DailyRptLicWinloss2_Job] @TableName = ''rpt_BettingParlay''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rpt_BettingColossusBets]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rpt_BettingColossusBets', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_DailyRptLicWinloss2_Job] @TableName = ''rpt_BettingColossusBets''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rptLicWinlossGMT]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rptLicWinlossGMT', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_DailyRptLicWinloss2_Job] @TableName = ''rptLicWinlossGMT''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for @ rptCasinoTurnover]    Script Date: 12/24/2021 6:26:17 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for @ rptCasinoTurnover', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_Job @TableName = ''rptCasinoTurnover''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Everyday before MoveBet New', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161214, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959, 
		@schedule_uid=N'c51aaf98-0a4b-46af-bae2-539d813f0b8c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_LicenseeReport: DW - Check and Correct Data]    Script Date: 12/24/2021 6:26:17 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:17 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_LicenseeReport: DW - Check and Correct Data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Move Bets Finish]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Move Bets Finish', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=3, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_MoveBets_Status_Job
EXEC DBACC.bodb02.dbo.Task_MoveBets_Status_Job', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delay 15 minutes]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delay 15 minutes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:15:00.000''', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check data ready or not]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check data ready or not', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_bet14_CheckDataIsReady', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and correct data]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and correct data', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:03:00.000''
EXEC bodb_LicenseeReport.dbo.Task_PostStaging
EXEC dbo.Task_rptBetting_CheckData_Job @AllowCorrect = 1', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'After MoveBet - Move Tables', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170531, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'0b603c1f-19e5-4461-961e-141b001697fa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_LicenseeReport: DW - Generate Daily]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_LicenseeReport: DW - Generate Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Process data daily', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Readiness]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Readiness', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=12, 
		@retry_interval=10, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC bodb_LicenseeReport.dbo.Task_ImportQueue_CheckReady', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Process staging data]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Process staging data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=1, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_PostStaging
EXEC dbo.Task_PrepareStaging', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [GEN report 3rd Product]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'GEN report 3rd Product', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @WinlossDate DATE
SET @WinlossDate = DATEADD(DAY, -1, CONVERT(VARCHAR(10), GETDATE(), 120))
EXEC dbo.Task_DOT_3rd_DailySummary @WinlostDate = @WinlossDate', 
		@database_name=N'bodb_3rdProduct', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate Betting]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate Betting', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.GEN_Betting', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate rpt_BettingByProduct @ bodb_licenseeReport]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate rpt_BettingByProduct @ bodb_licenseeReport', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @fromDate datetime, @toDate datetime
SELECT @fromDate = min(winlostdate) FROM bodb02.dbo.bettrans14 (NOLOCK)
SET @toDate = DATEADD(DAY,-1,CONVERT(VARCHAR(10),GETDATE(),120))

EXEC dbo.GEN_rptBettingByProduct @fromDate, @toDate', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gen data for Microgaming Casino Report @bodb_LicenseeReport]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gen data for Microgaming Casino Report @bodb_LicenseeReport', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @WinlossDate DATE, @BF_EarlyDay DATE
SET @WinlossDate = DATEADD(DAY, -1, CONVERT(VARCHAR(10), GETDATE(), 120))
SET @BF_EarlyDay = DATEADD(DAY, -2, @WinlossDate)
WHILE @WinlossDate >= @BF_EarlyDay
BEGIN
	EXEC dbo.Task_Microgaming_Bettrans @WinlossDate = @WinlossDate

	EXEC dbo.Task_rpt_CustomerWL_ExtraGMT @WinlostDate = @WinlossDate

	SET @WinlossDate = DATEADD(DAY, -1, @WinlossDate)
END', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate rpt_BettingBySport @ bodb_LicenseeReport]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate rpt_BettingBySport @ bodb_LicenseeReport', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @WinlossDate DATE
SET @WinlossDate = DATEADD(DAY, -1, CONVERT(VARCHAR(10), GETDATE(), 120))
EXEC dbo.GEN_rptBettingBySport @Date = @WinlossDate', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [POST staging :)]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'POST staging :)', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--coment for debuging
--EXEC dbo.Task_PostStaging


UPDATE bodb02.dbo.SystemSettings WITH(ROWLOCK, UPDLOCK)
SET VValue = 0
WHERE VName = ''IsStagingBettrans''
	AND VValue = 1', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'End of business day', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110623, 
		@active_end_date=99991231, 
		@active_start_time=11500, 
		@active_end_time=235959, 
		@schedule_uid=N'7e0fef12-a6ec-446a-84f4-a8505827bd6c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_LicenseeReport: DWPromotion - Generate Daily]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_LicenseeReport: DWPromotion - Generate Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Licensee Promotion - Process data daily', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Saba Promotion - Summany]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Saba Promotion - Summany', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[Task_DailySummaryLicPromotion_Job]', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'End of business day', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110623, 
		@active_end_date=99991231, 
		@active_start_time=11500, 
		@active_end_time=235959, 
		@schedule_uid=N'7e0fef12-a6ec-446a-84f4-a8505827bd6c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_LicenseeReport: Licensee Winloss - Check and Correct Data]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_LicenseeReport: Licensee Winloss - Check and Correct Data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Move Bets Finish]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Move Bets Finish', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=3, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_MoveBets_Status_Job

EXEC DBACC.bodb02.dbo.Task_MoveBets_Status_Job', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delay 15 minutes]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delay 15 minutes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:15:00.000''', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check data ready or not]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check data ready or not', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_bet14_CheckDataIsReady', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update statistics]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update statistics', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:03:00.000''
UPDATE STATISTICS bettrans14', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive BA Transaction - Correct and Delete data]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive BA Transaction - Correct and Delete data', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_LicenseeBATransaction_Archive_Delete', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rptLicWinloss2]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rptLicWinloss2', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:03:00.000''
EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rptLicWinloss2''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rptCustomerTurnover]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rptCustomerTurnover', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rptCustomerTurnover''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rptWinlostbyLeague]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rptWinlostbyLeague', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rptWinlostbyLeague''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rptCustomerMatch]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rptCustomerMatch', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rptCustomerMatch''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rpt_BettingParlay]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rpt_BettingParlay', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rpt_BettingParlay''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rpt_BettingColossusBets]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rpt_BettingColossusBets', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rpt_BettingColossusBets''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rptLicWinlossGMT]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rptLicWinlossGMT', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rptLicWinlossGMT''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check and Correct Data for @ rptCasinoTurnover]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check and Correct Data for @ rptCasinoTurnover', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptLicWinloss2_CheckData_Job @TableName = ''rptCasinoTurnover''', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'After MoveBet - Move Tables', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160729, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'c0da765c-d00a-4280-9d35-100db0031252'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_N88: API_Queue Process]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_N88: API_Queue Process', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exec SP]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exec SP', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_API_Queue_Process', 
		@database_name=N'bodb_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200520, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'b20d240f-8271-459b-82f1-b101bcf2d2a4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_N88: Generate daily data for N88_RptWinloss]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_N88: Generate daily data for N88_RptWinloss', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate daily data for N88_SumWinloss]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate daily data for N88_SumWinloss', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_N88_SumWinloss_Job', 
		@database_name=N'bodb_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Auto repull data]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Auto repull data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_N88_RepullData', 
		@database_name=N'bodb_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Generate daily data]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Generate daily data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_N88_RptWinloss_Job', 
		@database_name=N'bodb_N88', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Generate daily data', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200514, 
		@active_end_date=99991231, 
		@active_start_time=1500, 
		@active_end_time=1459, 
		@schedule_uid=N'361cbed9-ba2f-4ae1-ae48-0df7e49afc5d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_oddsfeed: Move PartnerStatistics]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_oddsfeed: Move PartnerStatistics', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [move partner statistics]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'move partner statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_Odds_Partner_MoveToArchivePeriod3Months', 
		@database_name=N'bodb_oddsfeed', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [clear login]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'clear login', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec Task_Odds_ClearLogin', 
		@database_name=N'bodb_oddsfeed', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'4:05PM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170703, 
		@active_end_date=99991231, 
		@active_start_time=160500, 
		@active_end_time=235959, 
		@schedule_uid=N'76b99336-1e81-45d7-8b86-53ed2d476ddd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_PlaytechCS: Execute Product3rd_ImportQueue Background]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_PlaytechCS: Execute Product3rd_ImportQueue Background', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute queue background]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute queue background', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Product3rd_ImportQueue_Process', 
		@database_name=N'bodb_PlaytechCS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 5 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130617, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'7cc1c7da-2ee0-45de-8a1c-85e8a3e4ebd3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Ploutos: Archive Data]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Ploutos: Archive Data', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archive data in DB052 and DB053 to BK tables]    Script Date: 12/24/2021 6:26:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archive data in DB052 and DB053 to BK tables', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Plo_Archiving_Process_Job', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'bodb_Ploutos - Archive Data - Occurs every first Monday of every 1 month(s) at 1:00:00 AM', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=1, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210416, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'3f68d26e-15dd-49d4-9d18-263fa60e1eca'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Ploutos: BetTicket Filtering and VC - 3RD Products]    Script Date: 12/24/2021 6:26:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Ploutos: BetTicket Filtering and VC - 3RD Products', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Ploutos - Process 3RD Bet Tickets from DBPLO', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 1: Pull 3rd Tickets from yesterday bettrans to STAGING]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1: Pull 3rd Tickets from yesterday bettrans to STAGING', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @currentDate DATE, @yesterday DATE, @errorMsg nvarchar(250);

SELECT @currentDate = GETDATE()
	,@yesterday = DATEADD(DD,-1,@currentDate);

EXEC dbo.Task_Plo_BetTicket_Pull_3RD
	@Winlostdate = @yesterday
	,@ErrorMessage = @errorMsg OUTPUT

IF LEN(@errorMsg) > 0
	RAISERROR(@errorMsg, 11, 1)', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 2: Run Volume Control - 3RD Products]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 2: Run Volume Control - 3RD Products', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @currentDate DATE
	, @monthDate DATE
	, @yesterday DATE
	, @errorMsg NVARCHAR(250)

SELECT @currentDate = GETDATE()
	, @yesterday = DATEADD(DD, -1, @currentDate)
	, @monthDate = DATEADD(DD,-DATEPART(DAY, @yesterday)+1,@yesterday);

IF @yesterday >= ''20200804''
BEGIN
	EXEC dbo.Task_Plo_VolumeControl_3RD
		@MonthDate = @monthDate
		, @Winlostdate = @yesterday
		, @ErrorMessage = @errorMsg OUTPUT
END

IF LEN(@errorMsg) > 0
	RAISERROR(@errorMsg, 11, 1)', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Ploutos Schedule - Run 3rd Products - Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200504, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'553b4799-bd7e-4826-a0a8-830ba2d050d0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Ploutos: BetTicket Filtering and VC - Sportbook]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Ploutos: BetTicket Filtering and VC - Sportbook', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Ploutos - Process SB Bet Tickets from DBBAH.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 1: Pull Settled Tickets from DB05 to STAGING]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1: Pull Settled Tickets from DB05 to STAGING', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @ErrorMessage VARCHAR(250) = '''';
EXEC dbo.Task_Plo_BetTicket_Pull
	@ErrorMessage = @ErrorMessage OUTPUT

IF (LEN(@ErrorMessage) > 0)
BEGIN
	RAISERROR(@ErrorMessage, 12, 1)
END', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 2: CleanUp settlement ticket from DBBAH by RowID]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 2: CleanUp settlement ticket from DBBAH by RowID', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--1st 5mins to clean up data for the previous hours
IF DATEPART(MINUTE, CURRENT_TIMESTAMP) < 2 
BEGIN
	exec dbo.Task_Plo_BetTicket_CleanUp
END
', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 3: Run Volume Control - Sportbook]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 3: Run Volume Control - Sportbook', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @currentTime DATETIME, @currentDate DATE, @monthDate DATE, @monthHourpart INT, @monthHourpart_PREV INT;

SELECT @currentTime = GETDATE()
	, @currentDate = @currentTime
	, @monthDate = DATEADD(DD,-DATEPART(DAY,@currentDate)+1,@currentDate)
	, @monthHourpart = (DATEPART(DAY, @currentDate) - 1) * 24 + DATEPART(HOUR, @currentTime)
	, @monthHourpart_PREV = @monthHourpart - 1;

IF @currentDate >= ''20200804'' AND @monthHourpart_PREV >= 0 --> check for the 1st hour of month
	AND NOT EXISTS (
	SELECT 1 
	FROM dbo.VolumeControlRunningTotal WITH(NOLOCK)
	WHERE MonthDate = @monthDate  AND MonthHourPart = @monthHourpart_PREV
)
BEGIN
	DECLARE @ErrorMessage		VARCHAR(250) = '''';

	EXEC [dbo].[Task_Plo_VolumeControl_SB]
		@MonthDate = @monthDate
		,@MonthHourpart = @monthHourpart_PREV
		, @ErrorMessage = @ErrorMessage OUTPUT

	IF LEN(@ErrorMessage) > 0
		RAISERROR(@ErrorMessage, 12, 1)
END', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 4: Copy VC Setting from Next Month to Current Month]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 4: Copy VC Setting from Next Month to Current Month', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @currentTime DATETIME, @monthHourpart INT, @monthDate DATE

SELECT @currentTime = GETDATE()
	, @monthHourpart = (DATEPART(DAY, @currentTime) - 1) * 24 + DATEPART(HOUR, @currentTime)
	, @monthDate = DATEADD(DD,-DATEPART(DAY,@currentTime)+1,@currentTime)

IF (@monthHourpart = 0
	AND EXISTS (SELECT TOP 1 1 FROM VolumeControlSetting_NextMonths vn WITH(NOLOCK) WHERE vn.MonthDate = @monthDate)
	) -- first hour of the month
BEGIN
	EXEC [dbo].[Task_Plo_VolumeControl_Setting_MonthlyUpdate] 
		@MonthDate = @monthDate

END', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'bodb_Ploutos - BetTicket Process Pull - Sportbook', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200110, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'060fe3be-4196-4da5-b328-e333bd16d177'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Ploutus: Check Data Consistency]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Ploutus: Check Data Consistency', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Non Deposit Player]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Non Deposit Player', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_Plo_UpdateNonDepositPlayer', 
		@database_name=N'bodb_Ploutos', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'End of Date', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20191127, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, 
		@schedule_uid=N'b128ab3d-0b9c-4aca-8966-8799336c20d1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_RMS: Check Sum & Delete Data]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_RMS: Check Sum & Delete Data', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Move Bets Finish]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Move Bets Finish', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=3, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_MoveBets_Status_Job', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delay 15 minutes]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delay 15 minutes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:15:00.000''', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Sum data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Sum data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_CheckSumData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete data', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_DeleteData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200512, 
		@active_end_date=99991231, 
		@active_start_time=201500, 
		@active_end_time=235959, 
		@schedule_uid=N'8c8b0c86-7f46-4180-a3ac-4c86f5daa502'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_RMS: Copy & Sum Data]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_RMS: Copy & Sum Data', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_CopyData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sum data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sum data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_SumData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'schedule2222', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200619, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'3d0f1918-b426-49a2-a9b0-af258bd09880'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_RMS: Copy parlay tickets to rmBettrans]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_RMS: Copy parlay tickets to rmBettrans', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step: Copy tickets to rmBettrans]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step: Copy tickets to rmBettrans', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[Task_RMS_SyncDataForBettransParlay_Job]', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sch: Copy parlay tickets rmBettrans', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130130, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'16e6c8ba-7326-429d-8041-64d1faaa99f9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_RMS: MBU Check Sum & Delete Data]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_RMS: MBU Check Sum & Delete Data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Move Bets Finish]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Move Bets Finish', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=3, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_MoveBets_Status_Job', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delay 15 minutes]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delay 15 minutes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:15:00.000''', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Sum data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Sum data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_MBU_CheckSumData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete data', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_MBU_DeleteData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200512, 
		@active_end_date=99991231, 
		@active_start_time=201500, 
		@active_end_time=235959, 
		@schedule_uid=N'f317e954-7b2c-49ff-9a3e-48c0c62d629d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_RMS: MBU Copy & Sum Data]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_RMS: MBU Copy & Sum Data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_MBU_CopyData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sum data]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sum data', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_RMS_MBU_SumData_Job', 
		@database_name=N'bodb_RMS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'schedule2222', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200619, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'cbffe5af-df77-4104-9055-5880e91e0877'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Summary - Weekly Company Balance History]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Summary - Weekly Company Balance History', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Get Company Balance]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Get Company Balance', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_BalanceCompany_HistoryIns', 
		@database_name=N'bodb_Summary', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Friday_Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=32, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20100408, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'ddff53c4-04d2-4a0f-ad1d-9722de902336'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Summary: Check and Correct Data - After MoveBets]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Summary: Check and Correct Data - After MoveBets', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Move Bets Finish]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Move Bets Finish', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=3, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_MoveBets_Status_Job', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delay 15 minutes]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delay 15 minutes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:15:00.000''', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RptProgressiveGamesContribution]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RptProgressiveGamesContribution', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptProgressiveGamesContribution_CheckData_Job', 
		@database_name=N'bodb_Summary', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CS_SumWinloss/CS_SumCancelled]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CS_SumWinloss/CS_SumCancelled', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_CS_Summary_CheckAndCorrect_Job', 
		@database_name=N'bodb_Summary', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sum_Winloss_Extra]    Script Date: 12/24/2021 6:26:19 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sum_Winloss_Extra', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailySum_Winloss_Extra_CheckData_Job', 
		@database_name=N'bodb_Summary', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180320, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'a54b5dd5-ae86-4b1f-a2eb-150a0ec98466'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Summary: Generate Data - Before MoveBets]    Script Date: 12/24/2021 6:26:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:19 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Summary: Generate Data - Before MoveBets', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RptProgressiveGamesContribution]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RptProgressiveGamesContribution', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailyRptProgressiveGamesContribution_Job', 
		@database_name=N'bodb_Summary', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Sum_Winloss_Extra]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Sum_Winloss_Extra', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DailySum_Winloss_Extra_Job', 
		@database_name=N'bodb_Summary', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180320, 
		@active_end_date=99991231, 
		@active_start_time=63000, 
		@active_end_time=235959, 
		@schedule_uid=N'2604dd23-50ce-46e3-ac15-ef941472b100'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb_Summary: Generate Data - CN88]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb_Summary: Generate Data - CN88', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CS_SumWinloss/CS_SumCancelled]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CS_SumWinloss/CS_SumCancelled', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC Task_CS_Summary_Job', 
		@database_name=N'bodb_Summary', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 2 hours from 0:00AM to 6:00AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190816, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=60000, 
		@schedule_uid=N'8bd53574-5938-456c-b908-c23b9ca620b2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02 : bettrans_running DELETE]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02 : bettrans_running DELETE', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Task_Delete_bettrans_running]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Task_Delete_bettrans_running', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Delete_bettrans_running', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Loop]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Loop', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare @i int', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1 minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20121203, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'4a5513fe-311f-44db-9661-0879e5b109e3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02 : Remove Settlement Logs]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02 : Remove Settlement Logs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Remove settlement logs', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [remove settement logs]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'remove settement logs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON
DECLARE @__CreationTime DATETIME
SET @__CreationTime = DATEADD(DAY, -8, GETDATE())
EXEC dbo.Task_SSB_RemoveData_SettlementLogs @CreationTime = @__CreationTime', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'2:00am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111015, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'79a1efda-e0d2-4c53-a846-5c835178419a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: Check Settlement status]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: Check Settlement status', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 1 - Check SSB commands status]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 1 - Check SSB commands status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=2, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.SSB_Settlement_MonitorLogs @MonitorDurationWithInMin = 120', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step 2 - Check SettlementLock]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step 2 - Check SettlementLock', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC DBA_CheckSettlementLockTimeout @MonitorDurationWithInMin = 15', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 1 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20211028, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1f90b6b8-3c9c-428a-b751-5bf178d6f174'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: Check/Verify ExchangeDaily]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: Check/Verify ExchangeDaily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run Jobs ExchangeDaily]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Jobs ExchangeDaily', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @yesterday  DATETIME,
	  @today	      DATETIME,
	  @tomorrow  DATETIME

SELECT	@yesterday = CAST(CONVERT(VARCHAR(10),  DATEADD(d,-1,getdate()), 111) AS DATETIME),
	@today	    = CAST(CONVERT(VARCHAR(10), getdate(), 111) AS DATETIME),
	@tomorrow  = CAST(CONVERT(VARCHAR(10),  DATEADD(d,1,getdate()), 111) AS DATETIME)

--today check
EXEC [Task_Acc_ExchangeDaily_Check] @InputDate= @today

--yesterday check
EXEC [Task_Acc_ExchangeDaily_Check] @InputDate= @yesterday

--tomorrow check 
EXEC [Task_Acc_ExchangeDaily_Check] @InputDate= @tomorrow
', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule ExchangeDaily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110215, 
		@active_end_date=99991231, 
		@active_start_time=233500, 
		@active_end_time=235959, 
		@schedule_uid=N'0dea0fa6-6b99-4770-a74b-fc07388ea9d4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: DBA monitor TLog]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: DBA monitor TLog', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [shrinklog if need]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'shrinklog if need', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC vndba_TrackingTlog ''bodb02''
', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N's1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160411, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e6ad5df3-ad4d-485d-834b-141dacd241f2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: Retrieve BA Transaction]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: Retrieve BA Transaction', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Call Jobs: Insert BA Transaction]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Call Jobs: Insert BA Transaction', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_BATransaction_Ins', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DetectBAMemberBreakRules]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DetectBAMemberBreakRules', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_DetectBAMemberBreakRules', 
		@database_name=N'bodb_Licensee', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [delay]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'delay', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''000:00:01''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule: BA Transaction', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110629, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'9b08a3d2-9579-4d45-8e4e-b9e99c3901d3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: SSB - Get settled tickets]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: SSB - Get settled tickets', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [bettrans]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'bettrans', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.Task_Get_Tickets_settled2', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [waitfor]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'waitfor', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WAITFOR DELAY ''00:00:00:030''', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'10s', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180621, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'9f888f2f-5683-44f3-9a83-e6077de43eee'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: SSB - TO Control -  Get tickets]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: SSB - TO Control -  Get tickets', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [bodb02: SSB - TOControl - get  tickets Insert]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'bodb02: SSB - TOControl - get  tickets Insert', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'while 1 = 1
begin
	EXEC Task_TOControl_GetTickets_Insert
	
	EXEC [dbo].[Task_TOControl_GetTickets_Update]
end', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [bodb02: SSB - TOControl - get  tickets Update]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'bodb02: SSB - TOControl - get  tickets Update', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_TOControl_GetTickets_Update]', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'10s', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180626, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0b42856e-ce4d-42fe-a72d-2d7853dd5276'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: TOControl Delete old transition]    Script Date: 12/24/2021 6:26:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: TOControl Delete old transition', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete old transtion]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete old transtion', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.TASK_TOControl_DeleteOldTransition', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete settled transition]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete settled transition', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[Task_BetSettled_DeleteOldTransition]', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TO Control Delete Insert]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TO Control Delete Insert', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'[dbo].[TASK_TOControl_DeleteTicketDetails_Insert]', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TO Control Delete Update]    Script Date: 12/24/2021 6:26:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TO Control Delete Update', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[TASK_TOControl_DeleteTicketDetails_Update]', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 6 hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170327, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'23753fa7-4e77-4d77-9ef0-3e70711dae38'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [bodb02: Verify BA Tickets]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'bodb02: Verify BA Tickets', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'vnDBA', 
		@notify_email_operator_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Call Jobs: Check date]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Call Jobs: Check date', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--new table
--EXEC dbo.Task_DailyRptLicWinloss2_Job

--EXEC Task_DailyRptLicWinloss3_Job

--Run Jobs BA Tickets Checking
EXEC [Task_BATransaction_CheckAndCorrect]', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'15 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130104, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'08c85c3e-1af2-4e67-89df-7c8a755059a4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DB052 : VERIFY DailySummary (Move Bet)]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DB052 : VERIFY DailySummary (Move Bet)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Verify Tomorrow Move Bet]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verify Tomorrow Move Bet', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @msg NVARCHAR(1000)
BEGIN TRY
	EXEC dbo.Task_DailySummary_VerifyJob
	 
END TRY 
BEGIN CATCH
	SELECT @msg = ERROR_MESSAGE()	

	EXEC DBLOG.bodb_customerLog.dbo.dba_sendNotification @servername = ''DB052'', @Title = ''DailySummary Verify MoveBet'', @msginfo = @msg
	
	RAISERROR(@msg,16,1)
END CATCH

', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Local night (4:30pm)', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110719, 
		@active_end_date=99991231, 
		@active_start_time=43000, 
		@active_end_time=235959, 
		@schedule_uid=N'5ac9132b-d2c0-454d-917d-44bd712b6f33'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - performance report (daily) test]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - performance report (daily) test', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Author: Vivi
Create date: 2018/03/15
Description: auto email for exchange project', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [exchange auto email]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'exchange auto email', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBA_Report_AutoEMail_Exchange_cvs', 
		@database_name=N'bodb_3rdProduct', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA_BAS_Exchange_DailySummary]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA_BAS_Exchange_DailySummary', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBA_BAS_Exchange_DailySummary', 
		@database_name=N'bodb_3rdProduct', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily 01:00 am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180314, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'2aa82f7b-14f6-4695-bfda-c944f1654720'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA : MonDB Get DB Info]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA : MonDB Get DB Info', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set 1 Exec sp]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set 1 Exec sp', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec DBA_Mon_GetDB_Info', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [waitfor10sec]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'waitfor10sec', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=1, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'waitfor delay ''00:00:10''', 
		@database_name=N'MONDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140205, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'4fa142a6-f433-4a15-b771-c8a8bed7615c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA : Monitor Job Fail]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA : Monitor Job Fail', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'20170309@Cooper/Alfie:merge [DBA_MonitorJobFail] and MonDB:[DBA_Mon_Get_JobStatus_Info]', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [startSP:mondb.dbo.DBA_MonitorJobFail]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'startSP:mondb.dbo.DBA_MonitorJobFail', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--The Time already add 12h
exec [DBA_MonitorJobFail]', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ExcuteTime', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161212, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'9c8b3ebc-6387-4200-8690-a7e786fff39d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA : Send SQL Service Restart Alert Mail]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA : Send SQL Service Restart Alert Mail', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Alert for SQL Server Agent Started. In order to get alert mail for check if the SQL Server also been restarted.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Send_Email_Step]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Send_Email_Step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''DB052Profile'',
@recipients = ''DBAAdmin@onelab.tw'',
@copy_recipients='''',
@query = ''SELECT getdate()'',
@body=''This is an informational message only: SQL Server Services possibly restarted on DB052 (10.40.40.92, 10.40.40.93, 10.1.1.92). Please check it!!'',
@subject=''SQL Services Restarted on DB052, Please Check!!''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Service_Restart_Notification', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120926, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'5f0b7cab-5f1b-4d73-a131-00a6cbcdd8aa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA: Database BackupHistory Cleanup]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA: Database BackupHistory Cleanup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'vnDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXEC BackupHistory  Cleanup]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC BackupHistory  Cleanup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.TASK_DatabaseBackupCleanup @Retention_months = 3', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'BackupHistory Cleanup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150810, 
		@active_end_date=99991231, 
		@active_start_time=300, 
		@active_end_time=235959, 
		@schedule_uid=N'fe37e276-5419-4584-86bd-32d7c5a0fded'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA: update stats]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA: update stats', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [update stats]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'update stats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA_Reorg_Index'')) = 1
	RETURN

IF DATEPART(HOUR,CURRENT_TIMESTAMP) >= 22
BEGIN
	EXEC sp_updatestats
END
ELSE
BEGIN
	UPDATE STATISTICS dbo.bettrans
	UPDATE STATISTICS dbo.bettransM
	UPDATE STATISTICS dbo.bettransG
	UPDATE STATISTICS dbo.bettransLC
	UPDATE STATISTICS dbo.bettransRnG
END', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [update stats - bodb_LicenseeReport]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'update stats - bodb_LicenseeReport', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA : DBA_ReIndex'')) = 1
	RETURN

IF DATEPART(HOUR,CURRENT_TIMESTAMP) >= 18
BEGIN
	EXEC sp_updatestats
END', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 2 hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160612, 
		@active_end_date=99991231, 
		@active_start_time=10100, 
		@active_end_time=235959, 
		@schedule_uid=N'1c1131cf-777e-4697-b9da-e8386b7d3d5f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_B4UM_Full_backup]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_B4UM_Full_backup', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DB Full Backup before UM]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DB Full Backup before UM', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare @Date nvarchar(50)  
Declare @Time nvarchar(50)  
Set @Date =
	CAST(DATEPART(year, CURRENT_TIMESTAMP) as nvarchar) +   
	CASE WHEN DATEPART(month, CURRENT_TIMESTAMP) < 10 THEN ''0'' + CAST(DATEPART(month, CURRENT_TIMESTAMP) as nvarchar) ELSE CAST(DATEPART(month, CURRENT_TIMESTAMP) as nvarchar) END +   
	CASE WHEN DATEPART(day, CURRENT_TIMESTAMP)   < 10 THEN ''0'' + CAST(DATEPART(day, CURRENT_TIMESTAMP) as nvarchar)   ELSE CAST(DATEPART(day, CURRENT_TIMESTAMP) as nvarchar) END  
Set @Time =
	CASE WHEN DATEPART(hour, CURRENT_TIMESTAMP)  < 10 THEN ''0'' + CAST(DATEPART(hour, CURRENT_TIMESTAMP) as nvarchar)  ELSE CAST(DATEPART(hour, CURRENT_TIMESTAMP) as nvarchar) END +  
	CASE WHEN DATEPART(minute,CURRENT_TIMESTAMP) < 10 THEN ''0'' + CAST(DATEPART(minute,CURRENT_TIMESTAMP) as nvarchar) ELSE CAST(DATEPART(minute,CURRENT_TIMESTAMP) as nvarchar) END  

Declare @Desc nvarchar(255) Set @Desc = ''Full Backup for '' + @Date  
Declare @Name nvarchar(128) Set @Name = @Date + '' '' + @Time + '' FULL_BK''

BACKUP DATABASE [bodb02] TO  DISK = N''G:\BACKUP_LOCAL\DB052.bodb02.bak''
WITH  DESCRIPTION = @Desc, COPY_ONLY,NOFORMAT, INIT,
NAME = @Name, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_Diff_Backup]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Diff_Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [backup databases]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'backup databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.DBA_Diff_Backup @BackupPath = ''G:\BACKUP''', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [delete old backup file - retention 8 days]    Script Date: 12/24/2021 6:26:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'delete old backup file - retention 8 days', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$Now = Get-Date
$Days = "8"
$SourceFolder = "G:\BACKUP\"
$Extension = "*.*"
$LastWrite = $Now.AddDays(-$Days)
$Files = Get-Childitem $SourceFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}
foreach ($File in $Files)
{
    if ($File -ne $NULL)
	{
        Remove-Item $File.FullName | out-null
	}
}', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Diff backup schedule', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=119, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170525, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'cded590d-e182-48b5-8beb-df5284ec761f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_Full_Backup]    Script Date: 12/24/2021 6:26:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Full_Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [backup databases]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'backup databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.DBA_Full_Backup @BackupPath = ''G:\BACKUP''', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Backup database', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170504, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'e28b29ec-518a-4f06-963a-95871ec9608c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_Getlockinfo 5 Secs]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Getlockinfo 5 Secs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [exec 5 secs a time]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'exec 5 secs a time', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WHILE 1=1
BEGIN
    EXEC dbo.DBA_Mon_Getlock_info; 
    WAITFOR DELAY ''00:00:05.000'';
END', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5 Second a time', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190520, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'7eb29bfc-2483-4b7b-99a2-5cc6cd6f1ad8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_Getwaitinfo 5 Secs]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Getwaitinfo 5 Secs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exec 5 Secs a time]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exec 5 Secs a time', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WHILE 1=1
BEGIN
    EXEC DBA_Mon_Get_Wait_Info; 
    WAITFOR DELAY ''00:00:05.000'';
END', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'exec 5 sec a time', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190520, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'4df2010a-8265-40e7-8dbf-277a43b628a1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_MonDB_Reorg]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_MonDB_Reorg', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA_ReIndex]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA_ReIndex', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC DBA_ReIndex', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'2:00am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111015, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'221a146c-22de-4b2e-8abb-da636e67428f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_Reorg_Index]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Reorg_Index', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBAAdmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Turn off auto update statistics]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Turn off auto update statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE bodb02 SET AUTO_UPDATE_STATISTICS OFF', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA_ReIndex]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA_ReIndex', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--==for re-index check
IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
BEGIN
	WAITFOR DELAY ''00:10:00:000''
	IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
	BEGIN
		RAISERROR(''the update statistics job is still running. Please check!'',16,1)
		RETURN
	END
END

EXEC DBA_ReIndex', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Turn on auto update statistics]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Turn on auto update statistics', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE bodb02 SET AUTO_UPDATE_STATISTICS ON', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA_ReIndex_bodb_Licensee]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA_ReIndex_bodb_Licensee', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--==for re-index check
IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
BEGIN
	WAITFOR DELAY ''00:10:00:000''
	IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
	BEGIN
		RAISERROR(''the update statistics job is still running. Please check!'',16,1)
		RETURN
	END
END

EXEC DBA_ReIndex', 
		@database_name=N'bodb_Licensee', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA_ReIndex_bodb_LicenseeReport]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA_ReIndex_bodb_LicenseeReport', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--==for re-index check
IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
BEGIN
	WAITFOR DELAY ''00:10:00:000''
	IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
	BEGIN
		RAISERROR(''the update statistics job is still running. Please check!'',16,1)
		RETURN
	END
END

--EXEC DBA_ReIndex', 
		@database_name=N'bodb_LicenseeReport', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA_ReIndex_bodb_PlaytechCS]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA_ReIndex_bodb_PlaytechCS', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--==for re-index check
IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
BEGIN
	WAITFOR DELAY ''00:10:00:000''
	IF (SELECT bodb02.dbo.f_CheckJobRunning(''DBA: update stats'')) = 1
	BEGIN
		RAISERROR(''the update statistics job is still running. Please check!'',16,1)
		RETURN
	END
END

EXEC dbo.DBA_ReIndex', 
		@database_name=N'bodb_PlaytechCS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Re-Org for affiliates]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Re-Org for affiliates', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @CMDs TABLE (rn int PRIMARY KEY IDENTITY(1,1)
	, cmd nvarchar(1000))			



INSERT INTO @CMDs (cmd)

SELECT ''exec '' + name+''.dbo.DBA_reindex'' 
FROM sys.databases

WHERE name LIKE ''Affiliate_%''
	
	AND is_read_only = 0
	
	AND state_desc = ''ONLINE''
	
	AND name not in (''Affiliate_12bet_Archive'')



declare @rn int, 
	@cmd nvarchar(1000)

SET @rn = 1



WHILE EXISTS(SELECT 1 FROM @CMDs WHERE rn = @rn)

BEGIN
	
	SELECT @cmd = cmd 
	FROM @CMDs 
	WHERE rn = @rn
	

	SET @rn = @rn + 1

	
	
	EXEC sp_executesql @cmd

END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'01:30am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170605, 
		@active_end_date=99991231, 
		@active_start_time=13000, 
		@active_end_time=235959, 
		@schedule_uid=N'a1065f55-e054-4c03-8893-9b4a85c8d7ee'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_Script_Instance_Object]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Script_Instance_Object', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'1.Weely Export Alias Setting from Registry
   LoginIID (SQL Account)
   Agent Job
   Alias Registry
   Linked Server
2.Remote Pull by DBBackup Scheduler
3.CREATED by Leon.Hsu - 20180514
4.LAST UPDATED: 20180514', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S1.Create-Folder]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S1.Create-Folder', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# 2.Create Folder If Not Exist
New-Item -ItemType Directory -Force -Path G:\ConfigFile\LoginID
New-Item -ItemType Directory -Force -Path G:\ConfigFile\AgentJob
New-Item -ItemType Directory -Force -Path G:\ConfigFile\Alias
New-Item -ItemType Directory -Force -Path G:\ConfigFile\LinkedServer
New-Item -ItemType Directory -Force -Path G:\ConfigFile\Others
New-Item -ItemType Directory -Force -Path G:\ConfigFile\Replication
New-Item -ItemType Directory -Force -Path G:\ConfigFile\Backup
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S2.LoginID]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S2.LoginID', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC master..sp_help_revlogin', 
		@database_name=N'master', 
		@output_file_name=N'G:\ConfigFile\LoginID\Create-LoginID_$(ESCAPE_SQUOTE(DATE)).sql', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S3.AgentJob]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S3.AgentJob', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# 1.Declare Variable
  $logdate = (get-date).tostring(''yyyyMMdd'')
  #$DateLog = Get-Date -Format ''yyyyMMdd''
  $serverInstance = gc env:computername
  #$servername = hostname
[System.Reflection.Assembly]::LoadWithPartialName(''Microsoft.SqlServer.Smo'') | Out-Null

$server = New-Object (''Microsoft.SqlServer.Management.Smo.Server'') $serverInstance
 
$jobs = $server.JobServer.Jobs 
#$jobs = $server.JobServer.Jobs | where-object {$_.category -eq "[your category]"}

# 2.Loop Scripting Create Job Appending to Out-File 
if ($jobs -ne $null)
{
  $serverInstance = $serverInstance.Replace("\", "-")
  
ForEach ( $job in $jobs )
  {
   #$FileName = "G:\ConfigFile\AgentJob\" + $serverInstance + "_" + $job.name + ".sql"
   #$job.Script() | Out-File -FilePath $FileName
   
   $FileName = "G:\ConfigFile\AgentJob\" + $serverInstance + "_Create-AgentJob_" + $logdate + ".sql"
   $job.Script()+ "GO`n" | Out-File -Append $FileName
  }
}
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S4.Alias]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S4.Alias', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# 1.Declare Variable
$DateLog = Get-Date -Format ''yyyyMMdd''
$servername = hostname
#New-Item -ItemType Directory -Force -Path G:\ConfigFile\Alias_"$servername"

# 2.Check if registry file exist, then delete file.
if(test-path G:\ConfigFile\Alias\Alias64_"$servername"_"$DateLog".reg)            
  { remove-item G:\ConfigFile\Alias\Alias64_"$servername"_"$DateLog".reg }
if(test-path G:\ConfigFile\Alias\Alias32_"$servername"_"$DateLog".reg)            
  { remove-item G:\ConfigFile\Alias\Alias32_"$servername"_"$DateLog".reg }

# 3.Gen output file
cd G:\ConfigFile\Alias
reg export HKLM\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo Alias64_"$servername"_"$DateLog".reg
reg export HKLM\SOFTWARE\Wow6432Node\Microsoft\MSSQLServer\Client\ConnectTo Alias32_"$servername"_"$DateLog".reg
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S5.LinkedServer]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S5.LinkedServer', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# 1.Declare Variable
  $logdate = (get-date).tostring(''yyyyMMdd'')
  #$DateLog = Get-Date -Format ''yyyyMMdd''
  $serverInstance = gc env:computername
  #$servername = hostname
  $FileName = "G:\ConfigFile\LinkedServer\" + $serverInstance + "_Create-LinkedServer_" + $logdate + ".sql"

[System.Reflection.Assembly]::LoadWithPartialName(''Microsoft.SqlServer.Smo'') | Out-Null


# 2.Scripting Create Linked Server to Out-File 
$server = New-Object (''Microsoft.SqlServer.Management.Smo.Server'') $serverInstance
$server.LinkedServers | foreach {$_.Script()+ "GO`n"} | Out-File $FileName 
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S6.Others]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S6.Others', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# 1.Declare Variable
  $logdate = (get-date).tostring(''yyyyMMdd'')
  #$DateLog = Get-Date -Format ''yyyyMMdd''
  $serverInstance = gc env:computername
  #$servername = hostname
  $FileName = "G:\ConfigFile\Others\" + $serverInstance + ".Others_" + $logdate + ".sql"

[System.Reflection.Assembly]::LoadWithPartialName(''Microsoft.SqlServer.Smo'') | Out-Null
$server = New-Object (''Microsoft.SqlServer.Management.Smo.Server'') $serverInstance


# 2.Scripting Other Instance Properties to Out-File 

''-- 1.SQLAgent Property'' | Out-File -Append $FileName
$server.JobServer | foreach {$_.Script()+ "GO`n"} | Out-File -Append $FileName

''-- 2.Alert'' | Out-File -Append $FileName
$server.JobServer.Alerts | foreach {$_.Script()+ "GO`n"} | Out-File -Append $FileName

''-- 3.Operator'' | Out-File -Append $FileName
$server.JobServer.Operators | foreach {$_.Script()+ "GO`n"} | Out-File -Append $FileName

''-- 4.EndPoint'' | Out-File -Append $FileName
$server.EndPoints | foreach {if ($_.endpoint_id -ge 65536) {$_.Script()}} | Out-File -Append $FileName

''-- 5.ServerTrigger'' | Out-File -Append $FileName
$server.Triggers | foreach {$_.Script()+ "GO`n"} | Out-File -Append $FileName

''-- 6.BackupDevice'' | Out-File -Append $FileName
$server.BackupDevices | foreach {$_.Script()+ "GO`n"} | Out-File -Append $FileName

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S7.Replication]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S7.Replication', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'#Load command-line parameters - if they exist
param ([string]$sqlserver, [string]$filename)


#Reference RMO Assembly
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Replication") | out-null
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Rmo") | out-null

#Date
$DateLog = Get-Date -Format ''yyyyMMdd''

function errorhandler([string]$errormsg)
{
    writetofile ("-- Replication Script Generator run at: " + (date)) $filename 1
    writetofile ("-- [Replication Script ERROR] " + $errormsg) $filename 0
}

function writetofile([string]$text, [string]$myfilename, [int]$cr_prefix)
{
    if ($cr_prefix -eq 1) { "" >> $myfilename }
    $text >> $myfilename
}

function initializefile([string]$myfilename)
{
    "" > $myfilename
}

trap {errorhandler($_); Break}



#Deal with absent parameters 處理參數為空 
[string] $hostname = hostname
#if ($sqlserver -eq "") {$sqlserver = read-host -prompt "Please enter the server name or leave blank for Hostname"}
#if ($filename -eq "")  {$filename = read-host -prompt "Please enter the file name (eg ''c:\ReplicationBackupScript.sql'')..."}
$Computername = gc env:computername
if ($sqlserver -eq "")  {$sqlserver = $Computername}
if ($filename -eq "")   {$filename = "G:\ConfigFile\Replication\" + $Computername + ".Replication_" + $DateLog+".sql"}

# Clear file contents
if (Test-Path  ($filename)) {Clear-Content $filename}

$repsvr = New-Object "Microsoft.SqlServer.Replication.ReplicationServer" $sqlserver

initializefile $filename

# if we don''t have any replicated databases then there''s no point in carrying on
if ($repsvr.ReplicationDatabases.Count -eq 0)
{
    writetofile ("-- Replication Script Generator run at: " + (date)) $filename 0
    writetofile "-- ZERO replicated databases on $sqlserver!!!" $filename 1
    EXIT
}

# similarly, if we don''t have any publications then there''s no point in carrying on
[int] $Count_Tran_Pub = 0
[int] $Count_Merge_Pub = 0

foreach($replicateddatabase in $repsvr.ReplicationDatabases)
{
        $Count_Tran_Pub = $Count_Tran_Pub + $replicateddatabase.TransPublications.Count
        $Count_Merge_Pub = $Count_Merge_Pub + $replicateddatabase.MergePublications.Count
}

if (($Count_Tran_Pub + $Count_Merge_Pub) -eq 0)
{
    writetofile ("-- Replication Script Generator run at: " + (date)) $filename 0
    writetofile "-- ZERO Publications on $sqlserver!!!" $filename 1
    EXIT
}

# if we got this far we know that there are some publications so we''ll script them out
# the $scriptargs controls exactly what the script contains
# for a full list of the $scriptargs see the end of this script
$scriptargs = [Microsoft.SqlServer.Replication.scriptoptions]::Creation `
-bor  [Microsoft.SqlServer.Replication.scriptoptions]::IncludeArticles `
-bor  [Microsoft.SqlServer.Replication.scriptoptions]::IncludePublisherSideSubscriptions `
-bor  [Microsoft.SqlServer.Replication.scriptoptions]::IncludeSubscriberSideSubscriptions

writetofile ("-- Replication Script Generator run at: " + (date)) $filename 0
writetofile "-- PUBLICATIONS ON $sqlserver" $filename 1
writetofile "-- TRANSACTIONAL PUBLICATIONS ($Count_Tran_Pub)" $filename 1

writetofile "/****** Installing the server as a Distributor.******/" $filename 1
writetofile "use master"  $filename 0
writetofile "exec sp_adddistributor @distributor = N''Enter Distributor name ex:DBDIST'', @password = N''Distributor Password''"  $filename 0
writetofile "GO"  $filename 0
writetofile "/****** End: Script to be run at Publisher ******/"  $filename 0

writetofile "-- Enabling the replication database" $filename 1
writetofile "use master" $filename 0
writetofile "exec sp_replicationdboption @dbname = N''Enter publish DBName ex:bodb02'', @optname = N''publish'', @value = N''true''" $filename 0
writetofile "GO" $filename 0


foreach($replicateddatabase in $repsvr.ReplicationDatabases)
{
    if ($replicateddatabase.TransPublications.Count -gt 0)
    {
        foreach($tranpub in $replicateddatabase.TransPublications)
        {
            writetofile "/********************************************************************************" $filename 0
            writetofile ("***** Writing to file script for publication: " + $tranpub.Name) $filename 0
            writetofile "********************************************************************************/" $filename 0
			[string] $myscript=$tranpub.script($scriptargs) 
            writetofile $myscript $filename 0
        }
    }
}

writetofile "-- MERGE PUBLICATIONS ($Count_Merge_Pub)" $filename 1

foreach($replicateddatabase in $repsvr.ReplicationDatabases)
{
    if ($replicateddatabase.MergePublications.Count -gt 0)
    {
        foreach($mergepub in $replicateddatabase.MergePublications)
        {
            writetofile "/********************************************************************************" $filename 0
            writetofile ("***** Writing to file script for publication: " + $mergepub.Name) $filename 0
            writetofile "********************************************************************************/" $filename 0
            [string] $myscript=$mergepub.script($scriptargs) 
            writetofile $myscript $filename 0
        }
    }
}



#-----------------Delete file befor 180 day-----------------

$Now = Get-Date

$Days = "180"

$TargetFolder = "G:\ConfigFile\Replication"

$Extension = "*.sql"

$LastWrite = $Now.AddDays(-$Days)
 

$Files = Get-Childitem $TargetFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}
 
foreach ($File in $Files)
{
    if ($File -ne $NULL)
    	{
        Remove-Item $File.FullName | out-null
    	}
}



(Get-Content $filename) | 
Foreach-Object {$_ -replace "@subscriber_login = N''sa'', @subscriber_password = null", "@subscriber_login = N''sa'', @subscriber_password = ''Change_to_sa_plus_1_Password''"} | 
Foreach-Object {$_ -replace "@publisher_login = N''sa'', @publisher_password = N''''", "@publisher_login = N''sa'', @publisher_password = N''Change_to_sa_plus_1_Password''"} | 
Foreach-Object {$_ -replace "@sync_type = N''automatic''", "@sync_type = N''replication support only''"} |  
Set-Content $filename
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S8.Delete_Hist_File]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S8.Delete_Hist_File', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$limit = (Get-Date).AddDays(-31)
$path = "G:\ConfigFile\"

# 1.Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Remove-Item -Force

# 2.Delete any empty directories left behind after deleting the old files.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [S9.Get-ServerInfo]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'S9.Get-ServerInfo', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# 1.ComputerName
$ComputerName = gc env:computername

# 2.H/W MODEL
$SYSTEM = Get-WmiObject Win32_Computersystem
$HWModel = $SYSTEM.MODEL

# 3.CPU MODEL
$CPUTmp = Get-WmiObject Win32_Processor | Select-Object -Property ''name'' -First 1
$CPUModel=$CPUTmp.name

# 4.Physical Memory Size (GB)
$PhyRAM = Get-WMIObject -class win32_physicalmemory | 
Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),0)}

# 5.Sockets
$CPUCount = Get-WmiObject Win32_Processor | Measure-Object -Property ''NumberOfCores'' -Sum -Average
$Socket = $CPUCount.Count

# 6.PhyCorePerSockets
$CorePerSocket = $CPUCount.Average

# 7.Physical Cores
$PhyCore= $CPUCount.Sum

# 8.Logical Cores
$CPUCount = Get-WmiObject Win32_Processor | Measure-Object -Property ''NumberOfLogicalProcessors'' -Sum
$LogCore= $CPUCount.Sum

# 9.OS Version
$OSVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption

# 10.OS Service Pack
$OSSP = (Get-WmiObject -class Win32_OperatingSystem).servicepackmajorversion

# 11.SQL Version
$SQLVersion = Invoke-Sqlcmd -Query "SELECT @@VERSION"
$SQLEdition = $SQLVersion.Column1

# 12.Domain Group
$DomainGroup = $SYSTEM.Domain

# 13.IP Info
$IP = ipconfig | Select-String "IPv4"
$IP = $IP -replace ''(^\s+|\s+$)'','''' -replace ''\s+'','' ''

# 14.Insert Table
Invoke-Sqlcmd -Query "Insert into Mondb.dbo.Mon_Server_DBInfo(HostName,HWModel,CPUModel,PhyRamGB,Socket,CorePerSocket,PhyCore, `
LogCore,OSVersion,OSServicePack,SQLEdition,DomainGroup,IP) values (''$ComputerName'',''$HWModel'',''$CPUModel'',''$PhyRAM'',''$Socket'', `
''$CorePerSocket'',''$PhyCore'',''$LogCore'',''$OSVersion'',''$OSSP'',''$SQLEdition'',''$DomainGroup'',''$IP'')" 

# 15.Update IP Info
Invoke-Sqlcmd -Query "UPDATE [MonDB].[dbo].[Mon_Server_DBInfo] SET IP = LTRIM(REPLACE (IP,'' Address. . . . . . . . . . . '',''''))" 

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sch1', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=36, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180514, 
		@active_end_date=99991231, 
		@active_start_time=211000, 
		@active_end_time=235959, 
		@schedule_uid=N'32c9e4e2-3e2d-4c8c-9512-8fc589bb9b35'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_Txn_Backup]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Txn_Backup', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step1_Txn_Log_Backup]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step1_Txn_Log_Backup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBA_Txn_Backup', 
		@database_name=N'MONDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step2_Del Hist File]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step2_Del Hist File', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$Now = Get-Date
$Days = "2"
$TargetFolder = "G:\Backup_Local\"
$Extension = "*.trn"
$LastWrite = $Now.AddDays(-$Days)
$Files = Get-Childitem $TargetFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}
foreach ($File in $Files)
{
    if ($File -ne $NULL)
    	{
        Remove-Item $File.FullName | out-null
    	}
}
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sch1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=6, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150910, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'56f056e0-0e13-4d50-89f0-abf3d89ef579'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_UM_Diff_backup]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_UM_Diff_backup', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DB Diff Backup in UM]    Script Date: 12/24/2021 6:26:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DB Diff Backup in UM', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare @Date nvarchar(50)  
Declare @Time nvarchar(50)  
Set @Date =
	CAST(DATEPART(year, CURRENT_TIMESTAMP) as nvarchar) +   
	CASE WHEN DATEPART(month, CURRENT_TIMESTAMP) < 10 THEN ''0'' + CAST(DATEPART(month, CURRENT_TIMESTAMP) as nvarchar) ELSE CAST(DATEPART(month, CURRENT_TIMESTAMP) as nvarchar) END +   
	CASE WHEN DATEPART(day, CURRENT_TIMESTAMP)   < 10 THEN ''0'' + CAST(DATEPART(day, CURRENT_TIMESTAMP) as nvarchar)   ELSE CAST(DATEPART(day, CURRENT_TIMESTAMP) as nvarchar) END  
Set @Time =
	CASE WHEN DATEPART(hour, CURRENT_TIMESTAMP)  < 10 THEN ''0'' + CAST(DATEPART(hour, CURRENT_TIMESTAMP) as nvarchar)  ELSE CAST(DATEPART(hour, CURRENT_TIMESTAMP) as nvarchar) END +  
	CASE WHEN DATEPART(minute,CURRENT_TIMESTAMP) < 10 THEN ''0'' + CAST(DATEPART(minute,CURRENT_TIMESTAMP) as nvarchar) ELSE CAST(DATEPART(minute,CURRENT_TIMESTAMP) as nvarchar) END  

Declare @Desc nvarchar(255) Set @Desc = ''Full Backup for '' + @Date  
Declare @Name nvarchar(128) Set @Name = @Date + '' '' + @Time + '' FULL_BK''

BACKUP DATABASE [bodb02] TO  DISK = N''G:\BACKUP_LOCAL\UM_Diff\DB052.bodb02.diff.bak''
WITH  DIFFERENTIAL ,DESCRIPTION = @Desc, NOFORMAT, INIT,  
NAME = @Name, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [FS-ArchiveCleanUpData]    Script Date: 12/24/2021 6:26:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [FraudSensor]    Script Date: 12/24/2021 6:26:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'FraudSensor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'FraudSensor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FS-ArchiveCleanUpData', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Archive CleanUp Data', 
		@category_name=N'FraudSensor', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [01.Remove tickets before BalanceUp]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'01.Remove tickets before BalanceUp', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE FS_Task_TicketsRemoveBeforeBalanceUp', 
		@database_name=N'bodb_FraudSensor', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [02.Remove UserLogs within 7 latest days]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'02.Remove UserLogs within 7 latest days', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE FS_Task_UserLogsRemove;', 
		@database_name=N'bodb_FraudSensor', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [03.ArchiveData_Arbitrage]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'03.ArchiveData_Arbitrage', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE FS_Task_ArchiveData_Arbitrage;', 
		@database_name=N'bodb_FraudSensor', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'FS - After BU', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=32, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190501, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'b11b4353-ce5e-41c2-9f37-dda0be26c649'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [FS-CustomerTicketCountDaily]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [FraudSensor]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'FraudSensor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'FraudSensor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FS-CustomerTicketCountDaily', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Daily sum total tickets for each match by customer', 
		@category_name=N'FraudSensor', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [01.CustomerTicketCountDaily]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'01.CustomerTicketCountDaily', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE FS_Task_CustomerTicketCountDaily;', 
		@database_name=N'bodb_FraudSensor', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180607, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'9d882ef2-ee4c-4620-a32a-1c9d1e4b127f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [FS-Daily Data Capturing]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [FraudSensor]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'FraudSensor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'FraudSensor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FS-Daily Data Capturing', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Daily sum data for each match from bodb02.bettrans

Created: 20180716@Long
System: NAP - Fraud Sensor', 
		@category_name=N'FraudSensor', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [01.Capture Data]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'01.Capture Data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec FS_Task_MatchDailyDataCapture', 
		@database_name=N'bodb_FraudSensor', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'FS-Daily Data Capturing-Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180607, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'48e3b24d-36d9-4c3e-90db-41d6d1bb64d9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [FS-Get Tickets By IP]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [FraudSensor]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'FraudSensor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'FraudSensor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FS-Get Tickets By IP', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Get all latest Tickets By IP from bodb02.bettrans', 
		@category_name=N'FraudSensor', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'StarixDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [01.Get tickets by IP]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'01.Get tickets by IP', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.FS_Task_TicketsGetByIP', 
		@database_name=N'bodb_FraudSensor', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'FS_Get Tickets By IP-Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=60, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180505, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'ad6ba45c-2972-4c4c-bc8a-eac0e6a2cd6b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [TEST_BENJAMIN]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'TEST_BENJAMIN', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [STP1]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'STP1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET ARITHABORT ON;


select getdate()', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'TEST', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210120, 
		@active_end_date=99991231, 
		@active_start_time=225158, 
		@active_end_time=235959, 
		@schedule_uid=N'68cfd76c-dd66-4f7f-81da-768f77e203d2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [viet: perf report]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'viet: perf report', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'Viet', 
		@notify_email_operator_name=N'Viet', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run script]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run script', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON;
DECLARE @wldate smalldatetime 
DECLARE @msg nvarchar(max) = ''''
DECLARE @x tinyint
SET @x = CASE WHEN DATEPART (hour, CURRENT_TIMESTAMP) > 17 THEN 0 ELSE 1 END

-- for testing
--set @x = 1
--/for testing

SET @wldate = DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), -@x)

if @x = 0 -- today''s so far
BEGIN		
	SET @msg += ''```<br>['' + LEFT(convert(varchar, CURRENT_TIMESTAMP, 20), 16) + '']<br>------------------[g]<br>''
	;WITH _s AS (
		SELECT p_amt = parsename(CONVERT(VARCHAR, convert(MONEY, -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)), 1), 2)
			,p_tc = parsename(CONVERT(VARCHAR, convert(MONEY, count(transid)), 1), 2)
		FROM dbo.bettrans b WITH(NOLOCK)
			INNER JOIN (SELECT ProductID, Bettype, SubProduct FROM dbo.f_SportBettypeMatrix_Sel (0, 0, 0, 2, '''', '''', 0)) s ON s.BetType = b.bettype
		WHERE winlostdate = @wldate
			AND b.matchid > 0
			AND b.statusid IN (111,112,113)
			AND b.currency <> 20
			AND b.bettype < 19999
			AND b.bettype NOT IN (2198, 2398, 2998, 2199, 2399, 2999) --jackpot	
	)	
	SELECT @msg += left(''WINLOSS'' + space(9), 9) + RIGHT(space(12) + p_amt, 12) + ''<br>''
						+ left(''TicketCNT'' + space(9), 9) + RIGHT(space(12) + p_tc, 12) + ''<br>''
	FROM _s
		
	-- highlight games
	SET @msg += ''<br>[Highlight Events]<br>---------------------''
	declare @tempTable as TABLE(hometeam varchar(100), awayteam varchar(100), finalhomescore int, finalawayscore int, xWL varchar(20), xTC varchar(20), sumWL money)
	;WITH _s AS (
		SELECT hometeam = h.teamname
			,finalhomescore = finalhomescore
			,awayteam = a.teamname
			,finalawayscore = finalawayscore			
			,sumWL = -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)
			,p_sumWL = parsename(CONVERT(VARCHAR, convert(MONEY, -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)), 1), 2)			
			,sumTC = count(transid)
			,p_sumTC = parsename(CONVERT(VARCHAR, convert(MONEY, count(transid)), 1), 2)
		FROM bettrans b WITH(NOLOCK)
			INNER JOIN match m WITH(NOLOCK) ON b.matchid = m.matchid
			INNER JOIN dbo.team h with(nolock) on m.homeid = h.teamid
			INNER JOIN dbo.team a with(nolock) on m.awayid = a.teamid
		WHERE eventdate = @wldate
			AND m.sporttype = 1
			AND m.eventstatus = ''completed''
			AND b.statusid IN (111,112,113)
			AND b.currency <> 20
			AND b.bettype < 19999
			AND b.bettype NOT IN (2198, 2398, 2998, 2199, 2399, 2999) --jackpot
		GROUP BY h.teamname
			,a.teamname
			,finalhomescore
			,finalawayscore
		HAVING ABS(-ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)) > 10000
	)	
	,_s1 as (
		SELECT hometeam
			,awayteam
			,finalhomescore
			,finalawayscore
			,xWL = CASE
					WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''b''
					WHEN sumWL >= 100000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
					WHEN sumWL >= 10000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
					WHEN sumWL >= 1000000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''m''
					WHEN sumWL >= 100000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''k''
					WHEN sumWL >= 10000 THEN REPLACE(LEFT(p_sumWL,2), '','', ''.'') + ''k''
					WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''						
					WHEN sumWL <= -10000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
					WHEN sumWL <= -1000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
					WHEN sumWL <= -100000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''
					WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''
					WHEN sumWL <= -1000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''					
					ELSE p_sumWL
				END
			,xTC = CASE
					WHEN sumTC >= 1000000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''b''
					WHEN sumTC >= 100000000 THEN REPLACE(LEFT(p_sumTC,5), '','', ''.'') + ''m''
					WHEN sumTC >= 10000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''m''
					WHEN sumTC >= 1000000 THEN REPLACE(LEFT(p_sumTC,3), '','', ''.'') + ''m''
					WHEN sumTC >= 100000 THEN REPLACE(LEFT(p_sumTC,3), '','', ''.'') + ''k''
					WHEN sumTC >= 10000 THEN REPLACE(LEFT(p_sumTC,2), '','', ''.'') + ''k''
					WHEN sumTC >= 1000 THEN REPLACE(REPLACE(LEFT(p_sumTC,3), '','', ''.''), ''.0'','''') + ''k''						
					WHEN sumTC <= -10000000 THEN REPLACE(LEFT(p_sumTC,5), '','', ''.'') + ''m''
					WHEN sumTC <= -1000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''m''
					WHEN sumTC <= -100000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''k''
					WHEN sumTC <= -10000 THEN REPLACE(REPLACE(LEFT(p_sumTC,3), '','', ''.''), ''.0'','''') + ''k''
					WHEN sumTC <= -1000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''k''					
					ELSE p_sumTC
				END
			,sumWL
		FROM _s
	)
	INSERT INTO @tempTable (hometeam, awayteam, finalhomescore, finalawayscore, xWL, xTC, sumWL)
	SELECT TOP (20) hometeam, awayteam, finalhomescore, finalawayscore, xWL, xTC, sumWL
	FROM _s1 order by abs(sumWL) desc

	SELECT @msg += ''<br>'' + LEFT(hometeam + replicate('' '',12),12) 
				+ RIGHT(space(2) + convert(varchar(5), isnull(finalhomescore, '''')), 2) 
				+ RIGHT(space(7) + xWL, 7) 
				+ ''<br>'' + LEFT(awayteam + replicate('' '',12),12) + RIGHT(space(2) + convert(varchar(5), isnull(finalawayscore, '''')), 2) 
				+ RIGHT(space(7) + xTC, 7) + ''<br>''
	FROM @tempTable
	ORDER BY sumWL ASC

	IF @@ROWCOUNT = 0 SET @msg += ''<br>No Data<br>''
END


if @x = 1
BEGIN	
	SET @msg += ''```<br>['' + convert(varchar(10), @wldate, 120) + '']<br>''	
	SET @msg += ''<br>'' + left(''[PROD]'' + replicate('' '',7),7) + RIGHT(space(7) + ''[WL]'', 7) + RIGHT(space(7) + ''[TC]'', 7) + ''<br>''

	-- reset winning codes
	SELECT distinct l.Custid
		,product = CASE custid WHEN 37639217 THEN ''CN88'' ELSE product END
		,seq = CASE custid WHEN 37639217 THEN 101 ELSE seq END
	INTO #Test1
	FROM DBACC.bodb_ACC.dbo.Acc_DWLList l WITH (NOLOCK)
	WHERE IsDeleted = 0
		AND custid > 0	

	INSERT INTO #test1 (custid, product, seq)
	SELECT custid, product = ''extraPT'', 0
	FROM DBACC.bodb_ACC.dbo.Acc_DWLList_ExtraPT WITH(NOLOCK)

	-- get reset winning info from ticket
	;WITH _s AS (
		SELECT  b.winlostdate
				,b.srecommend		
				,CASE WHEN ISNULL(m.Sporttype, 0) <> 0 THEN m.Sporttype ELSE 0 END AS Sporttype
				,s.ProductId
				,CASE WHEN s.SubProduct = ''MG-SuperLive'' THEN ''Metric Gaming - Super Live''
					WHEN s.SubProduct IN (''BT-Sold'',''BT-Bought'',''BT-Comm'',''BT-Winloss'') THEN ''Bettrade''
					WHEN s.SubProduct = ''Bet Builder'' THEN ''Bet Builder''
					WHEN ISNULL(m.Sporttype, 0) = 44 THEN ''Muay Thai''
					WHEN b.bettype = 10 THEN ''Outright''
					WHEN b.bettype IN (9,29) THEN''Parlay'' 
					WHEN b.liveindicator = 1 AND s.ProductID = 1 THEN ''SPL'' 
					WHEN b.liveindicator = 0 AND s.ProductID = 1 THEN ''SPNL''  	
					ELSE ''''
					END	AS ProductName
				,CASE WHEN s.SubProduct IN (''MG-SuperLive'', ''BT-Sold'',''BT-Bought'',''BT-Comm'',''BT-Winloss'',''Bet Builder'') THEN s.SubProduct ELSE '''' END AS SubProduct
				,SUM(
						CASE WHEN b.bettype IN (2199, 2399, 2999) THEN 0
							ELSE
								(ISNULL(winlost,0)-ISNULL(actual_stake,0)+ISNULL(awinlost,0)+ISNULL(mwinlost,0)+ISNULL(swinlost,0)+ISNULL(scomm,0)
									+ CASE
										-- Jackpot
										WHEN b.bettype IN (2198, 2398, 2998) THEN ISNULL(b.betid/CONVERT(DECIMAL(19,8), 100000000),0)
										ELSE 0 END
								) * actualrate  
							END
					) AS winlost
				,SUM(
						(	
							CASE
								-- Jackpot
								WHEN b.bettype IN (2198, 2398, 2998) THEN -ISNULL(b.betid/CONVERT(DECIMAL(19,8), 100000000), 0)
								WHEN b.bettype IN (2199, 2399, 2999) THEN ISNULL(b.Winlost, 0) - ISNULL(b.actual_stake, 0)
							ELSE 0 
							END
						) * b.actualrate
					) AS WinlostDueTo
				,0 AS CommForExtraPT
				,SUM(
						(	
							CASE
							-- Jackpot
							WHEN b.bettype IN (2198, 2398, 2998) THEN
								CASE WHEN b.tpositiontaking = 1 THEN 0 ELSE ISNULL(b.betid/CONVERT(DECIMAL(19,8), 100000000), 0) END
							WHEN b.bettype IN (2199, 2399, 2999) THEN 0
							ELSE
								CASE WHEN b.tpositiontaking = 1 THEN 0 ELSE b.winlost - b.actual_stake + b.scomm / (1 - b.tpositiontaking) END
							END
						)* b.actualrate
					) AS WinlostForExtraPT
				,COUNT(b.transid) as TicketCount
		FROM dbo.bettrans b WITH (NOLOCK)			
		INNER JOIN (SELECT ProductID, Bettype, SubProduct FROM dbo.f_SportBettypeMatrix_Sel (0, 0, 0, 2, '''', '''', 0)) s ON s.BetType = b.bettype
		LEFT JOIN dbo.Match m WITH (NOLOCK) ON m.MatchId = b.MatchId AND m.Sporttype = 44		
		WHERE   b.Winlostdate = @wldate
			AND b.ruben = 1
			AND b.statusid NOT IN (101, 102, 103, 121)		
			AND b.Currency <> 20 
			AND b.bettype < 19001
		GROUP BY b.Winlostdate			
				,b.srecommend
				,CASE WHEN ISNULL(m.Sporttype, 0) <> 0 THEN m.Sporttype ELSE 0 END
				,s.ProductId
				,CASE WHEN s.SubProduct = ''MG-SuperLive'' THEN ''Metric Gaming - Super Live''
					WHEN s.SubProduct IN (''BT-Sold'',''BT-Bought'',''BT-Comm'',''BT-Winloss'') THEN ''Bettrade''
					WHEN s.SubProduct = ''Bet Builder'' THEN ''Bet Builder''
					WHEN ISNULL(m.Sporttype, 0) = 44 THEN ''Muay Thai''
					WHEN b.bettype = 10 THEN ''Outright''
					WHEN b.bettype IN (9,29) THEN''Parlay'' 
					WHEN b.liveindicator = 1 AND s.ProductID = 1 THEN ''SPL'' 
					WHEN b.liveindicator = 0 AND s.ProductID = 1 THEN ''SPNL''  	
					ELSE ''''
					END
				,CASE WHEN s.SubProduct IN (''MG-SuperLive'', ''BT-Sold'',''BT-Bought'',''BT-Comm'',''BT-Winloss'',''Bet Builder'') THEN s.SubProduct ELSE '''' END
	)
	SELECT  productName = CASE WHEN w.ProductId = 6 THEN ''Casino'' 
								WHEN w.ProductID <> 1 THEN p.ProductName 
								ELSE w.ProductName 
							END
			,isC8 = CASE WHEN ISNULL(cs.CustID, '''') <> '''' THEN 1 ELSE 0 END
			,WL = -SUM(ISNULL(w.Winlost,0)-ISNULL(w.WinlostForExtraPT,0)*ISNULL(s.ExtraPT,0))
			,TC = SUM(TicketCount)
	INTO #TODAY_ResetWinning
	FROM	_s w
		INNER JOIN dbo.Products p WITH (NOLOCK) ON w.ProductId = p.ProductID
		LEFT JOIN CS_CustSuper cs WITH (NOLOCK) ON cs.CustId = w.srecommend
		LEFT JOIN dbo.Acc_GroupExtraPTSetting s WITH(NOLOCK) ON w.srecommend = s.SuperId
					AND w.ProductId = s.ProductId
					AND w.SubProduct = s.SubProduct
					AND w.Sporttype = s.Sporttype 
					AND w.Winlostdate BETWEEN s.FromDate AND s.ToDate		
	GROUP BY CASE WHEN w.ProductId = 6 THEN ''Casino'' 
								WHEN w.ProductID <> 1 THEN p.ProductName 
								ELSE w.ProductName 
							END
			,CASE WHEN ISNULL(cs.CustID, '''') <> '''' THEN 1 ELSE 0 END	

	-- 1. Total
	SET @msg += ''------------------[n]<br>''
	;WITH _s as (
		SELECT ''TOTAL'' as product
			,sumWL = SUM(WL)
			,p_sumWL = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)			
			,sumTC = SUM(TC)
			,p_sumTC = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(TC)), 1), 2)
		FROM #TODAY_ResetWinning
	)
	,_s1 as (
		SELECT xproduct = product
			,xWL = CASE
					WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''b''
					WHEN sumWL >= 100000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
					WHEN sumWL >= 10000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
					WHEN sumWL >= 1000000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''m''
					WHEN sumWL >= 100000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''k''
					WHEN sumWL >= 10000 THEN REPLACE(LEFT(p_sumWL,2), '','', ''.'') + ''k''
					WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''						
					WHEN sumWL <= -10000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
					WHEN sumWL <= -1000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
					WHEN sumWL <= -100000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''
					WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''
					WHEN sumWL <= -1000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''					
					ELSE p_sumWL
				END
			,xTC = CASE
					WHEN sumTC >= 1000000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''b''
					WHEN sumTC >= 100000000 THEN REPLACE(LEFT(p_sumTC,5), '','', ''.'') + ''m''
					WHEN sumTC >= 10000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''m''
					WHEN sumTC >= 1000000 THEN REPLACE(LEFT(p_sumTC,3), '','', ''.'') + ''m''
					WHEN sumTC >= 100000 THEN REPLACE(LEFT(p_sumTC,3), '','', ''.'') + ''k''
					WHEN sumTC >= 10000 THEN REPLACE(LEFT(p_sumTC,2), '','', ''.'') + ''k''
					WHEN sumTC >= 1000 THEN REPLACE(REPLACE(LEFT(p_sumTC,3), '','', ''.''), ''.0'','''') + ''k''						
					WHEN sumTC <= -10000000 THEN REPLACE(LEFT(p_sumTC,5), '','', ''.'') + ''m''
					WHEN sumTC <= -1000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''m''
					WHEN sumTC <= -100000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''k''
					WHEN sumTC <= -10000 THEN REPLACE(REPLACE(LEFT(p_sumTC,3), '','', ''.''), ''.0'','''') + ''k''
					WHEN sumTC <= -1000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''k''					
					ELSE p_sumTC
				END
		FROM _s
	)
	SELECT @msg += left(xproduct + replicate('' '',8),8) + RIGHT(space(67) + [xWL], 6) + RIGHT(space(7) + [xTC], 7) + ''<br>''
	FROM _s1
	
	-- 2. by product
	SET @msg += ''------------------[n]<br>''
	;WITH _s as (		
		SELECT prod = CASE d.productName WHEN ''Casino (Amount due to Jackpot Pool)'' THEN ''Casino ->JP.P'' 
								WHEN ''Virtual Sports'' THEN ''VS''
								WHEN ''Virtual Sports 2'' THEN ''VS2''
								WHEN ''Metric Gaming - Super Live'' THEN ''MG-SuperLive''
							ELSE d.productName END	
			,sumWL = SUM(WL)
			,p_sumWL = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)			
			,sumTC = SUM(TC)
			,p_sumTC = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(TC)), 1), 2)
			,s.seq
		FROM #TODAY_ResetWinning d
			LEFT JOIN #Test1 s ON d.productName = s.product		
		GROUP BY CASE d.productName WHEN ''Casino (Amount due to Jackpot Pool)'' THEN ''Casino ->JP.P'' 
								WHEN ''Virtual Sports'' THEN ''VS''
								WHEN ''Virtual Sports 2'' THEN ''VS2''
								WHEN ''Metric Gaming - Super Live'' THEN ''MG-SuperLive''
							ELSE d.productName END	
				, s.seq
		HAVING SUM(TC) > 10
	)
	,_s1 as (
		SELECT xproduct = prod
			,xWL = CASE
					WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''b''
					WHEN sumWL >= 100000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
					WHEN sumWL >= 10000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
					WHEN sumWL >= 1000000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''m''
					WHEN sumWL >= 100000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''k''
					WHEN sumWL >= 10000 THEN REPLACE(LEFT(p_sumWL,2), '','', ''.'') + ''k''
					WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''						
					WHEN sumWL <= -10000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
					WHEN sumWL <= -1000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
					WHEN sumWL <= -100000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''
					WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''
					WHEN sumWL <= -1000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''					
					ELSE p_sumWL
				END
			,xTC = CASE
					WHEN sumTC >= 1000000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''b''
					WHEN sumTC >= 100000000 THEN REPLACE(LEFT(p_sumTC,5), '','', ''.'') + ''m''
					WHEN sumTC >= 10000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''m''
					WHEN sumTC >= 1000000 THEN REPLACE(LEFT(p_sumTC,3), '','', ''.'') + ''m''
					WHEN sumTC >= 100000 THEN REPLACE(LEFT(p_sumTC,3), '','', ''.'') + ''k''
					WHEN sumTC >= 10000 THEN REPLACE(LEFT(p_sumTC,2), '','', ''.'') + ''k''
					WHEN sumTC >= 1000 THEN REPLACE(REPLACE(LEFT(p_sumTC,3), '','', ''.''), ''.0'','''') + ''k''						
					WHEN sumTC <= -10000000 THEN REPLACE(LEFT(p_sumTC,5), '','', ''.'') + ''m''
					WHEN sumTC <= -1000000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''m''
					WHEN sumTC <= -100000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''k''
					WHEN sumTC <= -10000 THEN REPLACE(REPLACE(LEFT(p_sumTC,3), '','', ''.''), ''.0'','''') + ''k''
					WHEN sumTC <= -1000 THEN REPLACE(LEFT(p_sumTC,4), '','', ''.'') + ''k''					
					ELSE p_sumTC
				END
			,p_sumWL
		FROM _s
	)
	SELECT @msg += left(xproduct + replicate('' '',7),7) + RIGHT(space(7) + [xWL], 7) + RIGHT(space(7) + [xTC], 7) + ''<br>''
	FROM _s1
	ORDER BY p_sumWL DESC

	-- data for by sports--	
	;WITH _sportsbettype AS (
		SELECT distinct
			Product = CASE WHEN ma.ProductID = 1 AND ma.bettype = 10 THEN ''Outright''
							WHEN ma.ProductID = 1 AND ma.bettype IN (9,29) THEN''Parlay'' 
							WHEN ma.SubProduct LIKE (''BT-%'') THEN ''Bettrade''
							WHEN ma.SubProduct LIKE (''CO-%'') THEN ''Cashout''
							ELSE COALESCE(NULLIF(ma.SubProduct, ''''), p.ProductPrefix)
						END
			,Bettype = ma.BetType					
		FROM dbo.SportBettypeMatrix ma WITH (NOLOCK)
			INNER JOIN dbo.Products p WITH (NOLOCK) ON p.ProductID = ma.ProductID
		WHERE ma.IsTest = 0
	)
	SELECT Product = CASE WHEN Product = ''SB'' THEN CASE WHEN b.liveindicator = 1 THEN ''SPL'' ELSE ''SPNL'' END ELSE Product END
		,Amt = -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)
		,ticketCNT = count(transid)
	INTO #perf
	FROM dbo.bettrans b WITH(NOLOCK)
		INNER JOIN _sportsbettype s ON b.bettype = s.bettype
	WHERE winlostdate = @wldate
		AND b.matchid > 0
		AND b.statusid IN (111,112,113)
		AND b.currency <> 20
		AND b.bettype < 19999
		AND b.bettype NOT IN (2198, 2398, 2998, 2199, 2399, 2999) --jackpot
	GROUP BY Product, liveindicator

	SELECT matchid		
		,WL = -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)
		,TicketCNT = count(transid)
	INTO #perf2	
	FROM bettrans b WITH(NOLOCK)
	WHERE winlostdate = @wldate
		AND b.matchid > 0
		AND b.statusid IN (111,112,113)
		AND b.currency <> 20
		AND b.bettype < 19999
		AND b.bettype NOT IN (2198, 2398, 2998, 2199, 2399, 2999) --jackpot
	GROUP BY matchid

	-- 3. by sport
	SET @msg += ''------------------[g]<br>''
	;WITH _s2 AS (
		SELECT sportname = LEFT(REPLACE(CASE 
									WHEN b.matchid = 29 THEN ''Parlay'' 
									WHEN b.matchid = 2799 THEN ''Virtual Sports Parlay''
									WHEN b.matchid BETWEEN 21301 AND 21831 THEN ''NG2''
									WHEN b.matchid < 20000 THEN s1.SportName
								ELSE COALESCE(s.SportName,''-'') END,'' '',''''), 7)
				,WL = CASE 
							WHEN sum(WL) >= 10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.'') + ''m''
							WHEN sum(WL) >= 1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.'') + ''m''
							WHEN sum(WL) >= 100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.'') + ''k''
							WHEN sum(WL) >= 10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),2), '','', ''.'') + ''k''
							WHEN sum(WL) >= 1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.''), ''.0'','''') + ''k''	
							--WHEN sum(WL) >= 100 THEN ''0.''+ REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),1), '','', ''.'') + ''k''
							WHEN sum(WL) <= -10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),5), '','', ''.'') + ''m''
							WHEN sum(WL) <= -1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.'') + ''m''
							WHEN sum(WL) <= -100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.'') + ''k''
							WHEN sum(WL) <= -10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.'') + ''k''
							WHEN sum(WL) <= -1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.''), ''.0'','''') + ''k''
							--WHEN sum(WL) <= -100 THEN ''-0.''+ REPLACE(LEFT(-sum(WL),1), '','', ''.'') + ''k''
							ELSE parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)
						END	
				,TC = CASE 
							WHEN SUM(ticketCNT) >= 10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.'') + ''m''
							WHEN SUM(ticketCNT) >= 1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.'') + ''m''
							WHEN SUM(ticketCNT) >= 100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.'') + ''k''
							WHEN SUM(ticketCNT) >= 10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),2), '','', ''.'') + ''k''
							WHEN SUM(ticketCNT) >= 1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.''), ''.0'','''') + ''k''	
							--WHEN SUM(ticketCNT) >= 100 THEN ''0.''+ REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),1), '','', ''.'') + ''k''
							WHEN SUM(ticketCNT) <= -10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),5), '','', ''.'') + ''m''
							WHEN SUM(ticketCNT) <= -1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.'') + ''m''
							WHEN SUM(ticketCNT) <= -100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.'') + ''k''
							WHEN SUM(ticketCNT) <= -10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.'') + ''k''
							WHEN SUM(ticketCNT) <= -1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.''), ''.0'','''') + ''k''
							--WHEN SUM(ticketCNT) <= -100 THEN ''-0.''+ REPLACE(LEFT(-SUM(ticketCNT),1), '','', ''.'') + ''k''
							ELSE parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2)
						END
				,sCNT = SUM(TicketCNT)
				,sWL = SUM(WL)
			FROM #perf2 b
				LEFT JOIN dbo.sports s1 ON b.matchid = s1.sporttype
				LEFT JOIN dbo.match m WITH(NOLOCK) on b.matchid = m.matchid
				LEFT JOIN dbo.sports s WITH(NOLOCK) on m.sporttype = s.sporttype	
			GROUP BY LEFT(REPLACE(CASE 
									WHEN b.matchid = 29 THEN ''Parlay'' 
									WHEN b.matchid = 2799 THEN ''Virtual Sports Parlay''
									WHEN b.matchid BETWEEN 21301 AND 21831 THEN ''NG2''
									WHEN b.matchid < 20000 THEN s1.SportName
								ELSE COALESCE(s.SportName,''-'') END,'' '',''''), 7)
			HAVING SUM(TicketCNT) > 100
	)
	SELECT @msg += left(sportname + replicate('' '',7),7) + RIGHT(space(7) + [WL], 7) + RIGHT(space(7) + [TC], 7) + ''<br>''
	FROM _s2
	ORDER BY sWL desc
	
	-- 4. by site
	SET @msg += ''------------------[g]<br>''
	DECLARE @c8_WL_today money
	SELECT @c8_WL_today = SUM(WL) FROM #TODAY_ResetWinning WHERE isC8 = 1

	;WITH _s AS (
		SELECT S = CASE WHEN l.LicenseeID = 13 THEN ''MBC'' ELSE COALESCE(lic.site, ds.site) END
			,WL = CASE WHEN CASE WHEN l.LicenseeID = 13 THEN ''MBC'' ELSE COALESCE(lic.site, ds.site) END = ''CN88'' THEN @c8_WL_today ELSE -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate), 0) END
			,TicketCNT = count(transid)
			,isDep = case when ds.custid is not null then 1 else 0 end
			,rn = ROW_NUMBER() OVER(ORDER BY case when ds.custid is not null then 1 else 0 end ASC, count(transid) desc)
		FROM dbo.bettrans b WITH(NOLOCK) 
			INNER JOIN dbo.CustAgent ag WITH(NOLOCK) ON b.recommend = ag.custid
			INNER JOIN dbo.custinfo cag WITH(NOLOCK) ON ag.custid = cag.custid
			LEFT JOIN dbo.site lic with(nolock) on ag.site = lic.site	
			LEFT JOIN dbo.dep_custsuper ds with(NOLOCK) on cag.srecommend = ds.custid
			LEFT JOIN bodb_Licensee.dbo.Labels l WITH(NOLOCK) on lic.site = l.LabelName
		WHERE winlostdate = @wldate
			AND b.matchid > 0
			AND b.statusid IN (111,112,113)
			AND b.currency <> 20
			AND b.bettype < 19999
			AND b.bettype NOT IN (2198, 2398, 2998, 2199, 2399, 2999) --jackpot
		GROUP BY CASE WHEN l.LicenseeID = 13 THEN ''MBC'' ELSE COALESCE(lic.site, ds.site) END, case when ds.custid is not null then 1 else 0 end
		HAVING CASE WHEN l.LicenseeID = 13 THEN ''MBC'' ELSE COALESCE(lic.site, ds.site) END IS NOT NULL
	), _s1 AS (	
		SELECT rn=CASE WHEN rn<9 THEN rn ELSE 9 END
			,S = CASE 
					WHEN rn<9 AND S IN (''MBC'') THEN ''M''
					WHEN rn<9 AND S IN (''789y'', ''y987'') THEN ''Y''					
					WHEN rn<9 AND S IN (''CN88'') THEN ''C8 [n]''
					WHEN rn<9 AND S IN (''asiabet88'') THEN ''F8''
					WHEN rn<9 AND S IN (''haifa'') THEN ''HF''
					WHEN rn<9 AND S IN (''mansion88'') THEN ''m8''
					WHEN rn<9 AND S IN (''12Bet'') THEN ''12''
					WHEN rn<9 AND S IN (''W88'') THEN ''w8''
					WHEN rn<9 THEN LEFT(S,3) 
				ELSE ''Others'' END
			,WL = CASE 
						WHEN sum(WL) >= 10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.'') + ''m''
						WHEN sum(WL) >= 1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.'') + ''m''
						WHEN sum(WL) >= 100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.'') + ''k''
						WHEN sum(WL) >= 10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),2), '','', ''.'') + ''k''
						WHEN sum(WL) >= 1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.''), ''.0'','''') + ''k''	
						--WHEN sum(WL) >= 100 THEN ''0.''+ REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),1), '','', ''.'') + ''k''
						WHEN sum(WL) <= -10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),5), '','', ''.'') + ''m''
						WHEN sum(WL) <= -1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.'') + ''m''
						WHEN sum(WL) <= -100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.'') + ''k''
						WHEN sum(WL) <= -10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),3), '','', ''.'') + ''k''
						WHEN sum(WL) <= -1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2),4), '','', ''.''), ''.0'','''') + ''k''
						--WHEN sum(WL) <= -100 THEN ''-0.''+ REPLACE(LEFT(-sum(WL),1), '','', ''.'') + ''k''
						ELSE parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)						
					END	
			,TC = CASE 
						WHEN SUM(ticketCNT) >= 10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.'') + ''m''
						WHEN SUM(ticketCNT) >= 1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.'') + ''m''
						WHEN SUM(ticketCNT) >= 100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.'') + ''k''
						WHEN SUM(ticketCNT) >= 10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),2), '','', ''.'') + ''k''
						WHEN SUM(ticketCNT) >= 1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.''), ''.0'','''') + ''k''	
						--WHEN SUM(ticketCNT) >= 100 THEN ''0.''+ REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),1), '','', ''.'') + ''k''
						WHEN SUM(ticketCNT) <= -10000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),5), '','', ''.'') + ''m''
						WHEN SUM(ticketCNT) <= -1000000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.'') + ''m''
						WHEN SUM(ticketCNT) <= -100000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.'') + ''k''
						WHEN SUM(ticketCNT) <= -10000 THEN REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),3), '','', ''.'') + ''k''
						WHEN SUM(ticketCNT) <= -1000 THEN REPLACE(REPLACE(LEFT(parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2),4), '','', ''.''), ''.0'','''') + ''k''
						--WHEN SUM(ticketCNT) <= -100 THEN ''-0.''+ REPLACE(LEFT(-SUM(ticketCNT),1), '','', ''.'') + ''k''
						ELSE parsename(CONVERT(VARCHAR, convert(MONEY, SUM(ticketCNT)), 1), 2)
					END			
		FROM _s
		GROUP BY CASE WHEN rn<9 THEN rn ELSE 9 END
			,CASE 
				WHEN rn<9 AND S IN (''MBC'') THEN ''M''
				WHEN rn<9 AND S IN (''789y'', ''y987'') THEN ''Y''					
				WHEN rn<9 AND S IN (''CN88'') THEN ''C8 [n]''
				WHEN rn<9 AND S IN (''asiabet88'') THEN ''F8''
				WHEN rn<9 AND S IN (''haifa'') THEN ''HF''
				WHEN rn<9 AND S IN (''mansion88'') THEN ''m8''
				WHEN rn<9 AND S IN (''12Bet'') THEN ''12''
				WHEN rn<9 AND S IN (''W88'') THEN ''w8''
				WHEN rn<9 THEN LEFT(S,3) 
			ELSE ''Others'' END
	)
	SELECT @msg += left(S + replicate('' '',7),7) + RIGHT(space(7) + [WL], 7) + RIGHT(space(7) + [TC], 7) + ''<br>''	
	FROM _s1
	ORDER BY rn ASC
	
	-- data for MTD	
	CREATE TABLE #test2 (product varchar(50), WL money, isC8 bit)

	IF datepart(dd, CURRENT_TIMESTAMP) <> 2 -- no MTD data yet.
	BEGIN
		--SET @msg += ''---------------------<br><br>'' + convert(varchar, getdate(), 20)

		-- SEND and reset message ------------------------------
		EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VIETGROUP'', @Msg = @msg;
		--EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VIET'', @Msg = @msg
		-- /SEND and reset message ------------------------------

		DECLARE @dateFrom datetime
		DECLARE @dateTo datetime
		DECLARE @balanceupday datetime
	
		SET @dateTo = DATEADD(dd, -1, @wldate)
		SET @dateFrom = DATEADD(MM, DATEDIFF(MM, 0, @dateTo), 0)

		SELECT @balanceupday = MAX(winlostdate) from bettrans with(nolock) WHERE matchid = 0 and bettype = 20000 and custid < 100

	
		INSERT INTO #test2 (product, WL, isC8)
		SELECT Product = CASE b.custid WHEN 37639217 THEN ISNULL(SUBSTRING(b.transdesc, 10, CHARINDEX (''#'', b.Transdesc )-10),'''') ELSE s.product END
			,WL = sum((winlost-actual_stake)*actualrate)
			,isC8 = CASE b.custid WHEN 37639217 THEN 1 ELSE 0 END
		FROM DBACC.bodb_archive.dbo.transfer_fi b WITH(NOLOCK)
			inner join #Test1 s ON b.custid = s.custid
		WHERE winlostdate between @dateFrom and CASE WHEN DATEADD(DD, -1, @balanceupday) < @dateTO THEN DATEADD(DD, -1, @balanceupday) ELSE @dateTO END
			AND bettype IN (21001,21002)
		GROUP BY CASE b.custid WHEN 37639217 THEN ISNULL(SUBSTRING(b.transdesc, 10, CHARINDEX (''#'', b.Transdesc )-10),'''') ELSE s.product END
			,CASE b.custid WHEN 37639217 THEN 1 ELSE 0 END

		INSERT INTO #test2 (product, WL, isC8)
		SELECT Product = CASE b.custid WHEN 37639217 THEN ISNULL(SUBSTRING(b.transdesc, 10, CHARINDEX (''#'', b.Transdesc )-10),'''') ELSE s.product END
			,WL = sum((winlost-actual_stake)*actualrate)
			,isC8 = CASE b.custid WHEN 37639217 THEN 1 ELSE 0 END
		FROM dbo.bettrans b WITH(NOLOCK)
			inner join #Test1 s ON b.custid = s.custid
		WHERE winlostdate BETWEEN CASE WHEN DATEADD(DD, -1, @balanceupday) < @dateFrom THEN @dateFrom ELSE DATEADD(DD, -1, @balanceupday) END AND @dateTo
			AND bettype IN (21001,21002)
		GROUP BY CASE b.custid WHEN 37639217 THEN ISNULL(SUBSTRING(b.transdesc, 10, CHARINDEX (''#'', b.Transdesc )-10),'''') ELSE s.product END
		,CASE b.custid WHEN 37639217 THEN 1 ELSE 0 END
	
		INSERT INTO #test2 (Product, WL, isC8)
		SELECT productName, WL, isC8
		FROM #TODAY_ResetWinning	
	
		-- 5. MTD		
		SET @msg = ''```<br>[MTD] as of '' + LEFT(convert(varchar, @wldate, 101), 5) + ''<br>------------------[n]<br>''
	
		;WITH _s as (
			SELECT 
				[prod] = CASE product WHEN ''extraPT'' THEN ''Extra PT'' ELSE ''Total WL'' END
				,[WL] = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)			
				,sumWL = SUM(WL)			
			FROM #test2
			GROUP BY CASE product WHEN ''extraPT'' THEN ''Extra PT'' ELSE ''Total WL'' END
		)
		,_s1 as (
			SELECT prod 
				,xWL = CASE
						WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''b''
						WHEN sumWL >= 100000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL >= 10000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL >= 1000000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''m''
						WHEN sumWL >= 100000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''k''
						WHEN sumWL >= 10000 THEN REPLACE(LEFT(WL,2), '','', ''.'') + ''k''
						WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''	
						--WHEN sumWL >= 100 THEN ''0.''+ REPLACE(LEFT(WL,1), '','', ''.'') + ''k''
						WHEN sumWL <= -10000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL <= -1000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL <= -100000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''
						WHEN sumWL <= -1000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						--WHEN sumWL <= -100 THEN ''-0.''+ REPLACE(LEFT(-sumWL,1), '','', ''.'') + ''k''
						ELSE WL
					END			
			FROM _s
		)
		SELECT @msg += left(prod + replicate('' '',14),14) + RIGHT(space(7) + [xWL], 7) + ''<br>''
		FROM _s1
		
		SET @msg += ''------------------[n]<br>''
		;WITH _s as (
			SELECT prod = CASE d.product WHEN ''Casino (Amount due to Jackpot Pool)'' THEN ''Casino ->JP.P'' 
									WHEN ''Virtual Sports'' THEN ''VS''
									WHEN ''Virtual Sports 2'' THEN ''VS2''
									WHEN ''Metric Gaming - Super Live'' THEN ''MG-SuperLive''
								ELSE d.product END		
				,[WL] = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)			
				,sumWL = SUM(WL)
				,s.seq
			FROM #test2 d
				INNER JOIN #Test1 s ON d.product = s.product
			WHERE d.product NOT IN (''extraPT'')
			GROUP BY CASE d.product WHEN ''Casino (Amount due to Jackpot Pool)'' THEN ''Casino ->JP.P'' 
									WHEN ''Virtual Sports'' THEN ''VS''
									WHEN ''Virtual Sports 2'' THEN ''VS2''
									WHEN ''Metric Gaming - Super Live'' THEN ''MG-SuperLive''
								ELSE d.product END	
					, s.seq
		)
		,_s1 as (
			SELECT prod
				,xWL = CASE
						WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''b''
						WHEN sumWL >= 100000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL >= 10000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL >= 1000000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''m''
						WHEN sumWL >= 100000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''k''
						WHEN sumWL >= 10000 THEN REPLACE(LEFT(WL,2), '','', ''.'') + ''k''
						WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''	
						--WHEN sumWL >= 100 THEN ''0.''+ REPLACE(LEFT(WL,1), '','', ''.'') + ''k''
						WHEN sumWL <= -10000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL <= -1000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL <= -100000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''
						WHEN sumWL <= -1000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						--WHEN sumWL <= -100 THEN ''-0.''+ REPLACE(LEFT(-sumWL,1), '','', ''.'') + ''k''
						ELSE WL
					END	
				,seq = sumWL		
			FROM _s
		)
		SELECT @msg += left(prod + replicate('' '',14),14) + RIGHT(space(7) + [xWL], 7) + ''<br>''
		FROM _s1
		ORDER BY seq DESC

		SET @msg += ''------------------[n]<br>''
		;WITH _s as (
			SELECT ''C8 TOTAL WL'' as product
				,[WL] = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)			
				,sumWL = SUM(WL)			
			FROM #test2
			WHERE isC8 = 1	
		)
		,_s1 as (
			SELECT product 
				,xWL = CASE
						WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''b''
						WHEN sumWL >= 100000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL >= 10000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL >= 1000000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''m''
						WHEN sumWL >= 100000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''k''
						WHEN sumWL >= 10000 THEN REPLACE(LEFT(WL,2), '','', ''.'') + ''k''
						WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''	
						--WHEN sumWL >= 100 THEN ''0.''+ REPLACE(LEFT(WL,1), '','', ''.'') + ''k''
						WHEN sumWL <= -10000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL <= -1000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL <= -100000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''
						WHEN sumWL <= -1000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						--WHEN sumWL <= -100 THEN ''-0.''+ REPLACE(LEFT(-sumWL,1), '','', ''.'') + ''k''
						ELSE WL
					END				
			FROM _s
		)
		SELECT @msg += left(product + replicate('' '',14),14) + RIGHT(space(7) + [xWL], 7) + ''<br>''
		FROM _s1
		
		SET @msg += ''------------------[n]<br>''
		;WITH _s as (
			SELECT product = ''C8 '' + CASE d.product WHEN ''Casino (Amount due to Jackpot Pool)'' THEN ''Casino ->JP.P'' 
									WHEN ''Virtual Sports'' THEN ''VS''
									WHEN ''Virtual Sports 2'' THEN ''VS2''
									WHEN ''Metric Gaming - Super Live'' THEN ''MG-SuperLive''
								ELSE d.product END
				,[WL] = parsename(CONVERT(VARCHAR, convert(MONEY, SUM(WL)), 1), 2)			
				,sumWL = SUM(WL)
				,s.seq
			FROM #test2 d
				INNER JOIN #Test1 s ON d.product = s.product
			WHERE isC8 = 1			
			GROUP BY d.product, s.seq		
		)
		,_s1 as (
			SELECT product 
				,xWL = CASE
						WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''b''
						WHEN sumWL >= 100000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL >= 10000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL >= 1000000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''m''
						WHEN sumWL >= 100000 THEN REPLACE(LEFT(WL,3), '','', ''.'') + ''k''
						WHEN sumWL >= 10000 THEN REPLACE(LEFT(WL,2), '','', ''.'') + ''k''
						WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''	
						--WHEN sumWL >= 100 THEN ''0.''+ REPLACE(LEFT(WL,1), '','', ''.'') + ''k''
						WHEN sumWL <= -10000000 THEN REPLACE(LEFT(WL,5), '','', ''.'') + ''m''
						WHEN sumWL <= -1000000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''m''
						WHEN sumWL <= -100000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(WL,3), '','', ''.''), ''.0'','''') + ''k''
						WHEN sumWL <= -1000 THEN REPLACE(LEFT(WL,4), '','', ''.'') + ''k''
						--WHEN sumWL <= -100 THEN ''-0.''+ REPLACE(LEFT(-sumWL,1), '','', ''.'') + ''k''
						ELSE WL
					END	
				,seq			
			FROM _s
			WHERE WL <> ''0''
		)
		SELECT @msg += left(product + replicate('' '',14),14) + RIGHT(space(7) + [xWL], 7) + ''<br>''
		FROM _s1
		ORDER BY seq
	END

	--SET @msg += ''---------------------<br><br>'' + convert(varchar, getdate(), 20) --+ ''<br>```''
	DROP TABLE #test1
	DROP TABLE #test2
	DROP TABLE #TODAY_ResetWinning
	DROP TABLE #perf
	DROP TABLE #perf2
END	


EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VIETGROUP'', @Msg = @msg;
--EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VIET'', @Msg = @msg

--PRINT @msg', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [for dataT]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'for dataT', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON;
-- Viet@2020011
-- if before 17h (server time), get yesterday''s data. otherwise, get today''s data instead
DECLARE @dayOffset int = CASE WHEN DATEPART (hour, CURRENT_TIMESTAMP) > 17 THEN 0 ELSE -1 END
IF @dayOffset = -1 RETURN -- no need to run this time

DECLARE @wldate smalldatetime = DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)
DECLARE @msg VARCHAR(max) = ''```<br>[''+ convert(varchar(10), @wldate, 112) +''] as of ''
	+ CASE WHEN DATEPART(hour, CURRENT_TIMESTAMP) > 12 THEN CAST(DATEPART(hour, CURRENT_TIMESTAMP)-12 as varchar) 
	+ ''PM'' ELSE CAST(DATEPART(hour, CURRENT_TIMESTAMP) as varchar) + ''AM'' END +''<br>''

SELECT 
	S = CASE 
			WHEN ISNULL(cs.CustID, '''') <> '''' THEN ''CN88''
			WHEN ag.site IN (''BEST-ODDS'',''INDO'',''XYZBET'',''611111'',''722222'',''733333'',''755555'',''222223'',''222225'',''222227'',''spotico'',''KORIBC'',''766666'',''7aa666'') THEN ''MBC''
			WHEN ag.site IN (''789y'', ''y987'') THEN ''789Y''
		ELSE ''CASH'' END
	,product = cast(m.matchid as varchar(8)) +''/''+ UPPER(LEFT(s.sportname, 3))
	,hometeam = h.teamname
	,awayteam = a.teamname
	,sumWL = -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)
	,p_sumWL = parsename(CONVERT(VARCHAR, convert(MONEY, -ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)), 1), 2)
INTO #TodayGames
FROM bettrans b WITH(NOLOCK)
	INNER JOIN match m WITH(NOLOCK) ON b.matchid = m.matchid
	INNER JOIN dbo.team h with(nolock) on m.homeid = h.teamid
	INNER JOIN dbo.team a with(nolock) on m.awayid = a.teamid
	INNER JOIN Customer ag WITH(NOLOCK) ON ag.custid = b.recommend
	INNER JOIN Sports s ON m.sporttype = s.SportType
	LEFT JOIN CS_CustSuper cs WITH (NOLOCK) ON cs.CustId = b.srecommend	
WHERE eventdate = @wldate
	AND m.eventstatus = ''completed''
	AND b.statusid > 1
	AND b.currency <> 20
	AND b.bettype < 19999
	AND b.bettype NOT IN (2198, 2398, 2998, 2199, 2399, 2999) --jackpot
GROUP BY h.teamname
	,a.teamname
	,cast(m.matchid as varchar(8)) +''/''+ UPPER(LEFT(s.sportname, 3))
	,CASE 
			WHEN ISNULL(cs.CustID, '''') <> '''' THEN ''CN88''
			WHEN ag.site IN (''BEST-ODDS'',''INDO'',''XYZBET'',''611111'',''722222'',''733333'',''755555'',''222223'',''222225'',''222227'',''spotico'',''KORIBC'',''766666'',''7aa666'') THEN ''MBC''
			WHEN ag.site IN (''789y'', ''y987'') THEN ''789Y''
		ELSE ''CASH'' END
HAVING ABS(-ISNULL(SUM((winlost-actual_stake + awinlost + mwinlost + swinlost + scomm)*actualrate),0)) > 50000


declare @tempTable as TABLE(S nvarchar(50), P nvarchar(12), hometeam nvarchar(100), awayteam nvarchar(100), xWL varchar(20), sumWL money)
;WITH _s as (
	SELECT 
		S
		,P = Product
		,hometeam
		,awayteam		
		,xWL = CASE
				WHEN sumWL >= 1000000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''b''
				WHEN sumWL >= 100000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
				WHEN sumWL >= 10000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
				WHEN sumWL >= 1000000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''m''
				WHEN sumWL >= 100000 THEN REPLACE(LEFT(p_sumWL,3), '','', ''.'') + ''k''
				WHEN sumWL >= 10000 THEN REPLACE(LEFT(p_sumWL,2), '','', ''.'') + ''k''
				WHEN sumWL >= 1000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''						
				WHEN sumWL <= -10000000 THEN REPLACE(LEFT(p_sumWL,5), '','', ''.'') + ''m''
				WHEN sumWL <= -1000000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''m''
				WHEN sumWL <= -100000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''
				WHEN sumWL <= -10000 THEN REPLACE(REPLACE(LEFT(p_sumWL,3), '','', ''.''), ''.0'','''') + ''k''
				WHEN sumWL <= -1000 THEN REPLACE(LEFT(p_sumWL,4), '','', ''.'') + ''k''					
				ELSE p_sumWL
			END		
		,sumWL
	FROM #TodayGames
)
INSERT INTO @tempTable (S, P, hometeam, awayteam, xWL, sumWL)
SELECT S, P, hometeam, awayteam, xWL, sumWL
FROM _s order by abs(sumWL) desc

SET @msg += ''<br>[Y]<br>---------------------''
SELECT @msg += ''<br>'' + LEFT(hometeam + replicate('' '',14),14)			
			+ RIGHT(space(7) + xWL, 7) 
			+ ''<br>'' + LEFT(awayteam + replicate('' '',8),8) + '' '' + RIGHT(space(12) + P, 12) + ''<br>''
FROM @tempTable
WHERE S = ''789Y''
ORDER BY sumWL ASC

EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VietGroupData'', @Msg = @msg;
set @msg = ''```''

SET @msg += ''<br>[M]<br>---------------------''
SELECT @msg += ''<br>'' + LEFT(hometeam + replicate('' '',14),14)			
			+ RIGHT(space(7) + xWL, 7) 
			+ ''<br>'' + LEFT(awayteam + replicate('' '',8),8) + '' '' + RIGHT(space(12) + P, 12) + ''<br>''
FROM @tempTable
WHERE S = ''MBC''
ORDER BY sumWL ASC

EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VietGroupData'', @Msg = @msg;
set @msg = ''```''

SET @msg += ''<br>[CASH]<br>---------------------''
SELECT @msg += ''<br>'' + LEFT(hometeam + replicate('' '',14),14)			
			+ RIGHT(space(7) + xWL, 7) 
			+ ''<br>'' + LEFT(awayteam + replicate('' '',8),8) + '' '' + RIGHT(space(12) + P, 12) + ''<br>''
FROM @tempTable
WHERE S = ''CASH''
ORDER BY sumWL ASC


EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VietGroupData'', @Msg = @msg;
set @msg = ''```''

SET @msg += ''<br>[C8]<br>---------------------''
SELECT @msg += ''<br>'' + LEFT(hometeam + replicate('' '',14),14)			
			+ RIGHT(space(7) + xWL, 7) 
			+ ''<br>'' + LEFT(awayteam + replicate('' '',8),8) + '' '' + RIGHT(space(12) + P, 12) + ''<br>''
FROM @tempTable
WHERE S = ''CN88''
ORDER BY sumWL ASC


EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VietGroupData'', @Msg = @msg;
--EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To = ''VIET'', @Msg = @msg

--PRINT @msg
DROP TABLE #TodayGames
', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Occurs every day at 01:00 AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20191002, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'b9e5e28b-697a-46c3-8e59-2217e6425938'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Occurs every day at 7:00 PM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140606, 
		@active_end_date=99991231, 
		@active_start_time=190010, 
		@active_end_time=235959, 
		@schedule_uid=N'9e7da498-9200-4762-b7d0-2f0224c1c5f0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [vnDBA : Objects Monitoring - Collect Data]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Starix Jobs Monitoring]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Starix Jobs Monitoring' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Starix Jobs Monitoring'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'vnDBA : Objects Monitoring - Collect Data', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Author: Lukas
Task: Job for collecting data for Objects Monitoring Function.', 
		@category_name=N'Starix Jobs Monitoring', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Schedule - Staging Jobs Information]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Schedule - Staging Jobs Information', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @isRun BIT = 0;

EXECUTE vnDBA_sp_CheckSchedules @schedule_type = ''MON_STAGING'', @isRun = @isRun OUTPUT;

IF @isRun = 0
RAISERROR(''Wait for scheduled time...'', 11, 0) WITH NOWAIT
', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Staging Objects Information]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Staging Objects Information', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE vnDBA_sp_Monitor_CollectInfo;', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Auto Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160701, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd5549103-46ba-497c-a8c6-b15fa4f9e97e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [vnDBA: Monitor_dba_tasks]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'vnDBA: Monitor_dba_tasks', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [check service broker status]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'check service broker status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.Task_DBA_Monitor_ServiceBroker @IsDebug = 0
', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_10_minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170419, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'61dd3135-f982-4a2a-a34f-1eec1d5b7706'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [vndba: SC health check test]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'vndba: SC health check test', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'Viet', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run script]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run script', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @min1 int, @min3 int
SELECT @min1 = SUM(CASE WHEN transdate > DATEADD(minute, -2, CURRENT_TIMESTAMP) THEN 1 ELSE 0 END)
	,@min3 =SUM(CASE WHEN transdate > DATEADD(minute, -5, CURRENT_TIMESTAMP) THEN 1 ELSE 0 END)
FROM dbo.bettransRnG WITH(NOLOCK)
WHERE vendorID=42	
	AND transdate > DATEADD(minute, -5, CURRENT_TIMESTAMP)
	AND currency IN (16, 64)

IF (@min1 < 30 AND @min3 > 30)
BEGIN
	DECLARE @msg varchar(1000)
	SET @msg = CAST(@min1 as varchar(10)) + '' bets in last 2 mins
'' + CAST(@min3 as varchar(10)) + '' bets in last 5 minutes''
	
	EXECUTE	DBSPAREKBT.NotificationDB.dbo.Letstalk_SendMessage @To = ''NotiGroup5'', @Msg = @msg, @Title = ''SC1 Alert'' -- NotiGroup5
END', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'90s', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=90, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200705, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'b511d506-b7de-4dad-9792-0f49544c9c82'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [vndba: temp perf report test]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'vndba: temp perf report test', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'these is a temporary job then no need to sync to MNL site', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'Viet', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run script]    Script Date: 12/24/2021 6:26:23 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run script', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- if before 2AM (server time), get yesterday''s data. otherwise, get today''s data instead
SET NOCOUNT ON

DECLARE @dayOffset int = CASE WHEN DATEPART (hour, CURRENT_TIMESTAMP) >= 2 THEN 0 ELSE -1 END

DECLARE @wldate smalldatetime = DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), @dayOffset)

DECLARE @msg VARCHAR(max) = ''''
DECLARE @msg2 VARCHAR(max) = ''''
DECLARE @title varchar(22)

IF (@dayOffset = 0)
BEGIN
	SET @title = CONVERT(VARCHAR(5), @wldate, 1) + '' ''
	+ CASE 
		WHEN DATEPART(hour, CURRENT_TIMESTAMP) > 12 THEN CAST(DATEPART(hour, CURRENT_TIMESTAMP)-12 as varchar) + '':'' + CAST(DATEPART(minute, CURRENT_TIMESTAMP) as varchar) + ''pm''
		WHEN DATEPART(hour, CURRENT_TIMESTAMP) = 12 THEN CAST(DATEPART(hour, CURRENT_TIMESTAMP) as varchar) + '':'' + CAST(DATEPART(minute, CURRENT_TIMESTAMP) as varchar) + ''pm''
		ELSE CAST(DATEPART(hour, CURRENT_TIMESTAMP) as varchar) + '':'' + CAST(DATEPART(minute, CURRENT_TIMESTAMP) as varchar) + ''am'' END
	+'' gmt-4''	
END
ELSE
BEGIN
	SET @title = CONVERT(VARCHAR(10), @wldate, 101)
END

CREATE TABLE #tmpResetWinning (
	Site VARCHAR(50), SB TINYINT, TurnOver	MONEY, Margin MONEY, HouseWinlost MONEY, isDeposit smallint
)

INSERT INTO #tmpResetWinning (Site, SB, TurnOver, Margin, HouseWinlost, isDeposit)
EXEC Acc_ResetWinning_MarginBySite @Winlostdate = @wldate

DECLARE @WLBySite as TABLE (S varchar(30), WL money, TurnOver money , MG MONEY, rn int)
INSERT INTO @WLBySite(S, WL, TurnOver, MG, rn)
SELECT  S = CASE 
				WHEN Site IN (''BEST-ODDS'',''XYZBET'') THEN ''XYZ & Bestodds''
				WHEN Site IN (''611111'') THEN ''611 (China)''
				WHEN Site IN (''733333'') THEN ''733 (Malaysia)''
				WHEN Site IN (''755555'') THEN ''755 (Thailand)''
				WHEN Site IN (''INDO'') THEN ''Indo''
				WHEN Site IN (''IbcIndo'') THEN ''IbcIndo''
				WHEN Site IN (''IBCMMR'') THEN ''Myanmar''
				WHEN Site IN (''722222'',''222223'',''222225'',''222227'',''spotico'',''KORIBC'',''766666'', ''76666B'', ''7aa666'', ''Saba789'') THEN ''Others''
				WHEN Site IN (''789y'', ''y987'') AND SB = 1 THEN ''789Y SB''
				WHEN Site IN (''789y'', ''y987'') AND SB = 0 THEN ''789Y Non-SB''
				WHEN Site = ''Total (w/o CN88)'' THEN ''TOTAL''
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 1 THEN ''CV SB''
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 0 THEN ''CV NS''
			ELSE CASE WHEN SB = 1 THEN ''CASH SB'' ELSE ''CASH Non-SB'' END END			
		,WL = -SUM(ISNULL(HouseWinlost,0))  
		,TurnOver = SUM(ISNULL(TurnOver,0)) 
		,MG = CASE WHEN SUM(ISNULL(TurnOver,0)) = 0 THEN 0 ELSE -SUM(ISNULL(HouseWinlost,0))/SUM(ISNULL(TurnOver,0)) * 100 END
		,rn = CASE 
				WHEN Site IN (''BEST-ODDS'',''XYZBET'') THEN 1
				WHEN Site IN (''611111'') THEN 2
				WHEN Site IN (''733333'') THEN 3
				WHEN Site IN (''755555'') THEN 4
				WHEN Site IN (''INDO'') THEN 5
				WHEN Site IN (''IbcIndo'') THEN 6
				WHEN Site IN (''IBCMMR'') THEN 7
				WHEN Site IN (''722222'',''222223'',''222225'',''222227'',''spotico'',''KORIBC'',''766666'', ''76666B'', ''7aa666'', ''Saba789'') THEN 8
				WHEN Site IN (''789y'', ''y987'') AND SB = 1 THEN 9
				WHEN Site IN (''789y'', ''y987'') AND SB = 0 THEN 10
				WHEN Site = ''Total (w/o CN88)'' THEN 15
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 1 THEN 13
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 0 THEN 14
			ELSE CASE WHEN SB = 1 THEN 11 ELSE 12 END END
FROM #tmpResetWinning
WHERE SITE NOT IN (''CN88'') AND isDeposit IN (0,1,2,5)
GROUP BY CASE 
				WHEN Site IN (''BEST-ODDS'',''XYZBET'') THEN ''XYZ & Bestodds''
				WHEN Site IN (''611111'') THEN ''611 (China)''
				WHEN Site IN (''733333'') THEN ''733 (Malaysia)''
				WHEN Site IN (''755555'') THEN ''755 (Thailand)''
				WHEN Site IN (''INDO'') THEN ''Indo''
				WHEN Site IN (''IbcIndo'') THEN ''IbcIndo''
				WHEN Site IN (''IBCMMR'') THEN ''Myanmar''
				WHEN Site IN (''722222'',''222223'',''222225'',''222227'',''spotico'',''KORIBC'',''766666'', ''76666B'', ''7aa666'', ''Saba789'') THEN ''Others''
				WHEN Site IN (''789y'', ''y987'') AND SB = 1 THEN ''789Y SB''
				WHEN Site IN (''789y'', ''y987'') AND SB = 0 THEN ''789Y Non-SB''
				WHEN Site = ''Total (w/o CN88)'' THEN ''TOTAL''
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 1 THEN ''CV SB''
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 0 THEN ''CV NS''
			ELSE CASE WHEN SB = 1 THEN ''CASH SB'' ELSE ''CASH Non-SB'' END END	
		,CASE 
				WHEN Site IN (''BEST-ODDS'',''XYZBET'') THEN 1
				WHEN Site IN (''611111'') THEN 2
				WHEN Site IN (''733333'') THEN 3
				WHEN Site IN (''755555'') THEN 4
				WHEN Site IN (''INDO'') THEN 5
				WHEN Site IN (''IbcIndo'') THEN 6
				WHEN Site IN (''IBCMMR'') THEN 7
				WHEN Site IN (''722222'',''222223'',''222225'',''222227'',''spotico'',''KORIBC'',''766666'', ''76666B'', ''7aa666'', ''Saba789'') THEN 8
				WHEN Site IN (''789y'', ''y987'') AND SB = 1 THEN 9
				WHEN Site IN (''789y'', ''y987'') AND SB = 0 THEN 10
				WHEN Site = ''Total (w/o CN88)'' THEN 15
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 1 THEN 13
				WHEN isDeposit = 1 AND Site like ''%CV'' AND SB = 0 THEN 14
			ELSE CASE WHEN SB = 1 THEN 11 ELSE 12 END END

-- generate string for winlost by site
SELECT @msg = @msg + ''<br>'' + 
	CASE WHEN S = ''All Sports'' THEN ''ALL''
		WHEN S = ''XYZ & Bestodds'' THEN ''XYZ & BO''
		WHEN S = ''611 (China)'' THEN ''611 (Chi)''
		WHEN S = ''733 (Malaysia)'' THEN ''733 (Mala)''
		WHEN S = ''755 (Thailand)'' THEN ''755 (Thai)''
		WHEN S = ''789Y SB'' THEN ''Y SB''
		WHEN S = ''789Y Non-SB'' THEN ''Y NS''
		WHEN S = ''CASH SB'' THEN ''C SB''
		WHEN S = ''CASH Non-SB'' THEN ''C NS''
		WHEN S = ''CV SB'' THEN ''CV SB''
		WHEN S = ''CV NS'' THEN ''CV NS''
	ELSE S END + '': ''
		--+ CASE WHEN ABS(WL) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),WL/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),WL/1000) as VARCHAR(10)) + ''k'' END 	
		+ CASE 
			WHEN ABS(WL) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(WL / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(WL) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(WL / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), WL) END
		+ '' '' + CAST(CONVERT(DECIMAL(10,2), MG) as VARCHAR(10)) + ''%''	
FROM @WLBySite
ORDER BY rn

DECLARE @submsg VARCHAR(1000)
SELECT @submsg = ''<br>T SB: ''	
		--+ CASE WHEN ABS(SUM(HouseWinlost)) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),-SUM(HouseWinlost)/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),-SUM(HouseWinlost)/1000) as VARCHAR(10)) + ''k'' END
		+ CASE 
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) BETWEEN 0 AND 999999 THEN (CONVERT(VARCHAR(10), (CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), (CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), -ISNULL(SUM(HouseWinlost),0)) END
		+ '' M: '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
		
FROM #tmpResetWinning
WHERE SB = 1 AND isDeposit IN (0,1) AND Site NOT IN (''CN88'')

SELECT @submsg = @submsg + ''<br>T NS: ''	
		--+ CASE WHEN ABS(SUM(HouseWinlost)) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),-SUM(HouseWinlost)/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),-SUM(HouseWinlost)/1000) as VARCHAR(10)) + ''k'' END
		+ CASE 
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), -SUM(HouseWinlost)) END
		+ '' M: '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpResetWinning
WHERE SB = 0 AND isDeposit IN (0,1) AND Site NOT IN (''CN88'')

SET @msg = REPLACE(@msg, ''TOTAL'', @submsg + ''<br><br>TOTAL'')

/*
-- generate string for CN88
SELECT @msg = @msg + ''<br><br>**C8: ''
		--+ CASE WHEN ABS(SUM(-ISNULL(HouseWinlost,0))) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),SUM(-ISNULL(HouseWinlost,0))/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),SUM(-ISNULL(HouseWinlost,0))/1000) as VARCHAR(10)) + ''k'' END 
		+ CASE 
			WHEN ABS(-SUM(HouseWinlost)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-SUM(HouseWinlost) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(-SUM(HouseWinlost)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-SUM(HouseWinlost) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), -SUM(HouseWinlost)) END
		+ '' '' + CAST(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/SUM(Turnover)) as VARCHAR(10)) + ''%''
		--+ ''<br>''
FROM #tmpResetWinning
WHERE Site IN (''CN88'')
*/

CREATE TABLE #tmpMargin (
	SportName VARCHAR(50), Liveindicator BIT, IsSaba tinyint, TurnOver MONEY, Margin MONEY, HouseWinlost MONEY
)

INSERT INTO #tmpMargin (SportName, Liveindicator,  IsSaba, TurnOver, Margin, HouseWinlost)
EXEC Acc_ResetWinning_MarginBySport @Winlostdate = @wldate

SELECT @msg = @msg + ''<br>-------<br>[SB TO & M]''

-- generate string for TO & Margin
;WITH _S as (
	SELECT SportName = CASE WHEN SportName = ''All Sports'' THEN ''ALL''				
				WHEN SportName = ''Soccer'' AND Liveindicator = 1 AND IsSaba = 0 THEN ''R.Soc(L)''
				WHEN SportName = ''Soccer'' AND Liveindicator = 0 AND IsSaba = 0 THEN ''R.Soc(NL)''					
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN ''Saba.Soc''
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN ''Saba.PG''	-- Saba Soccer Pingoal
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN ''Real.Bas''
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN ''Saba.Bas''
				WHEN SportName = ''Tennis'' THEN ''Tenn''				
				WHEN SportName = ''E-Sports'' THEN ''E-Spo''
				WHEN SportName = ''Cricket'' THEN ''Cricket''
				WHEN SportName = ''Other Sports'' THEN ''Others''
				WHEN SportName = ''Parlay'' THEN ''Parl''
			ELSE SportName END
		,rn = CASE WHEN SportName = ''All Sports'' THEN 1				
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 1 THEN 3
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 0 THEN 4					
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN 5
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN 6
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN 7
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN 8
				WHEN SportName = ''Tennis'' THEN 9
				WHEN SportName = ''E-Sports'' THEN 10				
				WHEN SportName = ''Cricket'' THEN 11
				WHEN SportName = ''Other Sports'' THEN 12
				WHEN SportName = ''Parlay'' THEN 13
			ELSE 14 END		
		, VAL = CASE 
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMargin
GROUP BY CASE WHEN SportName = ''All Sports'' THEN ''ALL''				
				WHEN SportName = ''Soccer'' AND Liveindicator = 1 AND IsSaba = 0 THEN ''R.Soc(L)''
				WHEN SportName = ''Soccer'' AND Liveindicator = 0 AND IsSaba = 0 THEN ''R.Soc(NL)''				
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN ''Saba.Soc''
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN ''Saba.PG''	-- Saba Soccer Pingoal
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN ''Real.Bas''
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN ''Saba.Bas''
				WHEN SportName = ''Tennis'' THEN ''Tenn''				
				WHEN SportName = ''E-Sports'' THEN ''E-Spo''
				WHEN SportName = ''Cricket'' THEN ''Cricket''
				WHEN SportName = ''Other Sports'' THEN ''Others''
				WHEN SportName = ''Parlay'' THEN ''Parl''
			ELSE SportName END
		,CASE WHEN SportName = ''All Sports'' THEN 1				
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 1 THEN 3
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 0 THEN 4					
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN 5
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN 6
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN 7
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN 8
				WHEN SportName = ''Tennis'' THEN 9
				WHEN SportName = ''E-Sports'' THEN 10
				WHEN SportName = ''Cricket'' THEN 11
				WHEN SportName = ''Other Sports'' THEN 12
				WHEN SportName = ''Parlay'' THEN 13
			ELSE 14 END	

UNION ALL 
SELECT SportName = ''Real.Soc''
	,rn = 2
	,VAL = CASE 
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMargin
WHERE SportName = ''Soccer'' AND IsSaba = 0
)
SELECT @msg = @msg + ''<br>'' + SportName + '': '' + VAL
FROM _S
ORDER BY rn

-- PHAIO
CREATE TABLE #tmpMarginPH (
	Market VARCHAR(50), TurnOver	MONEY, Margin MONEY, HouseWinlost MONEY
)

SELECT @msg = @msg + ''<br>-------<br>[PH TO & M]''

INSERT INTO #tmpMarginPH (Market, TurnOver, Margin, HouseWinlost)
EXEC Acc_ResetWinning_MarginByMarket @Winlostdate = @wldate

SELECT @msg = @msg + ISNULL(''<br>''
		+ Market + '': ''
			--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
			+ CASE 
				WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
				WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
				ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
			+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -HouseWinlost*100/NULLIF(TurnOver,0)),0) as VARCHAR(10)) + ''%''
			,'''')
FROM #tmpMarginPH
WHERE Market = ''PHAIO''

SELECT @msg = @msg + ''<br>[TimeM TO & M]''
SELECT @msg = @msg + ISNULL(''<br>''
		+ Market + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -HouseWinlost*100/NULLIF(TurnOver,0)),0) as VARCHAR(10)) + ''%''	
		,'''')	
FROM #tmpMarginPH
WHERE Market LIKE ''TimeM%''

-- non sports
CREATE TABLE #tmpMarginNonSport (
	ProductName VARCHAR(50), TurnOver MONEY, Margin MONEY, HouseWinlost MONEY, ProductCode VARCHAR(50), ProductGroup VARCHAR(10)
)

INSERT INTO #tmpMarginNonSport (ProductName, TurnOver, Margin, HouseWinlost)
EXEC Acc_ResetWinning_MarginByNonSport @Winlostdate = @wldate

-- merge vgaming into sc
;WITH _s AS (
	SELECT TurnOver_SC = SUM(TurnOver), HouseWinlost_SC = SUM(HouseWinlost)
	FROM #tmpMarginNonSport
	WHERE ProductName IN (''Saba.club'', ''Vgaming'')
)
UPDATE #tmpMarginNonSport
SET TurnOver = TurnOver_SC, HouseWinlost = HouseWinlost_SC, Margin = HouseWinlost_SC * 100 / TurnOver_SC
FROM _s
WHERE ProductName = ''Saba.club''

DELETE #tmpMarginNonSport WHERE ProductName = ''Vgaming''
-- /merge vgaming into sc

--2021-12-24: remove saba promotion from NS
DELETE #tmpMarginNonSport WHERE ProductName = ''Saba Promotion''

UPDATE #tmpMarginNonSport
SET ProductCode = CASE WHEN ProductName = ''All Non Sports'' THEN ''ALL'' 
			WHEN ProductName = ''Bet Builder'' THEN ''BetB''
			WHEN ProductName = ''Metric Gaming - Super Live'' THEN ''MetricG''
			WHEN ProductName = ''Number Game'' THEN ''NumG''
			WHEN ProductName = ''Virtual Sports'' THEN ''VirtSpo''
			WHEN ProductName = ''RNG Casino'' THEN ''1RNG''
			WHEN ProductName = ''RNG Keno'' THEN ''MKeno''
			WHEN ProductName = ''Colossus Bets'' THEN ''CB''
			WHEN ProductName = ''Allbet'' THEN ''AllB''
			WHEN ProductName = ''Macau Games'' THEN ''MacauG''
			WHEN ProductName = ''Fishing World'' THEN ''FishW''
			WHEN ProductName = ''Cash Out'' THEN ''CashO''
			WHEN ProductName = ''Virtual Sports 2'' THEN ''VirtSpo2''
			WHEN ProductName = ''Lottery'' THEN ''MLotte''
			--WHEN ProductName = ''Card Club'' THEN ''CardC''
			WHEN ProductName = ''Arcadia Gaming'' THEN ''ArcaGam''
			WHEN ProductName = ''PG Soft'' THEN ''PGSoft''
			WHEN ProductName = ''Virtual Games'' THEN ''VirtG''
			WHEN ProductName = ''Table Game'' THEN ''TableG''
			WHEN ProductName = ''Saba.club'' THEN ''SabaC''
			WHEN ProductName = ''Togel 4D'' THEN ''Togel4D''
			WHEN ProductName = ''PP'' THEN ''PragP''
			WHEN ProductName = ''SG'' THEN ''SpadeG''
			WHEN ProductName = ''IBCBet Live Casino'' THEN ''IBCLC''
			WHEN ProductName = ''SA Gaming'' THEN ''SAG''
			WHEN ProductName = ''RNG War'' THEN ''RNGWar''
			WHEN ProductName = ''Gold Deluxe'' THEN ''GoldD''
			WHEN ProductName = ''AG Casino'' THEN ''AG''
			WHEN ProductName = ''Sports Lottery'' THEN ''SportsLott''	
			WHEN ProductName = ''PP Live Casino'' THEN ''PP LC''
			WHEN ProductName = ''AE Sexy'' THEN ''AESexy''
			WHEN ProductName = ''Habanero'' THEN ''Haban''
			WHEN ProductName = ''AdvantPlay'' THEN ''AdPlay''
			WHEN ProductName = ''AdvantPlay Mini'' THEN ''AdPlayMini''
			
		ELSE ProductName END
	,ProductGroup = CASE WHEN ProductName = ''All Non Sports'' THEN ''-''
			WHEN ProductName = ''Allbet'' THEN ''LC''			
			WHEN ProductName = ''AE Sexy'' THEN ''LC''
			WHEN ProductName = ''IBCBet Live Casino'' THEN ''LC''
			WHEN ProductName = ''SA Gaming'' THEN ''LC''			
			WHEN ProductName = ''BBIN'' THEN ''LC''
			WHEN ProductName = ''ION'' THEN ''LC''			
			WHEN ProductName = ''Gold Deluxe'' THEN ''LC''
			WHEN ProductName = ''AG Casino'' THEN ''LC''
			WHEN ProductName = ''WM'' THEN ''LC''
			WHEN ProductName = ''GDG'' THEN ''LC''
			WHEN ProductName = ''BG'' THEN ''LC''			
			WHEN ProductName = ''PP Live Casino'' THEN ''LC''

			WHEN ProductName = ''Macau Games'' THEN ''RNG''
			WHEN ProductName = ''Fishing World'' THEN ''RNG''
			WHEN ProductName = ''Arcadia Gaming'' THEN ''RNG''
			WHEN ProductName = ''PG Soft'' THEN ''RNG''
			WHEN ProductName = ''Virtual Games'' THEN ''RNG''
			WHEN ProductName = ''Table Game'' THEN ''RNG''
			WHEN ProductName = ''Saba.club'' THEN ''RNG''			
			WHEN ProductName = ''PP'' THEN ''RNG''
			WHEN ProductName = ''SG'' THEN ''RNG''
			WHEN ProductName = ''Joker'' THEN ''RNG''
			WHEN ProductName = ''RNG War'' THEN ''RNG''
			WHEN ProductName = ''RNG Casino'' THEN ''RNG''
			WHEN ProductName = ''MaxGame'' THEN ''RNG''
			WHEN ProductName = ''Habanero'' THEN ''RNG''
			WHEN ProductName = ''Vgaming'' THEN ''RNG''
			WHEN ProductName = ''AdvantPlay'' THEN ''RNG''			
			WHEN ProductName = ''AdvantPlay Mini'' THEN ''RNG''
			WHEN ProductName = ''CG'' THEN ''RNG''
			
			WHEN ProductName = ''Lottery'' THEN ''LOTTERY''
			WHEN ProductName = ''Togel 4D'' THEN ''LOTTERY''
			WHEN ProductName = ''RNG Keno'' THEN ''LOTTERY''
			WHEN ProductName = ''Number Game'' THEN ''LOTTERY''
			WHEN ProductName = ''NG2'' THEN ''LOTTERY''
			WHEN ProductName = ''Sports Lottery'' THEN ''LOTTERY''				

			WHEN ProductName = ''Metric Gaming - Super Live'' THEN ''OTHERS''
			WHEN ProductName = ''Bet Builder'' THEN ''OTHERS''
			WHEN ProductName = ''Virtual Sports'' THEN ''OTHERS''
			WHEN ProductName = ''Colossus Bets'' THEN ''OTHERS''
			WHEN ProductName = ''Cash Out'' THEN ''OTHERS''
			WHEN ProductName = ''Virtual Sports 2'' THEN ''OTHERS''			
		ELSE ''OTHERS'' END

SELECT @msg2 = @msg2 + ''<br>[NS TO & M]''
-- generate string for TO & Margin
SELECT @msg2 = @msg2 + ''<br>'' + ProductCode + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -HouseWinlost*100/NULLIF(TurnOver,0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductCode = ''ALL''
ORDER BY TurnOver DESC

SELECT @msg2 = @msg2 + ''<br>-----<br>*LC: ''
		+ CASE 			
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END		
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''LC''

SELECT @msg2 = @msg2 + ''<br>'' + ProductCode + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -HouseWinlost*100/NULLIF(TurnOver,0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''LC''
ORDER BY TurnOver DESC

SELECT @msg2 = @msg2 + ''<br>-----<br>*RNG: ''
		+ CASE 			
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END		
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''RNG''
SELECT @msg2 = @msg2 + ''<br>'' + ProductCode + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -HouseWinlost*100/NULLIF(TurnOver,0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''RNG''
ORDER BY TurnOver DESC

SELECT @msg2 = @msg2 + ''<br>-----<br>*Lott/Ken: ''
		+ CASE 			
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END		
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''LOTTERY''
SELECT @msg2 = @msg2 + ''<br>'' + ProductCode + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -HouseWinlost*100/NULLIF(TurnOver,0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''LOTTERY''
ORDER BY TurnOver DESC

SELECT @msg2 = @msg2 + ''<br>-----<br>*OTHERS: ''
		+ CASE 			
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END		
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''OTHERS''
SELECT @msg2 = @msg2 + ''<br>'' + ProductCode + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -HouseWinlost*100/NULLIF(TurnOver,0)),0) as VARCHAR(10)) + ''%''	
FROM #tmpMarginNonSport
WHERE TurnOver > 0
	AND ProductGroup = ''OTHERS''
ORDER BY TurnOver DESC
-------------

DECLARE @msg_y_dailyperf VARCHAR(MAX) = ''''
DECLARE @msg_y_dailyperf2 VARCHAR(MAX) = ''''

DECLARE @WL_Y_breakdown as TABLE (S varchar(30), WL money, TurnOver money , MG MONEY, rn int)
INSERT INTO @WL_Y_breakdown(S, WL, TurnOver, MG, rn)
SELECT  S = CASE 
				WHEN Site IN (''789Y'') AND SB = 1 THEN ''T SB''
				WHEN Site IN (''789Y'') AND SB = 0 THEN ''T NS''
				WHEN Site IN (''ACCUT'') AND SB = 1 THEN ''UT SB''
				WHEN Site IN (''ACCUT'') AND SB = 0 THEN ''UT NS''
				WHEN Site IN (''ACCYEN789'') AND SB = 1 THEN ''Y789 SB''
				WHEN Site IN (''ACCYEN789'') AND SB = 0 THEN ''Y789 NS''
				WHEN Site IN (''ACCYEN889'') AND SB = 1 THEN ''Y889 SB''
				WHEN Site IN (''ACCYEN889'') AND SB = 0 THEN ''Y889 NS''
				WHEN Site IN (''Unassigned'') AND SB = 1 THEN ''Other SB''
				WHEN Site IN (''Unassigned'') AND SB = 0 THEN ''Other NS''
			ELSE Site END
		,WL = -SUM(ISNULL(HouseWinlost,0))  
		,TurnOver = SUM(ISNULL(TurnOver,0)) 
		,MG = CASE WHEN SUM (ISNULL(TurnOver,0)) = 0 THEN 0 ELSE -SUM(ISNULL(HouseWinlost,0))/SUM (ISNULL(TurnOver,0)) * 100 END
		,rn = CASE 
				WHEN Site IN (''789Y'') AND SB = 1 THEN 9
				WHEN Site IN (''789Y'') AND SB = 0 THEN 10
				WHEN Site IN (''ACCUT'') AND SB = 1 THEN 1
				WHEN Site IN (''ACCUT'') AND SB = 0 THEN 2
				WHEN Site IN (''ACCYEN789'') AND SB = 1 THEN 3
				WHEN Site IN (''ACCYEN789'') AND SB = 0 THEN 4
				WHEN Site IN (''ACCYEN889'') AND SB = 1 THEN 5
				WHEN Site IN (''ACCYEN889'') AND SB = 0 THEN 6
				WHEN Site IN (''Unassigned'') AND SB = 1 THEN 7
				WHEN Site IN (''Unassigned'') AND SB = 0 THEN 8
			ELSE 11 END	
FROM #tmpResetWinning
WHERE SITE IN (''789Y'') OR isDeposit IN (3)
GROUP BY CASE 
				WHEN Site IN (''789Y'') AND SB = 1 THEN ''T SB''
				WHEN Site IN (''789Y'') AND SB = 0 THEN ''T NS''
				WHEN Site IN (''ACCUT'') AND SB = 1 THEN ''UT SB''
				WHEN Site IN (''ACCUT'') AND SB = 0 THEN ''UT NS''
				WHEN Site IN (''ACCYEN789'') AND SB = 1 THEN ''Y789 SB''
				WHEN Site IN (''ACCYEN789'') AND SB = 0 THEN ''Y789 NS''
				WHEN Site IN (''ACCYEN889'') AND SB = 1 THEN ''Y889 SB''
				WHEN Site IN (''ACCYEN889'') AND SB = 0 THEN ''Y889 NS''
				WHEN Site IN (''Unassigned'') AND SB = 1 THEN ''Other SB''
				WHEN Site IN (''Unassigned'') AND SB = 0 THEN ''Other NS''
			ELSE Site END
		,CASE 
				WHEN Site IN (''789Y'') AND SB = 1 THEN 9
				WHEN Site IN (''789Y'') AND SB = 0 THEN 10
				WHEN Site IN (''ACCUT'') AND SB = 1 THEN 1
				WHEN Site IN (''ACCUT'') AND SB = 0 THEN 2
				WHEN Site IN (''ACCYEN789'') AND SB = 1 THEN 3
				WHEN Site IN (''ACCYEN789'') AND SB = 0 THEN 4
				WHEN Site IN (''ACCYEN889'') AND SB = 1 THEN 5
				WHEN Site IN (''ACCYEN889'') AND SB = 0 THEN 6
				WHEN Site IN (''Unassigned'') AND SB = 1 THEN 7
				WHEN Site IN (''Unassigned'') AND SB = 0 THEN 8
			ELSE 11 END	

SELECT @msg_y_dailyperf = @msg_y_dailyperf + ''<br>'' + S + '': ''
		--+ CASE WHEN ABS(WL) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),WL/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),WL/1000) as VARCHAR(10)) + ''k'' END 	
		+ CASE 
			WHEN ABS(ISNULL(WL,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(WL,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(WL,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(WL,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(WL,0)) END
		+ '' '' + CAST(CONVERT(DECIMAL(10,2), ISNULL(MG,0)) as VARCHAR(10)) + ''%''	
FROM @WL_Y_breakdown
ORDER BY rn

SET @msg_y_dailyperf = REPLACE(@msg_y_dailyperf, ''<br>T SB:'', ''<br><br>T SB:'')

CREATE TABLE #tmpMarginY (
	SportName VARCHAR(50), LiveIndicator BIT, IsSaba tinyint, TurnOver MONEY, Margin MONEY, HouseWinlost MONEY
)

INSERT INTO #tmpMarginY (SportName, LiveIndicator, IsSaba, TurnOver, Margin, HouseWinlost)
EXEC Acc_ResetWinning_MarginBySport_Y @Winlostdate = @wldate

SELECT @msg_y_dailyperf = @msg_y_dailyperf + ''<br>-------<br>[SB TO & M]''
-- generate string for TO & Margin
;WITH _S as (
	SELECT SportName = CASE WHEN SportName = ''All Sports'' THEN ''ALL''				
				WHEN SportName = ''Soccer'' AND Liveindicator = 1 AND IsSaba = 0 THEN ''R.Soc(L)''
				WHEN SportName = ''Soccer'' AND Liveindicator = 0 AND IsSaba = 0 THEN ''R.Soc(NL)''					
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN ''Saba.Soc''
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN ''Saba.PG''	-- Saba Soccer Pingoal
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN ''Real.Bas''
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN ''Saba.Bas''
				WHEN SportName = ''Tennis'' THEN ''Tenn''
				WHEN SportName = ''E-Sports'' THEN ''E-Spo''
				WHEN SportName = ''Cricket'' THEN ''Cricket''
				WHEN SportName = ''Other Sports'' THEN ''Others''
				WHEN SportName = ''Parlay'' THEN ''Parl''
			ELSE SportName END
		,rn = CASE WHEN SportName = ''All Sports'' THEN 1				
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 1 THEN 3
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 0 THEN 4					
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN 5
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN 6
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN 7
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN 8
				WHEN SportName = ''Tennis'' THEN 9
				WHEN SportName = ''E-Sports'' THEN 10
				WHEN SportName = ''Cricket'' THEN 11
				WHEN SportName = ''Other Sports'' THEN 12
				WHEN SportName = ''Parlay'' THEN 13
			ELSE 14 END	
		, VAL = CASE 
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMarginY
GROUP BY CASE WHEN SportName = ''All Sports'' THEN ''ALL''			
			WHEN SportName = ''Soccer'' AND Liveindicator = 1 AND IsSaba = 0 THEN ''R.Soc(L)''
			WHEN SportName = ''Soccer'' AND Liveindicator = 0 AND IsSaba = 0 THEN ''R.Soc(NL)''		
			WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN ''Saba.Soc''
			WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN ''Saba.PG''	-- Saba Soccer Pingoal
			WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN ''Real.Bas''
			WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN ''Saba.Bas''
			WHEN SportName = ''Tennis'' THEN ''Tenn''
			WHEN SportName = ''E-Sports'' THEN ''E-Spo''
			WHEN SportName = ''Cricket'' THEN ''Cricket''
			WHEN SportName = ''Other Sports'' THEN ''Others''
			WHEN SportName = ''Parlay'' THEN ''Parl''
		ELSE SportName END
		,CASE WHEN SportName = ''All Sports'' THEN 1			
			WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 1 THEN 3
			WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 0 THEN 4			
			WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN 5
			WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN 6
			WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN 7
			WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN 8
			WHEN SportName = ''Tennis'' THEN 9
			WHEN SportName = ''E-Sports'' THEN 10
			WHEN SportName = ''Cricket'' THEN 11
			WHEN SportName = ''Other Sports'' THEN 12
			WHEN SportName = ''Parlay'' THEN 13
		ELSE 14 END	

UNION ALL 
SELECT SportName = ''Real.Soc''
	,rn = 2
	,VAL = CASE 			
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMarginY
WHERE SportName = ''Soccer'' AND IsSaba = 0
)
SELECT @msg_y_dailyperf = @msg_y_dailyperf + ''<br>'' + SportName + '': '' + VAL
FROM _S
ORDER BY rn


-- non sports
CREATE TABLE #tmpMarginNonSportY (
	ProductName VARCHAR(50), TurnOver MONEY, Margin MONEY, HouseWinlost MONEY
)

INSERT INTO #tmpMarginNonSportY (ProductName, TurnOver, Margin, HouseWinlost)
EXEC Acc_ResetWinning_MarginByNonSport_Y @Winlostdate = @wldate

SELECT @msg_y_dailyperf2 = @msg_y_dailyperf2 + ''[NS TO & M]''
SELECT @msg_y_dailyperf2 = @msg_y_dailyperf2 + ''<br>'' + 
	CASE WHEN ProductName = ''All Non Sports'' THEN ''ALL'' 
			WHEN ProductName = ''Bet Builder'' THEN ''BetB''
			WHEN ProductName = ''Metric Gaming - Super Live'' THEN ''MetricG''
			WHEN ProductName = ''Number Game'' THEN ''NumG''
			WHEN ProductName = ''Virtual Sports'' THEN ''VirtSpo''
			WHEN ProductName = ''RNG Casino'' THEN ''1RNG''
			WHEN ProductName = ''RNG Keno'' THEN ''MKeno''
			WHEN ProductName = ''Colossus Bets'' THEN ''CB''
			WHEN ProductName = ''Allbet'' THEN ''AllB''
			WHEN ProductName = ''Macau Games'' THEN ''MacauG''
			WHEN ProductName = ''Fishing World'' THEN ''FishW''
			WHEN ProductName = ''Cash Out'' THEN ''CashO''
			WHEN ProductName = ''Virtual Sports 2'' THEN ''VirtSpo2''
			WHEN ProductName = ''Lottery'' THEN ''MLotte''
			--WHEN ProductName = ''Card Club'' THEN ''CardC''
			WHEN ProductName = ''Arcadia Gaming'' THEN ''ArcaGam''
			WHEN ProductName = ''PG Soft'' THEN ''PGSoft''
			WHEN ProductName = ''Virtual Games'' THEN ''VirtG''
			WHEN ProductName = ''Table Game'' THEN ''TableG''
			WHEN ProductName = ''Saba.club'' THEN ''SabaC''
			WHEN ProductName = ''Togel 4D'' THEN ''I4D''
			WHEN ProductName = ''PP'' THEN ''PragP''
			WHEN ProductName = ''SG'' THEN ''SpadeG''			
			WHEN ProductName = ''IBCBet Live Casino'' THEN ''IBCLC''
			WHEN ProductName = ''SA Gaming'' THEN ''SAG''
			WHEN ProductName = ''RNG War'' THEN ''RNGWar''
			WHEN ProductName = ''Gold Deluxe'' THEN ''GoldD''
			WHEN ProductName = ''AG Casino'' THEN ''AG''
			WHEN ProductName = ''Sports Lottery'' THEN ''SportsLott''	
			WHEN ProductName = ''PP Live Casino'' THEN ''PP LC''
			WHEN ProductName = ''AE Sexy'' THEN ''AESexy''
			WHEN ProductName = ''Habanero'' THEN ''Haban''
			WHEN ProductName = ''AdvantPlay'' THEN ''AdPlay''
			WHEN ProductName = ''AdvantPlay Mini'' THEN ''AdPlayMini''
	ELSE ProductName END + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(CONVERT(DECIMAL(10,2), -ISNULL(Margin,0)) as VARCHAR(10)) + ''%''		
FROM #tmpMarginNonSportY
WHERE TurnOver > 0
ORDER BY TurnOver DESC


-- Licensee WL
/*[TOTAL WL & M]
SB: 872k 2.39%
NS: 564k M: 2.12%
*/

---viet
-- For LICENSEEs
CREATE TABLE #tmpMarginLIC (SportName VARCHAR(50), LiveIndicator BIT, IsSaba Tinyint, TurnOver MONEY, Margin MONEY, HouseWinlost MONEY)
CREATE TABLE #tmpMarginNonSportLIC (ProductName VARCHAR(50), TurnOver MONEY, Margin MONEY, HouseWinlost MONEY)

INSERT INTO #tmpMarginLIC (SportName, LiveIndicator, IsSaba, TurnOver, Margin, HouseWinlost)
EXEC Acc_ResetWinning_MarginBySport_Lic @Winlostdate = @wldate, @BaseCurrency = ''CNY'' --base currency RMB

INSERT INTO #tmpMarginNonSportLIC (ProductName, TurnOver, Margin, HouseWinlost)
EXEC Acc_ResetWinning_MarginByNonSport_Lic @Winlostdate = @wldate, @BaseCurrency = ''CNY'' --base currency RMB

DELETE #tmpMarginLIC WHERE TurnOver IS NULL
DELETE #tmpMarginNonSportLIC WHERE TurnOver IS NULL

-- Licensee margin
DECLARE @msg_LIC_dailyperf VARCHAR(MAX) = ''''

-- LIC WL
SELECT @msg_LIC_dailyperf = @msg_LIC_dailyperf + ''[TOTAL WL(RMB) & M]''
SELECT @msg_LIC_dailyperf = @msg_LIC_dailyperf + ''<br>''
		+ ''SB: ''			
			+ CASE 
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) BETWEEN 0 AND 999999 THEN (CONVERT(VARCHAR(10), (CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), (CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), -ISNULL(SUM(HouseWinlost),0)) END
		+ ''  '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMarginLIC
WHERE SportName = ''All Sports''

SELECT @msg_LIC_dailyperf = @msg_LIC_dailyperf + ''<br>''
		+ ''NS: ''			
			+ CASE 
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) BETWEEN 0 AND 999999 THEN (CONVERT(VARCHAR(10), (CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(-ISNULL(SUM(HouseWinlost),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), (CAST(ROUND(-ISNULL(SUM(HouseWinlost),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), -ISNULL(SUM(HouseWinlost),0)) END
		+ ''  '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMarginNonSportLIC
WHERE ProductName = ''All Non Sports''

SELECT @msg_LIC_dailyperf = @msg_LIC_dailyperf + ''<br>-------<br>[SB TO(RMB) & M]''
;WITH _S as (
	SELECT SportName = CASE WHEN SportName = ''All Sports'' THEN ''ALL''				
				WHEN SportName = ''Soccer'' AND Liveindicator = 1 AND IsSaba = 0 THEN ''R.Soc(L)''
				WHEN SportName = ''Soccer'' AND Liveindicator = 0 AND IsSaba = 0 THEN ''R.Soc(NL)''					
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN ''Saba.Soc''
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN ''Saba.PG''	-- Saba Soccer Pingoal
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN ''Real.Bas''
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN ''Saba.Bas''
				WHEN SportName = ''Tennis'' THEN ''Tenn''
				WHEN SportName = ''E-Sports'' THEN ''E-Spo''
				WHEN SportName = ''Cricket'' THEN ''Cricket''
				WHEN SportName = ''Other Sports'' THEN ''Others''
				WHEN SportName = ''Parlay'' THEN ''Parl''
			ELSE SportName END
		,rn = CASE WHEN SportName = ''All Sports'' THEN 1				
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 1 THEN 3
				WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 0 THEN 4					
				WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN 5
				WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN 6
				WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN 7
				WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN 8
				WHEN SportName = ''Tennis'' THEN 9
				WHEN SportName = ''E-Sports'' THEN 10
				WHEN SportName = ''Cricket'' THEN 11
				WHEN SportName = ''Other Sports'' THEN 12
				WHEN SportName = ''Parlay'' THEN 13
			ELSE 14 END		
		, VAL = CASE 
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMarginLIC
GROUP BY CASE WHEN SportName = ''All Sports'' THEN ''ALL''			
			WHEN SportName = ''Soccer'' AND Liveindicator = 1 AND IsSaba = 0 THEN ''R.Soc(L)''
			WHEN SportName = ''Soccer'' AND Liveindicator = 0 AND IsSaba = 0 THEN ''R.Soc(NL)''		
			WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN ''Saba.Soc''
			WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN ''Saba.PG''	-- Saba Soccer Pingoal
			WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN ''Real.Bas''
			WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN ''Saba.Bas''
			WHEN SportName = ''Tennis'' THEN ''Tenn''
			WHEN SportName = ''E-Sports'' THEN ''E-Spo''
			WHEN SportName = ''Cricket'' THEN ''Cricket''
			WHEN SportName = ''Other Sports'' THEN ''Others''
			WHEN SportName = ''Parlay'' THEN ''Parl''
		ELSE SportName END
		,CASE WHEN SportName = ''All Sports'' THEN 1			
			WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 1 THEN 3
			WHEN SportName = ''Soccer'' AND IsSaba = 0 AND Liveindicator = 0 THEN 4			
			WHEN SportName = ''Soccer'' AND IsSaba = 1 THEN 5
			WHEN SportName = ''Soccer'' AND IsSaba = 2 THEN 6
			WHEN SportName = ''Basketball'' AND IsSaba = 0 THEN 7
			WHEN SportName = ''Basketball'' AND IsSaba = 1 THEN 8
			WHEN SportName = ''Tennis'' THEN 9
			WHEN SportName = ''E-Sports'' THEN 10
			WHEN SportName = ''Cricket'' THEN 11
			WHEN SportName = ''Other Sports'' THEN 12
			WHEN SportName = ''Parlay'' THEN 13
		ELSE 14 END		

UNION ALL 
SELECT SportName = ''Real.Soc''
	,rn = 2
	,VAL = CASE 			
			WHEN ABS(ISNULL(SUM(TurnOver),0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(SUM(TurnOver),0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(SUM(TurnOver),0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(SUM(TurnOver),0)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''
FROM #tmpMarginLIC
WHERE SportName = ''Soccer'' AND IsSaba = 0
)
SELECT @msg_LIC_dailyperf = @msg_LIC_dailyperf + ''<br>'' + SportName + '': '' + VAL
FROM _S
ORDER BY rn


-- non sports
SELECT @msg_LIC_dailyperf = @msg_LIC_dailyperf + ''<br>-------<br>[NS TO(RMB) & M]''
SELECT @msg_LIC_dailyperf = @msg_LIC_dailyperf + ''<br>'' + 
	CASE WHEN ProductName = ''All Non Sports'' THEN ''ALL'' 
			WHEN ProductName = ''Bet Builder'' THEN ''BetB''
			WHEN ProductName = ''Metric Gaming - Super Live'' THEN ''MetricG''
			WHEN ProductName = ''Number Game'' THEN ''NumG''
			WHEN ProductName = ''Virtual Sports'' THEN ''VirtSpo''
			WHEN ProductName = ''RNG Casino'' THEN ''1RNG''
			WHEN ProductName = ''RNG Keno'' THEN ''MKeno''
			WHEN ProductName = ''Colossus Bets'' THEN ''CB''
			WHEN ProductName = ''Allbet'' THEN ''AllB''
			WHEN ProductName = ''Macau Games'' THEN ''MacauG''
			WHEN ProductName = ''Fishing World'' THEN ''FishW''
			WHEN ProductName = ''Cash Out'' THEN ''CashO''
			WHEN ProductName = ''Virtual Sports 2'' THEN ''VirtSpo2''
			WHEN ProductName = ''Lottery'' THEN ''MLotte''
			--WHEN ProductName = ''Card Club'' THEN ''CardC''
			WHEN ProductName = ''Arcadia Gaming'' THEN ''ArcaGam''
			WHEN ProductName = ''PG Soft'' THEN ''PGSoft''
			WHEN ProductName = ''Virtual Games'' THEN ''VirtG''
			WHEN ProductName = ''Table Game'' THEN ''TableG''
			WHEN ProductName = ''Saba.club'' THEN ''SabaC''
			WHEN ProductName = ''Togel 4D'' THEN ''I4D''
			WHEN ProductName = ''PP'' THEN ''PragP''
			WHEN ProductName = ''SG'' THEN ''SpadeG''
			WHEN ProductName = ''IBCBet Live Casino'' THEN ''IBCLC''
			WHEN ProductName = ''SA Gaming'' THEN ''SAG''
			WHEN ProductName = ''RNG War'' THEN ''RNGWar''
			WHEN ProductName = ''Gold Deluxe'' THEN ''GoldD''
			WHEN ProductName = ''AG Casino'' THEN ''AG''
			WHEN ProductName = ''Sports Lottery'' THEN ''SportsLott''	
			WHEN ProductName = ''PP Live Casino'' THEN ''PP LC''
			WHEN ProductName = ''AE Sexy'' THEN ''AESexy''
			WHEN ProductName = ''Habanero'' THEN ''Haban''
			WHEN ProductName = ''AdvantPlay'' THEN ''AdPlay''
			WHEN ProductName = ''AdvantPlay Mini'' THEN ''AdPlayMini''
	ELSE ProductName END + '': ''
		--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END 		
		+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
		+ '' '' + CAST(CONVERT(DECIMAL(10,2), -ISNULL(Margin,0)) as VARCHAR(10)) + ''%''		
FROM #tmpMarginNonSportLIC
WHERE TurnOver > 0
ORDER BY TurnOver DESC

------------------------
IF (@dayOffset = -1)
BEGIN
	DECLARE @msg_seal_api VARCHAR(max) = ''''
	SELECT @msg_seal_api = ''T: ''		
			--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END
			+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
			+ '' M: '' + CAST(CONVERT(DECIMAL(10,2), -ISNULL(Margin,0)) as VARCHAR(10)) + ''%''
	FROM #tmpMarginNonSport
	WHERE ProductName = ''All Non Sports''

	DECLARE @Temp_taione_ns AS TABLE(ProductName varchar(50), Turnover Money, Margin Money, HouseWinlost Money)
	INSERT INTO @Temp_taione_ns (ProductName, Turnover, Margin, HouseWinlost)
	SELECT SportName, Turnover, Margin, HouseWinlost
	FROM #tmpMargin
	WHERE SportName = ''E-Sports''
	UNION ALL
	SELECT ProductName, Turnover, Margin, HouseWinlost
	FROM #tmpMarginNonSport
	WHERE ProductName IN (''RNG Casino'', ''Virtual Games'', ''Number Game'')
	---
	DECLARE @msg_taione_ns VARCHAR(max) = ''''
	INSERT INTO @Temp_taione_ns (ProductName, Turnover, Margin, HouseWinlost)
	SELECT ''All'', SUM(Turnover), ISNULL(SUM(HouseWinlost)*100/NULLIF(SUM(Turnover),0),0), SUM(HouseWinlost)
	FROM @Temp_taione_ns

	SELECT @msg_taione_ns = ''T: ''		
			--+ CASE WHEN ABS(TurnOver) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),TurnOver/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),TurnOver/1000) as VARCHAR(10)) + ''k'' END
			+ CASE 
			WHEN ABS(ISNULL(TurnOver,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(TurnOver,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnOver,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(TurnOver,0)) END
			+ '' M: '' + CAST(CONVERT(DECIMAL(10,2), -ISNULL(Margin,0)) as VARCHAR(10)) + ''%''
	FROM @Temp_taione_ns
	WHERE ProductName = ''All''
	---
	DECLARE @msg_infinity_member VARCHAR(max) = ''''
	DECLARE @TO_infinity_member MONEY, @Margin_infinity_member MONEY
	SELECT @TO_infinity_member = SUM(TurnOver), @Margin_infinity_member = ISNULL(SUM(HouseWinlost)*100/NULLIF(SUM(Turnover),0),0)
	FROM #tmpResetWinning
	WHERE isDeposit = 0
		AND SB = 1
		AND Site NOT IN (''CN88'')

	SELECT @msg_infinity_member = ''T: ''		
			--+ CASE WHEN ABS(@TO_infinity_member) > 1000000 THEN CAST(CONVERT(DECIMAL(10,1),@TO_infinity_member/1000000) as VARCHAR(10)) + ''m'' ELSE CAST(CONVERT(DECIMAL(10,0),@TO_infinity_member/1000) as VARCHAR(10)) + ''k'' END
			+ CASE 
			WHEN ABS(ISNULL(@TO_infinity_member,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(@TO_infinity_member,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(ISNULL(@TO_infinity_member,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(@TO_infinity_member,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), ISNULL(@TO_infinity_member,0)) END
			+ '' M: '' + CAST(CONVERT(DECIMAL(10,2), -ISNULL(@Margin_infinity_member,0)) as VARCHAR(10)) + ''%''		

	EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''SEAL.API'', @Msg = @msg_seal_api, @Title = ''This number is for KPI reference only'' -- SEAL.API group
	EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''TAIONE.NS'', @Msg = @msg_taione_ns, @Title = ''This number is for KPI reference only'' -- TAIONE.NS group	
	EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''Infinity.Member'', @Msg = @msg_infinity_member, @Title = ''This number is for KPI reference only'' -- Infinity.Member group	
END

--- TOP 30 low margin Licensees
/*
	1. Get the list of top 50 Licensees with highest turnover of the day
	2. Sort the list by lowest margin.
	3. Get the top 30 licensees
	4. Order by TO
*/
CREATE TABLE #tmpTopLicenseeMargin (
	Licensee VARCHAR(50), MarginAllSport DECIMAL(19,4), MarginSoccer DECIMAL(19,4), MarginBasketball DECIMAL(19,4), MarginEsport DECIMAL(19,4), MarginTennis DECIMAL(19,4), MarginParlay DECIMAL(19,4), MarginSabaSoccer DECIMAL(19,4), MarginSabaBasketball DECIMAL(19,4), MarginOthersport DECIMAL(19,4), TurnoverAllSport DECIMAL(19,4)
)

INSERT INTO #tmpTopLicenseeMargin (Licensee, MarginAllSport, MarginSoccer, MarginBasketball, MarginEsport, MarginTennis, MarginParlay, MarginSabaSoccer, MarginSabaBasketball, MarginOthersport, TurnoverAllSport)
EXEC Acc_ResetWinning_TopLicenseeMargin @Winlostdate = @wldate

DECLARE @Temp_Top30Final AS TABLE(Licensee VARCHAR(50), MarginAllSport DECIMAL(19,4), TurnoverAllSport DECIMAL(19,4))
INSERT INTO @Temp_Top30Final(Licensee, MarginAllSport, TurnoverAllSport)
SELECT TOP 30 Licensee, MarginAllSport, TurnoverAllSport
FROM #tmpTopLicenseeMargin
WHERE Licensee <> ''Other Licensees''
ORDER BY MarginAllSport


DECLARE @msgLicMargin VARCHAR(max) = ''[LIC TO(MYR) Margin]''
SELECT @msgLicMargin = @msgLicMargin + ''<br>'' + Licensee 
	+ '' '' + CASE 
				WHEN ABS(ISNULL(TurnoverAllSport,0)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnoverAllSport,0) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
				WHEN ABS(ISNULL(TurnoverAllSport,0)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(ISNULL(TurnoverAllSport,0) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
				ELSE CONVERT (VARCHAR(10), ISNULL(TurnoverAllSport,0)) END
	+ '' '' + CAST(CONVERT(DECIMAL(10,2), ISNULL(MarginAllSport,0)*100) as VARCHAR(10)) + ''%''

FROM @Temp_Top30Final
ORDER BY TurnoverAllSport DESC

DROP TABLE #tmpResetWinning
DROP TABLE #tmpMargin
DROP TABLE #tmpMarginPH
DROP TABLE #tmpMarginNonSport
DROP TABLE #tmpMarginY
DROP TABLE #tmpMarginNonSportY
DROP TABLE #tmpTopLicenseeMargin
DROP TABLE #tmpMarginLIC
DROP TABLE #tmpMarginNonSportLIC
---

DECLARE @letstalkNewLine varchar(1000) = ''
''
SET @msg = replace(@msg, ''<br>'', @letstalkNewLine)
SET @msg2 = replace(@msg2, ''<br>'', @letstalkNewLine)
SET @msg_y_dailyperf = replace(@msg_y_dailyperf, ''<br>'', @letstalkNewLine)
SET @msg_y_dailyperf2 = replace(@msg_y_dailyperf2, ''<br>'', @letstalkNewLine)
SET @msgLicMargin = replace(@msgLicMargin, ''<br>'', @letstalkNewLine)
SET @msg_LIC_dailyperf = replace(@msg_LIC_dailyperf, ''<br>'', @letstalkNewLine)

--PRINT @msg_seal_api
--PRINT @msg_taione_ns
--PRINT @msg_infinity_member
--PRINT  @msg
--PRINT  @msg2
--PRINT @msg_y_dailyperf
--PRINT @msg_y_dailyperf2
--PRINT @msgLicMargin
--PRINT @msg_LIC_dailyperf

-- send letstalk''s message
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''vietgroup'', @Msg = @msg, @Title = @title -- main group
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''vietgroup.UAT'', @Msg = @msg, @Title = @title -- UAT group --(Σ PERF)
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''vietgroup'', @Msg = @msg2, @Title = @title -- main group
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''vietgroup.UAT'', @Msg = @msg2, @Title = @title -- UAT group (Σ PERF)
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''NotiGroup2'', @Msg = @msg_y_dailyperf, @Title = @title -- Y-DailyPerformance --(Y PERF)
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''NotiGroup2'', @Msg = @msg_y_dailyperf2, @Title = @title -- Y-DailyPerformance --(Y PERF)
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''vietgroup'', @Msg = @msgLicMargin, @Title = @title -- main group
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''daily-house-wl'', @Msg = @msgLicMargin, @Title = @Title -- Licensee Performance
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''daily-house-wl'', @Msg = @msg_LIC_dailyperf, @Title = @Title -- Licensee Performance
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''NotiGroup4'', @Msg = @msgLicMargin, @Title = @Title -- L-DailyPerformance group --(L PERF)
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''NotiGroup4'', @Msg = @msg_LIC_dailyperf, @Title = @Title -- L-DailyPerformance group --(L PERF)', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 2 hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200302, 
		@active_end_date=99991231, 
		@active_start_time=1400, 
		@active_end_time=235959, 
		@schedule_uid=N'84b14d01-0751-485b-967a-4424e55f8581'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [vndba: temp SC perf report test]    Script Date: 12/24/2021 6:26:23 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:23 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'vndba: temp SC perf report test', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'Viet', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [run script]    Script Date: 12/24/2021 6:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'run script', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @dayOffset int = CASE WHEN DATEPART (HOUR, CURRENT_TIMESTAMP) >= 1 THEN 0 ELSE -1 END
DECLARE @wldate smalldatetime = DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), @dayOffset)
DECLARE @msg VARCHAR(max) = ''''
DECLARE @title varchar(22)

IF (@dayOffset = 0)
BEGIN
	SET @title = CONVERT(VARCHAR(5), @wldate, 1) + '' ''
	+ CASE 
		WHEN DATEPART(hour, CURRENT_TIMESTAMP) > 12 THEN CAST(DATEPART(hour, CURRENT_TIMESTAMP)-12 as varchar) + '':'' + CAST(DATEPART(minute, CURRENT_TIMESTAMP) as varchar) + ''pm''
		WHEN DATEPART(hour, CURRENT_TIMESTAMP) = 12 THEN CAST(DATEPART(hour, CURRENT_TIMESTAMP) as varchar) + '':'' + CAST(DATEPART(minute, CURRENT_TIMESTAMP) as varchar) + ''pm''
		ELSE CAST(DATEPART(hour, CURRENT_TIMESTAMP) as varchar) + '':'' + CAST(DATEPART(minute, CURRENT_TIMESTAMP) as varchar) + ''am'' END
	+'' gmt-4''	
END
ELSE
BEGIN
	SET @title = CONVERT(VARCHAR(10), @wldate, 101)
END

DECLARE @MinTransID_RNG BIGINT,  @MaxTransID_RNG BIGINT

SELECT  @MinTransID_RNG = MIN (TransID) , @MaxTransID_RNG = MAX(TransID) 
FROM	dbo.BettransRNG WITH (NOLOCK)
WHERE	winlostdate = @wldate

CREATE TABLE #tmpData (
	bettype smallint, Site VARCHAR(10), TurnOver	MONEY, HouseWinlost MONEY
)

INSERT INTO #tmpData (bettype, Site, TurnOver, HouseWinlost)
SELECT  CASE WHEN gameID BETWEEN 1622 AND 1630 OR gameID BETWEEN 3811 AND 3818 THEN 1622 ELSE gameid END as bettype,
		CASE WHEN b.currency IN (16, 35, 64) AND betfrom IN (''+'', ''='', ''<'', ''>'', ''!'', ''~'') THEN ''SM1'' --YEN, $US, UT
			WHEN b.currency IN (16, 35, 64) THEN ''SC1'' --YEN, $US, UT
			WHEN b.currency IN (51) THEN ''SC2'' -- INH
		ELSE ''SC3'' END as ''Site'', -- other currencies
				---Base currency
				SUM (   CASE WHEN b.StatusID = 111 THEN 0 ELSE ABS(Stake) END
						* (1 - b.tpositiontaking - ISNULL(CAST(b.epositiontaking AS DECIMAL(9, 8)), 0)) 
						* CASE
							  WHEN virtualrate > actualrate
							  THEN virtualrate
							  ELSE actualrate
							END
					)	 AS TurnOver,					
					
				SUM(
						(CASE
							WHEN b.gameId IN(2198, 2398, 2998, 4297)
								THEN b.ContributionRate * b.BetStake + awinlost + mwinlost + swinlost + scomm 
							WHEN b.GameId IN (2199,2399,2999,4298,4299,4300)	THEN 0 /*Progressive Jackpot, PP Promotion Prize, PP Tournament Prize*/
							ELSE winlost - actual_stake + awinlost + mwinlost + swinlost + scomm 
							END) * actualrate
					)  - SUM(			(CASE
                                    WHEN tpositiontaking = 1
                                    THEN 0
                                    WHEN b.GameId IN (2199,2399,2999,4298,4299,4300)	THEN 0 /*Progressive Jackpot, PP Promotion Prize, PP Tournament Prize*/
                                    WHEN b.gameId IN(2198, 2398, 2998, 4297)
                                    THEN ContributionRate * BetStake + 1.0 * scomm / (1 - tpositiontaking) --Jackpot Contribution
                                    ELSE winlost - actual_stake + 1.0 * scomm / (1 - tpositiontaking)
                                END) * ISNULL(CAST(b.epositiontaking AS DECIMAL(9, 8)), 0) * actualrate
					) AS HouseWinlost
		FROM dbo.bettransRNG b WITH (NOLOCK, index = PK_bettransRnG) 
			INNER JOIN dbo.bettype s WITH(NOLOCK) on b.gameid = s.typeid
		WHERE b.Winlostdate = @wldate
			AND b.statusid IN (111, 112, 113)
			AND vendorid IN (42,66)
			AND b.currency <> 20
			AND b.transID BETWEEN @MinTransID_RNG AND @MaxTransID_RNG		
		GROUP BY CASE WHEN gameID BETWEEN 1622 AND 1630 OR gameID BETWEEN 3811 AND 3818 THEN 1622 ELSE gameid END,
				CASE WHEN b.currency IN (16, 35, 64) AND betfrom IN (''+'', ''='', ''<'', ''>'', ''!'', ''~'') THEN ''SM1'' --YEN, $US, UT
					WHEN b.currency IN (16, 35, 64) THEN ''SC1'' --YEN, $US, UT
					WHEN b.currency IN (51) THEN ''SC2'' -- INH
				ELSE ''SC3'' END -- other currencies
		ORDER BY 2, 1

SELECT @msg = @msg + ''[SC TO & M]''

SELECT @msg = @msg + ''<br>'' + Site + '': ''
	+ CASE 
			WHEN ABS(SUM(TurnOver)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(SUM(TurnOver)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), SUM(TurnOver)) END
		+ '' '' + CAST(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/SUM(TurnOver)) as VARCHAR(10)) + ''%''
FROM #tmpData 
GROUP BY Site
ORDER BY Site

SELECT @msg = @msg + ''<br>ALL: ''
	+ CASE 
			WHEN ABS(SUM(TurnOver)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(SUM(TurnOver)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), SUM(TurnOver)) END
		+ '' '' + CAST(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/SUM(TurnOver)) as VARCHAR(10)) + ''%''
FROM #tmpData

SELECT @msg = @msg + ''<br><br>ALL WL: ''
	+ CASE 
			WHEN ABS(-SUM(HouseWinlost)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-SUM(HouseWinlost) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(-SUM(HouseWinlost)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-SUM(HouseWinlost) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), -SUM(HouseWinlost)) END	
FROM #tmpData

SELECT @msg = @msg + ''<br><br>-------''


SELECT @msg = @msg + ''<br>''
		+ CASE b.typenamee 
			WHEN ''Se Die'' THEN ''SeDie''
			WHEN ''VIP Se Die'' THEN ''VIP SeDie''
			WHEN ''Mini Se Die'' THEN ''Mini SeDie''
			WHEN ''Special Se Die'' THEN ''Spec SeDie''
			WHEN ''Keno Pro Max'' THEN ''ProM''
			WHEN ''Big Small'' THEN ''BigS''
			WHEN ''Turbo Big Small'' THEN ''Turb BigS''
			WHEN ''Fish Prawn Crab'' THEN ''FishPC''
			WHEN ''VIP Fish Prawn Crab'' THEN ''VIP FishPC''
			WHEN ''Dragon Tiger'' THEN ''DragonT''
			WHEN ''Keno Pro Viet'' THEN ''ProV''
			WHEN ''Odd Even'' THEN ''OddE''
			WHEN ''Turbo Odd Even'' THEN ''Turb OddE''
			WHEN ''Saba.club Lottery'' THEN ''Lottery''
		ELSE LEFT(b.typenamee,10) END
		+ '': ''		
		+ CASE 
			WHEN ABS(SUM(TurnOver)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(SUM(TurnOver)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), SUM(TurnOver)) END
		+ '' '' + CAST(ISNULL(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/NULLIF(SUM(TurnOver),0)),0) as VARCHAR(10)) + ''%''		
FROM #tmpData d
	inner join bettype b with(nolock) on d.bettype = b.typeid
GROUP BY CASE b.typenamee 
			WHEN ''Se Die'' THEN ''SeDie''
			WHEN ''VIP Se Die'' THEN ''VIP SeDie''
			WHEN ''Mini Se Die'' THEN ''Mini SeDie''
			WHEN ''Special Se Die'' THEN ''Spec SeDie''
			WHEN ''Keno Pro Max'' THEN ''ProM''
			WHEN ''Big Small'' THEN ''BigS''
			WHEN ''Turbo Big Small'' THEN ''Turb BigS''
			WHEN ''Fish Prawn Crab'' THEN ''FishPC''
			WHEN ''VIP Fish Prawn Crab'' THEN ''VIP FishPC''
			WHEN ''Dragon Tiger'' THEN ''DragonT''
			WHEN ''Keno Pro Viet'' THEN ''ProV''
			WHEN ''Odd Even'' THEN ''OddE''
			WHEN ''Turbo Odd Even'' THEN ''Turb OddE''
			WHEN ''Saba.club Lottery'' THEN ''Lottery''
		ELSE LEFT(b.typenamee,10) END
ORDER BY SUM(TurnOver) DESC

---- hourly performance
CREATE TABLE #tmpHourlyPerformance (
	HH tinyint, TurnOver MONEY, HouseWinlost MONEY, betSize MONEY
)

INSERT INTO #tmpHourlyPerformance(HH, Turnover, HouseWinlost, betSize)
SELECT  DATEPART(HOUR, DATEADD(HOUR, -4, transdate3rd)), --settle time
		---Base currency
		SUM (   CASE WHEN b.StatusID = 111 THEN 0 ELSE ABS(Stake) END
				* (1 - b.tpositiontaking - ISNULL(CAST(b.epositiontaking AS DECIMAL(9, 8)), 0)) 
				* CASE
						WHEN virtualrate > actualrate
						THEN virtualrate
						ELSE actualrate
					END
			)	 AS TurnOver,					
					
		SUM(
				(CASE
					WHEN b.gameId IN(2198, 2398, 2998, 4297)
						THEN b.ContributionRate * b.BetStake + awinlost + mwinlost + swinlost + scomm 
					WHEN b.GameId IN (2199,2399,2999,4298,4299,4300)	THEN 0 /*Progressive Jackpot, PP Promotion Prize, PP Tournament Prize*/
					ELSE winlost - actual_stake + awinlost + mwinlost + swinlost + scomm 
					END) * actualrate
			)  - SUM(			(CASE
                            WHEN tpositiontaking = 1
                            THEN 0
                            WHEN b.GameId IN (2199,2399,2999,4298,4299,4300)	THEN 0 /*Progressive Jackpot, PP Promotion Prize, PP Tournament Prize*/
                            WHEN b.gameId IN(2198, 2398, 2998, 4297)
                            THEN ContributionRate * BetStake + 1.0 * scomm / (1 - tpositiontaking) --Jackpot Contribution
                            ELSE winlost - actual_stake + 1.0 * scomm / (1 - tpositiontaking)
                        END) * ISNULL(CAST(b.epositiontaking AS DECIMAL(9, 8)), 0) * actualrate
			) AS HouseWinlost,
		SUM(stake*actualrate)/COUNT(transid) as betsize
FROM dbo.bettransRNG b WITH (NOLOCK, index = PK_bettransRnG) 
	INNER JOIN dbo.bettype s WITH(NOLOCK) on b.gameid = s.typeid
WHERE b.Winlostdate = @wldate
	AND b.statusid IN (111, 112, 113)
	AND vendorid IN (42,66)
	AND b.currency <> 20
	AND b.transID BETWEEN @MinTransID_RNG AND @MaxTransID_RNG		
GROUP BY DATEPART(HOUR, DATEADD(HOUR, -4, transdate3rd))

IF @dayOffset = 0 DELETE #tmpHourlyPerformance WHERE HH = DATEPART(HOUR, CURRENT_TIMESTAMP)

DECLARE @msgHourlyPerf VARCHAR(max) = ''''
DECLARE @TitleHourlyPerf VARCHAR(30) = ''''

SELECT @TitleHourlyPerf = 
	CASE 
			WHEN ABS(SUM(TurnOver)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(SUM(TurnOver)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(TurnOver) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), SUM(TurnOver)) END
	+ '' '' + CASE 
			WHEN ABS(SUM(-HouseWinlost)) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(-HouseWinlost) / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(SUM(-HouseWinlost)) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(SUM(-HouseWinlost) / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), SUM(-HouseWinlost)) END
	+ '' '' + CAST(CONVERT(DECIMAL(10,2), -SUM(HouseWinlost)*100/SUM(TurnOver)) as VARCHAR(10)) + ''%''
FROM #tmpHourlyPerformance

SELECT @msgHourlyPerf = @msgHourlyPerf + CASE @msgHourlyPerf WHEN '''' THEN '''' ELSE ''<br>'' END
	+ CASE 
			WHEN HH+1 < 12 THEN RIGHT(''0'' + CONVERT(VARCHAR(2), HH+1),2) + ''am''
			WHEN HH+1 = 12 THEN ''12pm''
			WHEN HH+1 = 24 THEN ''12am''
		ELSE RIGHT(''0'' + CONVERT(VARCHAR(2),HH+1-12), 2) + ''pm'' END
	+ '': ''
	+ CASE 
			WHEN ABS(TurnOver) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(TurnOver / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
			WHEN ABS(TurnOver) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(TurnOver / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
			ELSE CONVERT (VARCHAR(10), TurnOver) END
	+ '' '' + parsename(CONVERT(VARCHAR, convert(MONEY,ISNULL(betsize, 0)), 1), 2)
	+ '' '' + CASE 
		WHEN ABS(HouseWinlost) BETWEEN 0 AND 999999 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-HouseWinlost / 1000.0, 0) AS NUMERIC(4, 0)) )) ) + ''k''
		WHEN ABS(HouseWinlost) >= 1000000 THEN ( CONVERT (VARCHAR(10), ( CAST(ROUND(-HouseWinlost / 1000000.0, 2) AS NUMERIC(6, 2)) )) ) + ''m''
		ELSE CONVERT (VARCHAR(10), -HouseWinlost) END		
FROM #tmpHourlyPerformance 
ORDER BY HH DESC

DROP TABLE #tmpData
DROP TABLE #tmpHourlyPerformance

--PRINT @msg
DECLARE @letstalkNewLine varchar(1000) = ''
''
SET @msg = replace(@msg, ''<br>'', @letstalkNewLine)
SET @msgHourlyPerf = replace(@msgHourlyPerf, ''<br>'', @letstalkNewLine)

--PRINT @msg
--PRINT @msgHourlyPerf

EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''NotiGroup5'', @Msg = @msg, @Title = @title -- SC performance
EXECUTE	DBSPARE.NotificationDB.dbo.Letstalk_SendMessage @To = ''NotiGroup6'', @Msg = @msgHourlyPerf, @Title = @TitleHourlyPerf -- SC Hourly Perf
', 
		@database_name=N'bodb02', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201123, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'5e3b6b1e-968f-47dc-9c43-1dcd41f5f0fb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [vndba_monitor_whoisactive]    Script Date: 12/24/2021 6:26:24 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:24 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'vndba_monitor_whoisactive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'author: Lukas
task: monitor & capture plan of who is active', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [call who is active]    Script Date: 12/24/2021 6:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'call who is active', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
----https://www.brentozar.com/responder/log-sp_whoisactive-to-a-table/

SET NOCOUNT ON;

DECLARE @retention INT = 7,
        @destination_table VARCHAR(500) = ''WhoIsActive'',
        @destination_database sysname = ''MonDB'',
        @schema VARCHAR(MAX),
        @SQL NVARCHAR(4000),
        @parameters NVARCHAR(500),
        @exists BIT;

SET @destination_table = @destination_database + ''.dbo.'' + @destination_table;

--create the logging table
IF OBJECT_ID(@destination_table) IS NULL
    BEGIN;
        EXEC dbo.vndba_sp_WhoIsActive @get_transaction_info = 1,
                                @get_outer_command = 1,
                                @get_plans = 1,
                                @return_schema = 1,
                                @schema = @schema OUTPUT;
        SET @schema = REPLACE(@schema, ''<table_name>'', @destination_table);
        EXEC ( @schema );
    END;

--create index on collection_time
SET @SQL
    = ''USE '' + QUOTENAME(@destination_database)
      + ''; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''''cx_collection_time'''') SET @exists = 0'';
SET @parameters = N''@destination_table varchar(500), @exists bit OUTPUT'';
EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;

IF @exists = 0
    BEGIN;
        SET @SQL = ''CREATE CLUSTERED INDEX cx_collection_time ON '' + @destination_table + ''(collection_time ASC)'';
        EXEC ( @SQL );
    END;

--collect activity into logging table
EXEC dbo.vndba_sp_WhoIsActive @get_transaction_info = 1,
                        @get_outer_command = 1,
                        @get_plans = 1,
                        @destination_table = @destination_table;

--purge older data
SET @SQL
    = ''DELETE FROM '' + @destination_table + '' WHERE collection_time < DATEADD(day, -'' + CAST(@retention AS VARCHAR(10))
      + '', GETDATE());'';
EXEC ( @SQL );

go


', 
		@database_name=N'MonDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N's1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20191020, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'f34f5bb1-cad4-48ef-9582-0fba04add9e1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [zzzzLukasJob_test]    Script Date: 12/24/2021 6:26:24 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/24/2021 6:26:24 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'zzzzLukasJob_test', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [st1]    Script Date: 12/24/2021 6:26:24 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'st1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @i int


', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



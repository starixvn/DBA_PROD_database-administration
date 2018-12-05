/*
	Task: Insert job step copy data for DB052.bodb_Summary.sum_winloss_old (Setup Alpha HA on DB052)
	Run at DBTRANS
*/


USE [msdb]
GO
/****** Object:  Step [archive events]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=18
GO
USE [msdb]
GO
/****** Object:  Step [List 7 days for FRIDAY routine]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=17
GO
USE [msdb]
GO
/****** Object:  Step [Loop for Archive_Bettrans14]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=16
GO
USE [msdb]
GO
/****** Object:  Step [Archive_Bettrans14 to DB06]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=15
GO
USE [msdb]
GO
/****** Object:  Step [Archive_BetLucky3Result]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=14
GO
USE [msdb]
GO
/****** Object:  Step [Archive_bettrans_staging_NG2]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=13
GO
USE [msdb]
GO
/****** Object:  Step [Archive_settlementNG2_messages]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=12
GO
USE [msdb]
GO
/****** Object:  Step [Archive_Bettransm14 to DB06]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=11
GO
USE [msdb]
GO
/****** Object:  Step [Archive_BettransG14 to DB06]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=10
GO
USE [msdb]
GO
/****** Object:  Step [Archive_TransLog14 to DB06]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=9
GO
USE [msdb]
GO
/****** Object:  Step [Archive_BettransRNG to DB06]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=8
GO
USE [msdb]
GO
/****** Object:  Step [Archive_BettransLC to DB06]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=7
GO
USE [msdb]
GO
/****** Object:  Step [Archvie_Transfer to DB06]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=6
GO
USE [msdb]
GO
/****** Object:  Step [Archive_Statement to DB06 (BAL/Transfer)]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=5
GO
USE [msdb]
GO
/****** Object:  Step [Archive_Statement to DB06 (Bet/Pos/Com)]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=4
GO
USE [msdb]
GO
/****** Object:  Step [Archive_Sum_WinLoss to DB053]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=3
GO
USE [msdb]
GO
/****** Object:  Step [Archive_Sum_WinLoss to DB054]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=2
GO
USE [msdb]
GO
/****** Object:  Step [List 7 days to archive]    Script Date: 12/03/2018 05:30:11 ******/
EXEC msdb.dbo.sp_delete_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_id=1
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'List 7 days to archive', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE FROM dbo.Task_ArchiveDate

INSERT INTO dbo.Task_ArchiveDate
SELECT DISTINCT TOP 7 winlostdate
FROM dbo.bettrans14 (nolock)
ORDER BY winlostdate

EXEC bodb02.dbo.Task_Archive_SetState @State = ''Prepare''
', 
		@database_name=N'bodb02', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_Sum_WinLoss to DB054', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Sum_Winloss-DB054.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_Sum_WinLoss to DB053', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Sum_Winloss-DB053.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_Sum_WinLoss to DB052', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Sum_Winloss-DB052.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_Statement to DB06 (Bet/Pos/Com)', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Statement_BetPosCom-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_Statement to DB06 (BAL/Transfer)', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Statement_BalTransfer-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archvie_Transfer to DB06', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Transfer-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_BettransLC to DB06', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_BettransLC-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_BettransRNG to DB06', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_BettransRnG-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_TransLog14 to DB06', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Translog-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_BettransG14 to DB06', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_BettransG-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_Bettransm14 to DB06', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_Bettransm-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_settlementNG2_messages', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_SettlementNG2_Message-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_bettrans_staging_NG2', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_bettrans_staging-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_BetLucky3Result', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/FILE "H:\ThursdayRoutine_SSIS_Packages\DBTRANS-Archive_BetLucky3Result-DB06.dtsx" /DECRYPT r4g95x /CHECKPOINTING OFF /REPORTING E', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Archive_Bettrans14 to DB06', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

EXEC bodb02.dbo.Task_Archive_SelectBettrans14_Init
EXEC bodb02.dbo.Task_Archive_SetState @State = ''Ready''
', 
		@database_name=N'bodb02', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'Loop for Archive_Bettrans14', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON

WHILE (SELECT VValue FROM bodb02.dbo.SystemSettings WITH (NOLOCK) WHERE VName = ''Task_Archive_State'') <> ''Done''
BEGIN
   -- delay 10 seconds before next check
   WAITFOR DELAY ''000:00:10.000''
END

PRINT ''State Reported as Done''


', 
		@database_name=N'bodb02', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'List 7 days for FRIDAY routine', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE FROM dbo.Task_ArchiveDate

INSERT INTO dbo.Task_ArchiveDate
SELECT DISTINCT TOP 7 winlostdate
FROM dbo.bettrans14 (nolock)
ORDER BY winlostdate', 
		@database_name=N'bodb02', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'3070839a-0fb9-425d-a9e1-da8a134ad047', @step_name=N'archive events', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @archiveDate TABLE (rid int PRIMARY KEY IDENTITY(1,1), winlostdate smalldatetime)
INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate FROM dbo.task_archivedate
ORDER BY 1

Declare @wldate smalldatetime

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 1   EXEC DB02.bodb02.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = ''copy''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 2   EXEC DB02.bodb02.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = ''copy''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 3   EXEC DB02.bodb02.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = ''copy''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 4   EXEC DB02.bodb02.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = ''copy''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 5   EXEC DB02.bodb02.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = ''copy''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 6   EXEC DB02.bodb02.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = ''copy''
SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 7   EXEC DB02.bodb02.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = ''copy''
', 
		@database_name=N'bodb02', 
		@flags=0
GO

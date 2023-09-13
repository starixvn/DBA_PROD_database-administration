/*
	Created: 20230912@Sol
	Task: sync job status
	DB: 10.40.40.33,16401-msdb
*/

GO

EXEC msdb.dbo.sp_update_job @job_name = N'[FPS] Backup Databases', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA - Archive Subscriber Transactions', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Monitor Job Fail', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Send SQL Service Restart Alert Mail', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA: Check missing backup file', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA: Database BackupHistory Cleanup', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA: Update stats', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Deadlock_Monitor', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'dba_deletedata', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_FPS_BODB_TRANS_DeleteOldTicket', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_MonDB_Reorg', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Reorg_Index', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'FPSMS - Associated Account Monitoring', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'Job to collect the space-used of each FPS database', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'Job to collect the space-used of each FPS database - DBFRAUD', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'syspolicy_purge_history', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = N'Task_Sync_Bettrans_Staging', @enabled = 1;

GO
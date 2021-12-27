select @@SERVERNAME
/*
	Task - Upgrade SQL Server DB06 to 2019
		+ disable agent jobs
	Run on DB06C2\DB06
*/

/*
USE msdb
GO
-- 1.Check Job State (Disabled=8, Enabled=20)
SELECT CASE enabled WHEN 0 THEN 'Disabled' ELSE 'Enabled' END
  ,COUNT(enabled) [Enabled]
FROM msdb.dbo.sysjobs
WHERE category_id <> 6
GROUP BY enabled
GO

(No column name)	Enabled
Disabled	36
Enabled	50

-- 2.Enable Job (Exclude log shipping job category_id=6)
SELECT 'EXEC msdb.dbo.sp_update_job @job_name = N''' + name +''', @enabled = 0;'
FROM msdb.dbo.sysjobs
WHERE enabled = 1
  AND category_id <> 6
GO
*/

EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Script_Instance_Object', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02: Check and Correct Data - After MBU', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02: Verify BA Tickets', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_Report: Daily Summary rptStatement', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Reorg_Index', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02: Retrieve BA Transaction', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_Report: Weekly Archive Into rptStatementOld', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'Archive Deposit Member - Step 1: Collect Dormant Member', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'Archive Credit Account: Load statement', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_Licensee: Archive BA Transaction - Correct and Delete data', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02 - Archive Job : Daily Update Cust_TrackingLastBetDate', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_MaintainLicProfileUser', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_Report: Daily Summary RptTotalBalance_Active', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_report_CheckNAPDuplicatedTicket', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Task : LogDB CopyUserLog from DB061.LogDB_UserLog_T', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Task : LogPDB UserLog clean up', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Deadlock_Monitor', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DB06: Database BackupHistory Cleanup', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Monitor Job Fail', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Full_Backup', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'vndba: Monitor Leftover Lettalk test', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_monitor userlog sync time_test', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'Task : Insert SystemFormulaBetUsers for Problem Account', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'Joe : Thursday Routine on DB06', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'vnDBA_monitor_Templog_test', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Monitor Parlay same smatch issue_tmpTest', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'vndba_monitor_whoisactive', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Task : LogPDB CopyUserLog from DB061.LogPDB_UserLog_P', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Clean up data for Licensee Log History', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Getwaitinfo 5 Secs', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Getlockinfo 5 Secs', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_Report: Customer Status History', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02 - running tickets monitor', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02: Deposit Report Summary', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'syspolicy_purge_history', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02: BettradeSelling_ArchiveData', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA: update stats', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Maintain Third Party Bet Statistics', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : MonDB Get DB Info', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_Licensee: Archive BA Transaction - Copy data', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Send SQL Service Restart Alert Mail', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02 : balance check between bettrans and detail table', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA : Clean up SystemFormulaBetUsers table', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02 : Log Digger', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb_report: Task_BetBuilder_Daily_InsertRawData', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02: Check Settlement status', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_MonDB_Reorg', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'bodb02 : Remove Settlement Logs', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Task : LogDB UserLog clean up', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'DBA_Diff_Backup', @enabled = 0;
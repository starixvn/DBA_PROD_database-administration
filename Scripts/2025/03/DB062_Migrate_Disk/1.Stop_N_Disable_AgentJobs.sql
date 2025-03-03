/*
	Task: Stop and disable SQL Jobs related to indicated databases
		bodb_archive
		bodb_Report
		SAS_adhocReport_UAT
		MONDB
		DEL_LasDB_Archive
		bodb_TGRS_UAT
		
	Created on 20250303 by Daniel
	Run on DB062
*/

-- Run to gen script, copy sql in column [StopAndDisableScript] and run, also copy column [EnableBackScript] to save for later enable back the jobs
USE msdb;
GO
DECLARE @DatabaseList TABLE (DatabaseName NVARCHAR(128));
INSERT INTO @DatabaseList (DatabaseName)
VALUES ('bodb_archive'), ('bodb_Report'), ('SAS_adhocReport_UAT'),('MONDB'),('DEL_LasDB_Archive'),('bodb_TGRS_UAT'); -- Add your database names here

SELECT 
		--j.job_id,  
  --     j.name AS JobName,  
  --     s.step_id,  
  --     s.step_name,  
  --     s.database_name,  
  --     s.command, 
	distinct
       'EXEC msdb.dbo.sp_stop_job @job_name = ''' + j.name + '''; ' + 
       'EXEC msdb.dbo.sp_update_job @job_name = ''' + j.name + ''', @enabled = 0;' 
       AS StopAndDisableScript,
		'EXEC msdb.dbo.sp_update_job @job_name = ''' + j.name + ''', @enabled = 1;' 
		AS EnableBackScript
FROM msdb.dbo.sysjobs j  
JOIN msdb.dbo.sysjobsteps s  
    ON j.job_id = s.job_id  
WHERE (s.database_name IN (SELECT DatabaseName FROM @DatabaseList)
   OR EXISTS (
       SELECT 1 
       FROM @DatabaseList d
       WHERE s.command LIKE '%' + d.DatabaseName + '%'
   ))
   and j.enabled = 1
--ORDER BY j.name, s.step_id;


-- Stop and disable jobs:
EXEC msdb.dbo.sp_stop_job @job_name = 'Archive Credit Account: Load statement'; EXEC msdb.dbo.sp_update_job @job_name = 'Archive Credit Account: Load statement', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb_Report: Customer Status History'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Customer Status History', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb_Report: Daily Summary rptStatement'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Daily Summary rptStatement', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb_Report: Daily Summary RptTotalBalance_Active'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Daily Summary RptTotalBalance_Active', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb_report: Task_BetBuilder_Daily_InsertRawData'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb_report: Task_BetBuilder_Daily_InsertRawData', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb_Report: Weekly Statement Process'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Weekly Statement Process', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb_report_CheckNAPDuplicatedTicket'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb_report_CheckNAPDuplicatedTicket', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb02: Check and Correct Data - After MBU'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Check and Correct Data - After MBU', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb02: Deposit Report Summary'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Deposit Report Summary', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA : MonDB Get DB Info'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA : MonDB Get DB Info', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA : Monitor Job Fail'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA : Monitor Job Fail', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA: SSIS Thursday Routine - Update Statistics'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA: SSIS Thursday Routine - Update Statistics', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Deadlock_Monitor'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Deadlock_Monitor', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Diff_Backup'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Diff_Backup', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_ExtendLogCheck'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_ExtendLogCheck', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Full_Backup'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Full_Backup', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Getlockinfo 5 Secs'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getlockinfo 5 Secs', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Getwaitinfo 5 Secs'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getwaitinfo 5 Secs', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Mon_ClearUpData'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_ClearUpData', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Mon_Get_TLog_Usage'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_Get_TLog_Usage', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_MonDB_Reorg'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_MonDB_Reorg', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Script_Instance_Object'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Script_Instance_Object', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Switch_Errorlog'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Switch_Errorlog', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'vnDBA_monitor_Templog_test'; EXEC msdb.dbo.sp_update_job @job_name = 'vnDBA_monitor_Templog_test', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'vndba_monitor_whoisactive'; EXEC msdb.dbo.sp_update_job @job_name = 'vndba_monitor_whoisactive', @enabled = 0;

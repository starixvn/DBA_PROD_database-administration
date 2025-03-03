/*
	Task: Enable back SQL Jobs related to indicated databases
		bodb_archive
		bodb_Report
		SAS_adhocReport_UAT
		MONDB
		DEL_LasDB_Archive
		bodb_TGRS_UAT
		
	Created on 20250303 by Daniel
	Run on DB062
*/

-- Enable back jobs (script gen list jobs copied from step 1):
EXEC msdb.dbo.sp_update_job @job_name = 'Archive Credit Account: Load statement', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Customer Status History', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Daily Summary rptStatement', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Daily Summary RptTotalBalance_Active', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_report: Task_BetBuilder_Daily_InsertRawData', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Weekly Statement Process', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_report_CheckNAPDuplicatedTicket', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Check and Correct Data - After MBU', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Deposit Report Summary', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA : MonDB Get DB Info', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA : Monitor Job Fail', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA: SSIS Thursday Routine - Update Statistics', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Deadlock_Monitor', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Diff_Backup', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_ExtendLogCheck', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Full_Backup', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getlockinfo 5 Secs', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getwaitinfo 5 Secs', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_ClearUpData', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_Get_TLog_Usage', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_MonDB_Reorg', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Script_Instance_Object', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Switch_Errorlog', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'vnDBA_monitor_Templog_test', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'vndba_monitor_whoisactive', @enabled = 1;

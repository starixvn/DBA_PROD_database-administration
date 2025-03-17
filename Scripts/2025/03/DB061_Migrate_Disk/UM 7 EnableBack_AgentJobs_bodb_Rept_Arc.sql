/*
	Task: Enable back SQL Jobs related to indicated databases
		bodb_archive
		bodb_Report
		
	Created on 20250317 by Daniel
	Run on DB061
*/

-- Enable back jobs (script gen list jobs copied from step 1):
EXEC msdb.dbo.sp_update_job @job_name = '__SYNC: [DB061] Archived tables HA', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'Archive Credit Account: Load statement', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Customer Status History', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Daily Summary rptStatement', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Daily Summary RptTotalBalance_Active', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_report: Task_BetBuilder_Daily_InsertRawData', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb_Report: Weekly Statement Process', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Check and Correct Data - After MBU', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Deposit Report Summary', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA: SSIS Thursday Routine - Update Statistics', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Backup: backup dif bodb_archive', @enabled = 1;

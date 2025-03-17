/*
	Task: Disable LS jobs of indicated databases
		bodb_archive
		bodb_Report
		bodb_archive_New
		bodb_Report_New
		
	Created on 20250317 by Daniel
	Run on DB062
*/

-- Disable LS jobs
EXEC msdb.dbo.sp_update_job @job_name = 'LSBackup_bodb_archive', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = 'LSBackup_bodb_Report', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = 'LSCopy_db061_bodb_archive', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = 'LSCopy_db061_bodb_Report', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = 'LSRestore_db061_bodb_archive_New', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = 'LSRestore_db061_bodb_Report_New', @enabled = 0;
/*
	Task: Stop and disable SQL Jobs related to indicated databases
		bodb_archive
		bodb_Report
		
	Created on 20250317 by Daniel
	Run on DB062
*/

-- Run to gen script, copy sql in column [StopAndDisableScript] and run, also copy column [EnableBackScript] to save for later enable back the jobs
USE msdb;
GO
DECLARE @DatabaseList TABLE (DatabaseName NVARCHAR(128));
INSERT INTO @DatabaseList (DatabaseName)
VALUES ('bodb_archive'), ('bodb_Report'); -- Add your database names here

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
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb02: Check and Correct Data - After MBU'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Check and Correct Data - After MBU', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'bodb02: Deposit Report Summary'; EXEC msdb.dbo.sp_update_job @job_name = 'bodb02: Deposit Report Summary', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA: SSIS Thursday Routine - Update Statistics'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA: SSIS Thursday Routine - Update Statistics', @enabled = 0;

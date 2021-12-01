/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: Migrate SQLJobs - Enable
***/
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA_Deadlock_Monitor', 
		@enabled=1
GO

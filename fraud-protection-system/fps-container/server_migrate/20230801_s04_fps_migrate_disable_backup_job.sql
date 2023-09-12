/*
	Created: 20230801@Sol
	Task: disable log shipping job
	DB: FPS_DB02\FPS_01-msdb
*/

GO

USE msdb;

GO

---disable backup job
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_ADMIN', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_LOG', @enabled = 0;